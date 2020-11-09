module instruments.rlx.obsstrongfence;
import instruments.instrument;
import instruments.utils;
import instruments.sc.vsc;
import pegged.grammar;
import instruments.access;
import instruments.lib.vsc.memory;
import instruments.rlx.register;
import instruments.config : Config;

import std.string : format;
import std.range : iota, chain;
import std.algorithm.iteration : map;
import std.algorithm.setops : cartesianProduct;
import std.array : join, array;
import std.conv : to;
import std.typecons;
import std.exception : enforce;

import instruments.rlx.targettype;
enum targetTypes = [ TargetType("", "locsAll"), TargetType("U", "globals"), ];

// Track by single value
mixin GetVarNameValue!("size_t", "Vacq");
mixin GetVarNameValue!("size_t", "Vcur");
mixin GetVarNameValue!("size_t", "Vrel");
mixin GetVarNameValue!("size_t", "VUacq");
mixin GetVarNameValue!("size_t", "VUcur");
mixin GetVarNameValue!("size_t", "VUrel");
mixin GetVarNameValue!("string", "Mem");
mixin GetVarNameValue!("string", "MemU");
mixin GetVarName!("size_t", "VacqC");
mixin GetVarName!("size_t", "VcurC");
mixin GetVarName!("size_t", "VrelC");
mixin GetVarName!("size_t", "VUacqC");
mixin GetVarName!("size_t", "VUcurC");
mixin GetVarName!("size_t", "VUrelC");
mixin GetVarName!("string", "MemC");
mixin GetVarName!("string", "MemUC");

/**
  Taint flag for local variables

  Params:
  var = Name of local var

  Returns:
  Promela variable for taintness checking
 */
string getTaintFlag(string var) pure @safe{
       return "__LocalTaint_" ~ var;
}


/**
  NA Variable name for thread

  Params:
  var = Name of navar
  tid = Thread

  Returns:
  Name of variable used for NA write by that thread
 */
string getNAVar(string var, size_t tid) pure @safe{
       return "__NA_" ~ var ~ "_" ~ tid.to!string;
}

