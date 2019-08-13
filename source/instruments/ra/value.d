module instruments.ra.value;
import instruments.instrument;
import instruments.utils;
import instruments.ra.vsc;

import std.string : format;
import std.range : iota;
import std.conv : to;

// Used as arrays of bytes
mixin GetVarName!("size_t", "VR");
mixin GetVarName!("size_t", "VU");
mixin GetVarName!("string", "MR");
mixin GetVarName!("string", "MU");

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

@safe class Value : Instrument{
	/// Variables tracked by all values
	bool[string] trackedVariables;

	const string[] globals;
	const string[] naGlobals;
	size_t threads;
	string moduloNumber;
	Vsc vsc;
	pure this(const string[] _vars, const string[] _naVars, size_t _threads, string _moduloNumber){
		globals = _vars.dup;
		naGlobals = _naVars.dup;
		threads = _threads;
		moduloNumber = _moduloNumber;
		vsc = new Vsc(globals, threads);
	}


	override string initializeMemoryMetadata() pure{
		string result;
		result ~= vsc.initializeMemoryMetadata();
		foreach (ref to; globals){
			result ~= initializeMemoryMetadata(to);
		}
		foreach (ref var; naGlobals){
			result ~= "bit " ~ getNaWriteFlag(var) ~ " = 0;\n";
		}
		result ~= "\n";
		return result;
	}

	string initializeMemoryMetadata(immutable string to) pure{
		string result;
		foreach (i ; iota(threads)){
			result ~= "bit " ~ getVR(i,to) ~ "[" ~ moduloNumber ~ "] = 0;\n";
			result ~= "bit " ~ getVU(i,to) ~ "[" ~ moduloNumber ~ "] = 0;\n";
		}
		foreach (ref from ; globals){
			if (from != to) {
				result ~= "bit " ~ getMR(from,to) ~ "[" ~ moduloNumber ~ "] = 0;\n";
				result ~= "bit " ~ getMU(from,to) ~ "[" ~ moduloNumber ~ "] = 0;\n";
			}
		}
		return result;
	}

	pure override string storeStatementBefore(size_t currThread, string mem){
		auto result = assertVscMemU(currThread, mem);
		result ~= updateStoreStatement(currThread, mem);
		return result;
	}
	pure override string loadStatementBefore(size_t currThread, string mem){
		string result;
		result ~= assertVscMemR(currThread, mem);
		result ~= updateLoadStatement(currThread, mem);
		return result;
	}
	pure override string waitStatementAfterWaiting(size_t currThread, string mem){
		return updateLoadStatement(currThread, mem);
	}
	pure override string waitStatementBeforeWaiting(size_t currThread, string mem, string[] vals){
		return assertVscMemRV(currThread, mem, vals);
	}
	pure override string bcasStatementBeforeWaiting(size_t currThread, string mem, string expBefore){
		return assertVscMemUV(currThread, mem, expBefore);
	}
	pure override string bcasStatementBefore(size_t currThread, string mem){
		return updateRmwStatement(currThread, mem);
	}
	pure override string casStatementBefore(size_t currThread, string mem, string expr){
		return assertVscMemVRCas(currThread, mem, expr);
	}
	pure override string casStatementBeforeRead(size_t currThread, string mem, string expr){
		return updateLoadStatement(currThread, mem);
	}
	pure override string casStatementBeforeUpdate(size_t currThread, string mem, string expr){
		return updateRmwStatement(currThread, mem);
	}
	pure override string rmwStatementBefore(size_t currThread, string mem){
		string result;
		result ~= assertVscMemU(currThread, mem);
		result ~= updateRmwStatement(currThread, mem);
		return result;
	}

	string updateLoadStatement(size_t currThread, in string mem) pure {
		string result;
		result ~= vsc.updateLoadStatement(currThread, mem);
		// Thread learns from MEM
		foreach (ref other; globals){
			result ~= updateLoadStatement(currThread, mem, other);
		}
		return result;
	}

	string updateLoadStatement(size_t currThread, in ref string mem, in ref string other) pure {
		string result;
		if (mem != other){
			result ~= intersectViewMemLeft(getVR(currThread, other), getMR(mem, other));
			result ~= intersectViewMemLeft(getVU(currThread, other), getMU(mem, other));
		} else {
			result ~= clearViewMem(getVR(currThread, mem));
			result ~= clearViewMem(getVU(currThread, mem));
		}
		return result;
	}

	string updateStoreStatement(size_t currThread, string mem) pure{
		string result;
		result ~= vsc.updateStoreStatement(currThread, mem);

		// Every thread forget MEM, current thread learns MEM
		// (Thread)(Location)
		// Other locations forget MEM
		// (Other)(Mem)
		result ~= updateStoreStatementMem(currThread, mem);
		// MEM learns about changes in thread
		// (Mem)(Other)
		foreach (ref other; globals) {
			if (other == mem) continue;
			result ~= updateStoreStatementOther(currThread, mem, other);
		}
		return result;
	}
	string updateStoreStatementMem(size_t currThread, string mem) pure{
		string result;
		// Every thread forget MEM, current thread learns MEM
		// (Thread)(Location)
		foreach (i; iota(threads)){
			if (i == currThread) {
				result ~= clearViewMem(getVR(i, mem));
				result ~= clearViewMem(getVU(i, mem));
			} else {
				result ~= "%s[%s] = 1;\n".format(getVR(i, mem), mem);
				result ~= "%s[%s] = 1;\n".format(getVU(i, mem), mem);
			}
		}
		// Other locations forget MEM
		// (Other)(Mem)
		foreach (ref other; globals) {
			if (other == mem) continue;
			result ~= "%s[%s] = 1;\n".format(getMR(other, mem), mem);
			result ~= "%s[%s] = 1;\n".format(getMU(other, mem), mem);
		}
		return result;
	}
	string updateStoreStatementOther(size_t currThread, string mem, string other) pure{
		string result;
		if (mem == other) return "";
		result ~= cloneViewMem(getVR(currThread, other), getMR(mem, other));
		result ~= cloneViewMem(getVU(currThread, other), getMU(mem, other));
		return result;
	}

