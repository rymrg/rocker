module instruments.ra.vra;
import instruments.instrument;
import instruments.utils;
import instruments.ra.vsc;

import std.string : format;
import std.range : iota;
import std.conv : to;

mixin GetVarName!("size_t", "VRA");
mixin GetVarName!("size_t", "VRAU");
mixin GetVarName!("string", "MRA");
mixin GetVarName!("string", "MRAU");

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

@safe class Vra : Instrument{
	const string[] globals;
	const string[] naGlobals;
	size_t threads;
	Vsc vsc;

	pure this(const string[] _vars, const string[] _naVars, size_t _threads){
		globals = _vars.dup;
		naGlobals = _naVars.dup;
		threads = _threads;
		vsc = new Vsc(globals, threads);
	}

	pure override string initializeMemoryMetadata(){
		string result;
		result ~= vsc.initializeMemoryMetadata();
		foreach (ref to; globals){
			result ~= initializeMemoryMetadata(to);
		}
		result ~= "\n";
		foreach (ref var; naGlobals){
			result ~= "bit " ~ getNaWriteFlag(var) ~ " = 0;\n";
		}
		return result;
	}
	string initializeMemoryMetadata(immutable string to) pure{
		string result;
			foreach (i ; iota(threads)){
				result ~= "bit " ~ getVRA(i,to) ~ " = 1;\n";
				result ~= "bit " ~ getVRAU(i,to) ~ " = 1;\n";
			}
			foreach (ref from ; globals){
				if (from != to) {
					result ~= "bit " ~ getMRA(from,to) ~ ";\n";
					result ~= "bit " ~ getMRAU(from,to) ~ ";\n";
				}
			}
		return result;
	}

	pure override string storeStatementBefore(size_t currThread, string mem){
		auto result = assertVrauVsc(currThread, mem);
		result ~= updateStoreStatement(currThread, mem);
		return result;
	}
	pure override string loadStatementBefore(size_t currThread, string mem){
		auto result = assertVraVsc(currThread, mem);
		result ~= updateLoadStatement(currThread, mem);
		return result;
	}
	pure override string waitStatementAfterWaiting(size_t currThread, string mem){
		return updateLoadStatement(currThread, mem);
	}
	pure override string waitStatementBeforeWaiting(size_t currThread, string mem, string[] vals){
		return assertVraVsc(currThread, mem);
	}
	pure override string bcasStatementBeforeWaiting(size_t currThread, string mem, string val){
		return assertVraVsc(currThread, mem);
	}
	pure override string bcasStatementBefore(size_t currThread, string mem){
		return updateRmwStatement(currThread, mem);
	}
	pure override string casStatementBefore(size_t currThread, string mem, string expr){
		return "skip;";
	}
	pure override string casStatementBeforeRead(size_t currThread, string mem, string expr){
		string result = assertVraVsc(currThread, mem);
		return result ~ updateLoadStatement(currThread, mem);
	}
	pure override string casStatementBeforeUpdate(size_t currThread, string mem, string expr){
		string result = assertVrauVsc(currThread, mem);
		return result ~ updateLoadStatement(currThread, mem);
	}
	pure override string rmwStatementBefore(size_t currThread, string mem){
		auto result = assertVrauVsc(currThread, mem);
		return result ~ updateRmwStatement(currThread, mem);
	}

	string updateLoadStatement(size_t currThread, in string mem, in ref string other) pure {
		string result;
		if (mem == other) {
			result ~= getVRA(currThread, mem) ~ " = 1;\n";
			result ~= getVRAU(currThread, mem) ~ " = 1;\n";
		} else {
			result ~= "%1$s = %1$s | %2$s;\n".format(getVRA(currThread, other), getMRA(mem, other));
			result ~= "%1$s = %1$s | %2$s;\n".format(getVRAU(currThread, other), getMRAU(mem, other));
		}
		return result;
	}

	string updateLoadStatement(size_t currThread, string mem) pure {
		string result;
		result ~= vsc.updateLoadStatement(currThread, mem);
		// Thread learns from MEM
		foreach (ref other; globals){
			result ~= updateLoadStatement(currThread, mem, other);
		}
		return result;
	}

	string updateStoreStatement(size_t currThread, string mem) pure {
		string result;
		result ~= vsc.updateStoreStatement(currThread, mem);

		// Every thread forget MEM, current thread learns MEM
		// (Thread)(Location)
		// MEM learns about changes in thread
		result ~= updateStoreStatementMem(currThread, mem);
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
				result ~= getVRA(i, mem) ~ " = 1;\n";
				result ~= getVRAU(i, mem) ~ " = 1;\n";
			} else {
				result ~= getVRA(i, mem) ~ " = 0;\n";
				result ~= getVRAU(i, mem) ~ " = 0;\n";
			}
		}
		// Other locations forget MEM
		// (Other)(Mem)
		foreach (ref other; globals) {
			if (other == mem) continue;
			result ~= getMRA(other, mem) ~ " = 0;\n";
			result ~= getMRAU(other, mem) ~ " = 0;\n";
		}
		return result;
	}
	string updateStoreStatementOther(size_t currThread, string mem, string other) pure{
		string result;
		if (other == mem) return "";
		result ~= "%1$s = %1$s || %2$s;\n".format(getMRA(mem, other), getVRA(currThread, other));
		result ~= "%1$s = %1$s || %2$s;\n".format(getMRAU(mem, other), getVRA(currThread, other));
		return result;
	}

	string updateRmwStatement(size_t currThread, string mem) pure {
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
				result ~= "%s = 0;\n".format(getVRA(i, mem));
			}
		}
		foreach (ref other; globals){
			if (mem == other) {
				result ~=  "%s = 1;\n".format(getVRA(currThread, mem));
				result ~=  "%s = 1;\n".format(getVRAU(currThread, mem));
			} else {
				// (Other)(Mem)
				result ~= "%1$s = 0;\n".format(getMRA(other, mem));
			}
		}
		return result;
	}
	string updateRmwStatementOther(size_t currThread, string mem, string other) pure{
		string result;
		if (mem == other) return "";
		// (Mem)(Other)
		// (currThread)(Other)
		result ~= "%1$s = %1$s | %2$s;\n".format(getVRA(currThread, other), getMRA(mem, other));
		result ~= "%1$s = %1$s | %2$s;\n".format(getMRA(mem, other), getVRA(currThread, other));
		result ~= "%1$s = %1$s | %2$s;\n".format(getVRAU(currThread, other), getMRAU(mem, other));
		result ~= "%1$s = %1$s | %2$s;\n".format(getMRAU(mem, other), getVRAU(currThread, other));
		return result;
	}

	/**
	  Generate line for asserting if x \in VSC then x \in VRA

	  Params:
	  thread = The VRA/VSC thread
	  loc = the memory location, x
	  Returns: the assert message
	 **/
	string assertVraVsc(size_t thread, const ref string loc) @safe pure {
		return "assert(%s >= %s);\n".format(getVRA(thread, loc), getVSC(thread, loc));
	}
	/**
	  Generate line for asserting if x \in VSC then x \in VRAU

	  Params:
	  thread = The VRAU/VSC thread
	  loc = the memory location, x
	  Returns: the assert message
	 **/
	string assertVrauVsc(size_t thread, const ref string loc) @safe pure {
		return "assert(%s >= %s);\n".format(getVRAU(thread, loc), getVSC(thread, loc));
	}

	pure override string[string] getLocals(){
		return null;
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
