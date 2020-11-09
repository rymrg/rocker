module instruments.ra.tracksome;
import instruments.instrument;
import instruments.utils;
import instruments.ra.vsc;
import pegged.grammar;
import instruments.access;
import instruments.lib.vsc.memory;

import std.string : format;
import std.range : iota;
import std.conv : to;
import std.algorithm.iteration : map;
import std.typecons;

mixin GetVarNameValue!("size_t", "VR");
mixin GetVarNameValue!("size_t", "VU");
mixin GetVarNameValue!("string", "WR");
mixin GetVarNameValue!("string", "WU");
mixin GetVarName!("size_t", "VRC");
mixin GetVarName!("size_t", "VUC");
mixin GetVarName!("string", "WRC");
mixin GetVarName!("string", "WUC");


/**
  Non-atomics are verified using write flags

  Params:
  var = Name of NA var

  Returns:
  Promela variable for tracking writes to var
  */
string getNaWriteFlag(string var) pure @safe{
	return "__WriteFlag_" ~ var;
}

pure @safe class TrackSome : Instrument{
	/// Variables tracked for some values
	bool[size_t][string] trackedVariablesValues;

	const string[] globals;
	const string[] naGlobals;
	immutable size_t threads;
	string moduloNumber;
	mixin MemoryOps;
	Vsc vsc;
	pure this(const string[] _vars, const string[] _naVars, size_t _threads, string _moduloNumber, const ref ParseTree t){
		import std.algorithm : sort;
		globals = _vars.dup;
		naGlobals = _naVars.dup;
		threads = _threads;
		moduloNumber = _moduloNumber;
		vsc = new Vsc(globals, threads);

		// Init trackedVariablesValues for all globals
		foreach (v; globals){
			trackedVariablesValues[v][-1] = false;
			trackedVariablesValues[v].remove(-1);
		}

		// Locks should track value 0
		foreach (lock; findLocks(t)){
			trackedVariablesValues[lock][0] = true;
		}

		// Track everything else
		import std.algorithm : filter;
		import std.exception : enforce;
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


	pure override string initializeMemoryMetadata(){
		string result;
		result ~= vsc.initializeMemoryMetadata();
		foreach (ref to; globals){
			foreach (i ; iota(threads)){
				foreach (v ; trackedVariablesValues[to].byKey){
					result ~= "bit " ~ getVR(i,to,v) ~ " = 0;\n";
					result ~= "bit " ~ getVU(i,to,v) ~ " = 0;\n";
				}
				result ~= "bit " ~ getVRC(i,to) ~ " = 0;\n";
				result ~= "bit " ~ getVUC(i,to) ~ " = 0;\n";
			}
			foreach (ref from ; globals){
				if (from != to) {
					foreach (v ; trackedVariablesValues[to].byKey){
						result ~= "bit " ~ getWR(from,to,v) ~ " = 0;\n";
						result ~= "bit " ~ getWU(from,to,v) ~ " = 0;\n";
					}
					result ~= "bit " ~ getWUC(from,to) ~ " = 0;\n";
					result ~= "bit " ~ getWRC(from,to) ~ " = 0;\n";
				}
			}
		}
		foreach (ref var; naGlobals){
			result ~= "bit " ~ getNaWriteFlag(var) ~ " = 0;\n";
		}
		result ~= "\n";
		return result;
	}
	pure override string storeStatementBefore(size_t currThread, string mem, StoreType storeType = StoreType.rel){
		string result;
		result ~= assertVscKnowledge!"VU"(currThread, mem);
		result ~= updateStoreStatement(currThread, mem);
		return result;
	}
	pure override string loadStatementBefore(size_t currThread, string mem, string reg, LoadType loadType){
		string result;
		result ~= assertVscKnowledge!"VR"(currThread, mem);
		result ~= updateLoadStatement(currThread, mem);
		return result;
	}
	pure override string waitStatementAfterWaiting(size_t currThread, string mem, LoadType){
		return updateLoadStatement(currThread, mem);
	}
	pure override string waitStatementBeforeWaiting(size_t currThread, string mem, string[] vals){
		return assertVscKnowledge!"VR"(currThread, mem, vals);
	}
	pure override string bcasStatementBeforeWaiting(size_t currThread, string mem, string expBefore){
		return assertVscKnowledge!"VU"(currThread, mem, [expBefore]);
	}
	pure override string bcasStatementBefore(size_t currThread, string mem, LoadType, StoreType){
		return updateRmwStatement(currThread, mem);
	}
	pure override string casStatementBefore(size_t currThread, string mem, string expr){
		string condition;
		foreach (v; trackedVariablesValues[mem].byKey){
			condition ~= "if
				:: (%1$s == %2$s) -> { assert(%3$s == 0); }
			:: else -> { assert(%4$s == 0); }
			fi;\n".format(expr, v, getVU(currThread, mem, v), getVR(currThread, mem, v));
		}
		condition ~= "assert(%s == 0);\n".format(getVRC(currThread, mem));
		auto result = "
			if
				:: %1$s > 0 -> { %2$s } 
		:: else
			fi;\n".format(getVSC(currThread, mem), condition);
		return result;
	}
	pure override string casStatementBeforeRead(size_t currThread, string mem, string expr, LoadType){
		return updateLoadStatement(currThread, mem);
	}
	pure override string casStatementBeforeUpdate(size_t currThread, string mem, string expr, LoadType, StoreType){
		return updateRmwStatement(currThread, mem);
	}
	pure override string rmwStatementBefore(size_t currThread, string mem, string reg, LoadType, StoreType){
		auto result = assertVscKnowledge!"VU"(currThread, mem);
		result ~= updateRmwStatement(currThread, mem);
		return result;
	}
	string updateLoadStatement(size_t currThread, string mem) pure{
		string result;
		result ~= vsc.updateLoadStatement(currThread, mem);
		// Thread learns from MEM
		foreach (ref other; globals){
			if (mem == other) {
				result ~= clearViewMem!"VR"(currThread, mem);
				result ~= clearViewMem!"VU"(currThread, mem);
			} else {
				result ~= intersectViewMemLeft!("VR", "WR")(currThread, mem, other);
				result ~= intersectViewMemLeft!("VU", "WU")(currThread, mem, other);
			}
		}
		return result;
	}

	string updateStoreStatement(size_t currThread, string mem) pure{
		string result;
		result ~= vsc.updateStoreStatement(currThread, mem);

		// Every thread forget MEM, current thread learns MEM (Thread)(Location)
		foreach (i; iota(threads)){
			if (i == currThread) {
				result ~= clearViewMem!"VR"(currThread, mem);
				result ~= clearViewMem!"VU"(currThread, mem);
			} else {
				result ~= makePlacesForgetLastWriteLoc!(["VR", "VU"])(i, mem);
			}
		}
		// Other locations forget MEM (Other)(Mem)
		// MEM learns about changes in thread (Mem)(Other)
		foreach (ref other; globals) {
			if (other == mem) continue;
			result ~= makePlacesForgetLastWriteLoc!(["WR", "WU"])(other, mem);
			result ~= cloneViewMem!("WR", "VR")(mem, currThread, other);
			result ~= cloneViewMem!("WU", "VU")(mem, currThread, other);
		}
		return result;
	}

	string updateRmwStatement(size_t currThread, string mem) pure{
		string result;
		result ~= vsc.updateRmwStatement(currThread, mem);

		// Thread learns from MEM
		result ~= clearViewMem!"VR"(currThread, mem);
		result ~= clearViewMem!"VU"(currThread, mem);
		foreach (ref other; globals){
			if (mem == other) continue;
			result ~= intersectViewMemLeft!("VR", "WR")(currThread, mem, other);
			result ~= intersectViewMemLeft!("VU", "WU")(currThread, mem, other);
		}

		// Every thread forget MEM (Thread)(Location)
		foreach (i; iota(threads)){
			if (i == currThread) continue;
			result ~= makePlacesForgetLastWriteLoc!(["VR"])(i, mem);
		}

		// Other locations forget MEM (Other)(Mem)
		// MEM learns about changes in thread (Mem)(Other)
		foreach (ref other; globals) {
			if (other == mem) continue;
			result ~= makePlacesForgetLastWriteLoc!(["WR"])(other, mem);
			// Intersection to VR happened earlier
			result ~= cloneViewMem!("WR", "VR")(mem, currThread, other);
			// Intersection to VU happened earlier
			result ~= cloneViewMem!("WU", "VU")(mem, currThread, other);
		}
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

	string assertKnowsNA(const ref string loc) @safe pure {
		return "assert(%s == 0);\n".format(getNaWriteFlag(loc));
	}

	pure override string naStoreStatementBeforeAtomic(size_t currThread, string mem){
		auto result = "atomic {
			%s
			%s = 1;
		}
		".format(assertKnowsNA(mem), getNaWriteFlag(mem));
		return result;
	}
	pure override string naStoreStatementBefore(size_t currThread, string mem){
		return "%s = 0;".format(getNaWriteFlag(mem));
	}
	pure override string naLoadStatementBefore(size_t currThread, string mem){
		auto result = assertKnowsNA(mem);
		return result;
	}

	pure override string[string] getLocals(size_t){
		return null;
	}

	override string verifyLocal(size_t currThread, in string var) const pure nothrow @nogc {
		return null;
	}
	override string cleanLocal(size_t currThread, in string var) const pure nothrow @nogc {
		return null;
	}

	override string transetiveTaint(size_t, in string, in string[]) const pure nothrow @nogc {
		return null;
	}

	override Tuple!(bool, string) fence(size_t, FenceType fenceType){
		final switch (fenceType) with (FenceType){
			case acq:
			case rel:
			case acq_rel:
				return tuple(true, "skip;\n");
			case seq_cst:
			case upd:
				return Tuple!(bool, string)(false, null);
		}
	}
}