	string updateRmwStatement(size_t currThread, string mem) pure{
		string result;
		result ~= vsc.updateRmwStatement(currThread, mem);
		result ~= updateRmwStatementMem(currThread, mem);
		// Thread learns from MEM
		// Memory learns from thread
		foreach (ref other; globals){
			if (mem == other) continue;
			result ~= updateRmwStatementOther(currThread, mem, other);
		}
		return result;
	}

	string updateRmwStatementMem(size_t currThread, string mem) pure{
		string result;
		// Other threads forget about MEM in SC
		// (Thread)(Mem)
		foreach (i; iota(threads)){
			if (i != currThread) {
				result ~= "%s[%s] = 1;\n".format(getVR(i, mem), mem);
			}
		}
		foreach (ref other; globals){
			if (mem == other) {
				result ~= clearViewMem(getVR(currThread, mem));
				result ~= clearViewMem(getVU(currThread, mem));
			} else {
				// (Other)(Mem)
				result ~= "%s[%s] = 1;\n".format(getMR(other, mem), mem);
			}
		}
		return result;
	}
	string updateRmwStatementOther(size_t currThread, string mem, string other) pure{
		string result;
		if (mem == other) return "";
		// (Mem)(Other)
		// (currThread)(Other)
		result ~= intersectViewMemLeft(getVR(currThread, other), getMR(mem, other));
		result ~= intersectViewMemLeft(getVU(currThread, other), getMU(mem, other));
		result ~= cloneViewMem(getVR(currThread, other), getMR(mem, other));
		result ~= cloneViewMem(getVU(currThread, other), getMU(mem, other));
		return result;
	}


	/**
	  Generate line for asserting if x \in VSC then x can't read stable values

	  Params:
	  thread = The VSC thread
	  loc = the memory location, x
	  Returns: the assert message
	 **/
	string assertVscMemR(size_t thread, const ref string loc) @safe pure {
		auto i = getAssertVariable();
		auto result = "
			if
				:: %1$s > 0 -> for (%2$s in %3$s) { assert(%3$s[%2$s] == 0); }
		:: else
			fi;\n".format(getVSC(thread, loc), i, getVR(thread, loc));
		return result;
	}
	string assertVscMemU(size_t thread, const ref string loc) @safe pure {
		auto i = getAssertVariable();
		auto result = "
			if
				:: %1$s > 0 -> for (%2$s in %3$s) { assert(%3$s[%2$s] == 0); }
		:: else
			fi;\n".format(getVSC(thread, loc), i, getVU(thread, loc));
		return result;
	}
	string assertVscMemRV(size_t thread, const ref string loc, string[] vals) @safe pure {
		auto i = getAssertVariable();
		string assertLines;
		foreach (ref val; vals) {
			assertLines ~= "assert(%1$s[%2$s] == 0);\n".format(getVR(thread, loc), val);
		}
		auto result = "
			if
				:: %1$s > 0 -> %2$s;
		:: else
			fi;\n".format(getVSC(thread, loc), assertLines);
		return result;
	}

	string assertVscMemUV(size_t thread, const ref string loc, string val) @safe pure {
		auto i = getAssertVariable();
		auto result = "
			if
				:: %1$s > 0 -> assert(%2$s[%3$s] == 0);
		:: else
			fi;\n".format(getVSC(thread, loc), getVU(thread, loc), val);
		return result;
	}

	string assertVscMemVRCas(size_t thread, const ref string loc, string expr) pure{
		auto i = getAssertVariable();
		auto result = "
			if
				:: %1$s > 0 -> for (%2$s in %3$s) { 
					if 
						:: %2$s == %6$s -> {
							assert(%4$s[%2$s] == 0);
						}
					:: else -> {
						assert(%3$s[%2$s] == 0);
					}
					fi;
				}
		:: else
			fi;\n".format(getVSC(thread, loc), i, getVR(thread, loc), getVU(thread, loc), loc, expr);
		return result;
	}

	string clearViewMem(string dst) @safe pure {
		auto i = getAssertVariable();
		auto result = "
			for (%1$s in %2$s) { %2$s[%1$s] = 0; };\n".format(i, dst);
		return result;
	}

	string cloneViewMem(string src, string dst) @safe pure {
		auto i = getAssertVariable();
		auto result = "
			for (%1$s in %2$s) { %2$s[%1$s] = %3$s[%1$s]; };\n".format(i, dst, src);
		return result;
	}

	string intersectViewMemLeft(string lhs, string rhs) @safe pure {
		auto i = getAssertVariable();
		auto result = "
			for (%1$s in %2$s) { %2$s[%1$s] = %2$s[%1$s] && %3$s[%1$s]; };\n".format(i, lhs, rhs);
		return result;
	}

	pure string getAssertVariable(){
		return "__i_assert";
	}

	pure override string[string] getLocals(){
		return [getAssertVariable(): "byte",];
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
	string assertKnowsNA(const ref string loc) @safe pure {
		return "assert(%s == 0);\n".format(getNaWriteFlag(loc));
	}
}