/** Observation robustness, no sc fence */
pure @safe class ObsStrongFence : Instrument{
	/// Variables tracked for some values
	bool[size_t][string] trackedVariablesValues;

	private const string[] globals;
	private const string[] naGlobals;
	private const string[] naGlobalsReal;
	private const string[] locsAll;
	private immutable size_t threads;
	private string moduloNumber;
	private Vsc vsc;
	mixin MemoryOps;
	private const(string)[][size_t] locals;
	pure this(const string[] _vars, const string[] _naVars, size_t _threads, string _moduloNumber, const ref ParseTree t, const(string)[][size_t] _locals){
		globals = _vars.dup;
		naGlobalsReal = _naVars.dup;
		naGlobals = _naVars.dup ~ cartesianProduct(_naVars,_threads.iota).map!(a=>getNAVar(a.expand)).array;
		locsAll = globals ~ naGlobals;
		threads = _threads;
		moduloNumber = _moduloNumber;
		locals = _locals;
		vsc = new Vsc(globals, threads);

		// Init trackedVariablesValues for all globals
		foreach (v; locsAll){
			trackedVariablesValues[v][-1] = false;
			trackedVariablesValues[v].remove(-1);
		}

		// Locks should track value 0
		foreach (lock; findLocks(t)){
			trackedVariablesValues[lock][0] = true;
		}

		// Track everything else
		import std.algorithm : filter;
		foreach (c; t.children[0].children.filter!(c => c.name == "Tpl.TrackedValue")){
			const auto variable = c.matches[0];
			foreach (cp; c.children){
				if (cp.name == "Tpl.Number"){
					const auto v = cp.matches[0].to!size_t;
					enforce(v < moduloNumber.to!size_t, "Can't track variable %s with value %s when max_memory is %s".format(variable, v, moduloNumber.to!size_t - 1));
					trackedVariablesValues[variable][v] = true;
				}
			}
			if (c.matches.length > 1 && c.matches[1] == "all"){
				import std.array : assocArray;
				import std.range : iota, zip, repeat;
				trackedVariablesValues[variable] = assocArray(zip(iota(0, moduloNumber.to!size_t), true.repeat));
			}
		}
	}

	package pure static Instrument make(Config config) {
		with (config){
			return new typeof(this)(vars, naVars, threads, moduloNumber, parseTree, locals);
		}
	}
	private enum name = "obsStrongFence";
	private enum desc = "observation robustness with strong SC fences";
	mixin register;

	pure override string initializeMemoryMetadata(){
		string result;
		result ~= vsc.initializeMemoryMetadata();
		static foreach (u; targetTypes){ {
			mixin("auto locs = %s;\n".format(u.vars));
			foreach (ref to; locs){
				foreach (i ; iota(threads)){
					foreach (v ; trackedVariablesValues[to].byKey){
						static foreach(b; ["acq", "cur", "rel"]){
							mixin(q{result ~= "bit " ~ getV%s%s(i,to,v) ~ " = 0;\n";}.format(u.text,b));
						}
					}
					static foreach(b; ["acq", "cur", "rel"]){
						mixin(q{result ~= "bit " ~ getV%s%sC(i,to) ~ " = 0;\n";}.format(u.text,b));
					}
				}
				foreach (ref from ; globals){
					if (from != to) {
						foreach (v ; trackedVariablesValues[to].byKey){
							mixin(q{result ~= "bit " ~ getMem%s(from,to,v) ~ " = 0;\n";}.format(u.text));
						}
						mixin(q{result ~= "bit " ~ getMem%sC(from,to) ~ " = 0;\n";}.format(u.text));
					}
				}
			}
		} }
		result ~= "\n";
		return result;
	}
	pure override string storeStatementBefore(size_t currThread, string mem, StoreType storeType){
		string result;
		result ~= assertVscKnowledge!"VUcur"(currThread, mem);
		result ~= updateStoreStatement(currThread, mem, storeType);
		return result;
	}
	pure override string loadStatementBefore(size_t currThread, string mem, string reg, LoadType loadType){
		string result;
		//result ~= assertVscKnowledge!"Vcur"(currThread, mem);
		//result ~= updateLoadStatement(currThread, mem, loadType);
		string upd = updateLoadStatementInner(currThread, mem, loadType) ~ "%s = false;\n".format(reg.getTaintFlag);
		result ~= conditionalVscKnowledge!"Vcur"(currThread, mem, upd, "%s = true;".format(reg.getTaintFlag));
		result ~= vsc.updateLoadStatement(currThread, mem);
		return result;
	}
	pure override string waitStatementAfterWaiting(size_t currThread, string mem, LoadType loadType){
		return updateLoadStatement(currThread, mem, loadType);
	}
	pure override string waitStatementBeforeWaiting(size_t currThread, string mem, string[] vals){
		return assertVscKnowledge!"Vcur"(currThread, mem, vals);
	}
	pure override string bcasStatementBeforeWaiting(size_t currThread, string mem, string expBefore){
		return assertVscKnowledge!"VUcur"(currThread, mem, [expBefore]);
	}
	pure override string bcasStatementBefore(size_t currThread, string mem, LoadType loadType, StoreType storeType){
		return updateRmwStatement(currThread, mem, loadType, storeType);
	}
	pure override string casStatementBefore(size_t currThread, string mem, string expr){
		string condition;
		foreach (v; trackedVariablesValues[mem].byKey){
			condition ~= "if
				:: (%1$s == %2$s) -> { assert(%3$s == 0); }
			:: else -> { assert(%4$s == 0); }
			fi;\n".format(expr, v, getVUcur(currThread, mem, v), getVcur(currThread, mem, v));
		}
		condition ~= "assert(%s == 0);\n".format(getVcurC(currThread, mem));
		auto result = "
			if
				:: %1$s > 0 -> { %2$s } 
		:: else
			fi;\n".format(getVSC(currThread, mem), condition);
		return result;
	}

	pure override string casStatementBeforeRead(size_t currThread, string mem, string expr, LoadType loadType){
		string result;
		result ~= updateLoadStatement(currThread, mem, loadType);
		return result;
	}
	pure override string casStatementBeforeUpdate(size_t currThread, string mem, string expr, LoadType loadType, StoreType storeType){
		string result;
		result ~= updateRmwStatement(currThread, mem, loadType, storeType);
		return result;
	}

	pure override string rmwStatementBefore(size_t currThread, string mem, string reg, LoadType loadType, StoreType storeType){
		string result;
		result ~= assertVscKnowledge!"VUcur"(currThread, mem);
		result ~= updateRmwStatement(currThread, mem, loadType, storeType);
		result ~= "%s = false;\n".format(reg.getTaintFlag);
		return result;
	}

	override Tuple!(bool, string) fence(size_t currThread, FenceType fenceType){
		final switch (fenceType) with (FenceType){
			case acq:
				string result;
				static foreach (u; targetTypes){
					mixin(q{result ~= cloneViewMem!("V%1$scur", "V%1$sacq")(currThread, currThread, %2$s);}.format(u.text,u.vars));
				}
				return typeof(return)(true, result);
			case rel:
				string result;
				static foreach (u; targetTypes){
					mixin(q{result ~= cloneViewMem!("V%1$srel", "V%1$scur")(currThread, currThread, %2$s);}.format(u.text,u.vars));
				}
				return typeof(return)(true, result);
			case acq_rel:
				string result;
				static foreach (u; targetTypes){
					mixin(q{result ~= cloneViewMem!("V%1$scur", "V%1$sacq")(currThread, currThread, %2$s);}.format(u.text,u.vars));
					mixin(q{result ~= cloneViewMem!("V%1$srel", "V%1$scur")(currThread, currThread, %2$s);}.format(u.text,u.vars));
				}
				return typeof(return)(true, result);
			case seq_cst:
				// SC Fence isn't supported Use U fence instead
				goto case upd;
				//enforce(false, "Seq-Fence isn't supported yet");
			case upd:
				return typeof(return)(false, null);
		}
	}

	private string updateLoadStatementInner(size_t currThread, string mem, LoadType loadType) pure{
		string result;
		result ~= clearViewMem!"Vacq"(currThread, mem);
		result ~= clearViewMem!"VUacq"(currThread, mem);
		result ~= clearViewMem!"Vcur"(currThread, mem);
		result ~= clearViewMem!"VUcur"(currThread, mem);
		// Thread learns from MEM
		static foreach(u; targetTypes){
			mixin(
					q{result ~= intersectViewMemLeft!("V%1$sacq", "Mem%1$s")(currThread, mem, %2$s);}.format(u.text, u.vars)
				 );
			if (loadType >= LoadType.acq){
				mixin(
						q{result ~= intersectViewMemLeft!("V%1$scur", "Mem%1$s")(currThread, mem, %2$s);}.format(u.text, u.vars)
					 );
			}
		}
		return result;
	}
	string updateLoadStatement(size_t currThread, string mem, LoadType loadType) pure{
		string result;
		result ~= vsc.updateLoadStatement(currThread, mem);
		result ~= updateLoadStatementInner(currThread, mem, loadType);

		return result;
	}

	string updateStoreStatement(size_t currThread, string mem, StoreType storeType) pure{
		string result;
		result ~= vsc.updateStoreStatement(currThread, mem);

		// Every thread forget MEM, current thread learns MEM (Thread)(Location)
		result ~= clearViewMem!"Vacq"(currThread, mem);
		result ~= clearViewMem!"VUacq"(currThread, mem);
		result ~= clearViewMem!"Vcur"(currThread, mem);
		result ~= clearViewMem!"VUcur"(currThread, mem);
		result ~= makePlacesForgetLastWriteLoc!(["Vrel", "VUrel"])(currThread, mem);
		foreach (i; iota(threads)){
			if (i == currThread) continue;
			result ~= makePlacesForgetLastWriteLoc!(["Vacq", "Vcur", "Vrel", "VUacq", "VUcur", "VUrel"])(i, mem);
		}
		// Other locations forget MEM (Other)(Mem)
		// MEM learns about changes in thread (Mem)(Other)
		foreach (ref other; globals) {
			if (other == mem) continue;
			result ~= makePlacesForgetLastWriteLoc!(["Mem", "MemU"])(other, mem);
		}
		final switch (storeType) with (StoreType){
			case rlx:
				static foreach(u; targetTypes){
					mixin( q{result ~= cloneViewMem!("Mem%1$s", "V%1$srel")(mem, currThread, %2$s);}.format(u.text, u.vars));
				}
				break;
			case rel:
				static foreach(u; targetTypes){
					mixin( q{result ~= cloneViewMem!("Mem%1$s", "V%1$scur")(mem, currThread, %2$s);}.format(u.text, u.vars));
				}
				break;
		}

		return result;
	}

	string updateRmwStatement(size_t currThread, string mem, LoadType loadType = LoadType.rlx, StoreType storeType = StoreType.rlx) pure {
		string result;
		result ~= vsc.updateRmwStatement(currThread, mem);

		// Load part
		result ~= updateLoadStatementInner(currThread, mem, loadType);

		// Store part
		// Every thread forget MEM, current thread learns MEM (Thread)(Location)
		result ~= clearViewMem!"Vacq"(currThread, mem);
		result ~= clearViewMem!"VUacq"(currThread, mem);
		result ~= clearViewMem!"Vcur"(currThread, mem);
		result ~= clearViewMem!"VUcur"(currThread, mem);
		result ~= makePlacesForgetLastWriteLoc!(["Vrel"])(currThread, mem);
		foreach (i; iota(threads)){
			if (i == currThread) continue;
			result ~= makePlacesForgetLastWriteLoc!(["Vacq", "Vcur", "Vrel"])(i, mem);
		}
		// Other locations forget MEM (Other)(Mem)
		// MEM learns about changes in thread (Mem)(Other)
		foreach (ref other; globals) {
			if (other == mem) continue;
			result ~= makePlacesForgetLastWriteLoc!(["Mem"])(other, mem);
		}
		final switch (storeType) with (StoreType){
			case rlx:
				static foreach(u; targetTypes){
					mixin( q{result ~= intersectViewMemLeft!("Mem%1$s", "V%1$srel")(mem, currThread, %2$s);}.format(u.text, u.vars));
				}
				break;
			case rel:
				static foreach(u; targetTypes){
					mixin( q{result ~= intersectViewMemLeft!("Mem%1$s", "V%1$scur")(mem, currThread, %2$s);}.format(u.text, u.vars));
				}
				break;
		}
		return result;
	}

	string conditionalVscKnowledge(string var, T)(T fst, string loc, string injectGood, string injectBad){
		mixin("auto getVar = &get%s;".format(var));
		mixin("auto getVarC = &get%sC;".format(var));
		string result;
		result ~= "
			if
				:: (%s > 0) && (%s) -> {\n %s \n}
				:: else -> {\n %s \n};
				fi;\n".format(
						getVSC(fst, loc),
						trackedVariablesValues[loc].byKey
						.map!(v=>getVar(fst, loc, v))
						.chain([getVarC(fst, loc)])
						.map!(x => "%s == 1".format(x))
						.join(" || "),
						injectBad,
						injectGood,
					);
		return result;
	}

	string assertVscKnowledge(string var, T)(T fst, string loc){
		mixin("auto getVar = &get%s;".format(var));
		mixin("auto getVarC = &get%sC;".format(var));
		string result;
		result ~= "
			if
				:: %s > 0 -> { \n".format(getVSC(fst, loc));
					foreach (v; trackedVariablesValues[loc].byKey){
						result ~= "assert(%s == 0);\n".format(getVar(fst, loc, v));
					}
					result ~= "assert(%s == 0);\n".format(getVarC(fst, loc));
					result ~= "}
		:: else
			fi;\n";
		return result;
	}

	string assertVscKnowledge(string var, T)(T fst, string loc, string[] vals){
		mixin("auto getVar = &get%s;".format(var));
		mixin("auto getVarC = &get%sC;".format(var));
		string condition;
		foreach (val ; vals){
			condition ~= "if\n";
			foreach (v ; trackedVariablesValues[loc].byKey){
				condition ~= ":: (%1$s == %2$s) -> { assert(%3$s == 0); }\n".format(val, v, getVar(fst, loc, v));
			}
			condition ~= ":: else -> { assert(%s == 0); }\n".format(getVarC(fst, loc));
			condition ~= "fi;\n";
		}
		auto result = "
			if
				:: %1$s > 0 -> { %2$s } 
		:: else
			fi;\n".format(getVSC(fst, loc), condition);
		return result;
	}

	string assertKnowsNA(size_t thread, const ref string loc) @safe pure const {
		return "assert(%s == 0);\n".format(getVcurC(thread,loc));
	}

	pure override string naStoreStatementBeforeAtomic(size_t currThread, string mem){
		return null;
	}
	pure override string naStoreStatementBefore(size_t currThread, string mem){
		return threads.iota.map!(i=>naStoreBeforeHelper(currThread, getNAVar(mem, i))).join;
	}
	private pure string naStoreBeforeHelper(size_t currThread, string mem){
		auto result = assertKnowsNA(currThread, mem);
		foreach (i; iota(threads)){
			if (i == currThread){
				result ~= makePlacesForgetLastWriteLoc!([
						"Vrel", 
				])(i, mem);
			} else {
				result ~= makePlacesForgetLastWriteLoc!([
						"Vacq", "Vcur", "Vrel", 
				])(i, mem);
			}
		}
		foreach (ref other; globals) {
			if (other == mem) continue;
			result ~= makePlacesForgetLastWriteLoc!(["Mem"])(other, mem);
		}
		return result;
	}
	pure override string naLoadStatementBefore(size_t currThread, string mem){
		//auto result = assertKnowsNA(currThread, mem);
		auto result = naStoreBeforeHelper(currThread, getNAVar(mem, currThread));
		return result;
	}

	pure override string[string] getLocals(size_t currThread){
		import std.range : zip, repeat;
		import std.array : assocArray;
		return zip(locals[currThread].map!getTaintFlag, "bool".repeat).assocArray;
	}

	pure override string verifyLocal(size_t currThread, string var) const{
		return "assert(%s == 0);\n".format(var.getTaintFlag);
	}
	pure override string cleanLocal(size_t currThread, string var) const{
		return "%s = 0;\n".format(var.getTaintFlag);
	}

	override string transetiveTaint(size_t currThread, in string var, in string[] vars) const pure {
		string result =	cleanLocal(currThread, var);
		foreach (v; vars){
			result ~= "%1$s = %1$s | %2$s;\n".format(var.getTaintFlag, v.getTaintFlag);
		}
		return result;
	}
}
