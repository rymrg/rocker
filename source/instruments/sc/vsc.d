module instruments.sc.vsc;
import instruments.utils;

import std.string : format;
import std.range : iota;
import std.conv : to;

mixin GetVarName!("size_t", "VSC");
mixin GetVarName!("string", "MSC");
mixin GetVarName!("string", "MSCW");

package(instruments){
	@safe class Vsc{
		pure this(const string[] _vars, size_t _threads){
			globals = _vars;
			threads = _threads;
		}
		const string[] globals;
		size_t threads;

		pure string initializeMemoryMetadata(){
			string result;
			foreach (i ; iota(threads)){
				foreach (ref s; globals){
					result ~= "bit " ~ getVSC(i,s) ~ " = 1;\n";
				}
			}
			foreach (ref from ; globals){
				foreach (ref to; globals){
					if (from != to) {
						result ~= "bit " ~ getMSC(from,to) ~ ";\n";
						result ~= "bit " ~ getMSCW(from,to) ~ ";\n";
					}
				}
			}
			result ~= "\n";
			return result;
		}

		pure string updateLoadStatement(size_t currThread, string mem){
			string result;
			// Thread learns from MEM
			foreach (ref other; globals){
				if (mem == other) {
					result ~= getVSC(currThread, mem) ~ " = 1;\n";
				} else {
					result ~= "%1$s = %1$s || %2$s;\n".format(getMSC(mem, other), getVSC(currThread, other));
					result ~= "%1$s = %1$s || %2$s;\n".format(getVSC(currThread, other), getMSCW(mem, other));
				}
			}
			return result;
		}
		pure string updateStoreStatement(size_t currThread, string mem){
			string result;

			// Every thread forget MEM, current thread learns MEM
			// (Thread)(Location)
			foreach (i; iota(threads)){
				if (i == currThread) {
					result ~= getVSC(i, mem) ~ " = 1;\n";
				} else {
					result ~= getVSC(i, mem) ~ " = 0;\n";
				}
			}
			// MEM learns about changes in thread
			// (Mem)(Other)
			foreach (ref other; globals) {
				if (other == mem) continue;
				result ~= "%1$s = %1$s || %2$s;\n".format(getVSC(currThread, other), getMSC(mem, other));
				result ~= "%s = %s || %s;\n".format(getMSCW(mem, other), getVSC(currThread, other), getMSC(mem, other));
				result ~= "%1$s = %1$s || %2$s;\n".format(getMSC(mem, other), getVSC(currThread, other));
			}
			// Other locations forget MEM
			// (Other)(Mem)
			foreach (ref other; globals) {
				if (other == mem) continue;
				result ~= getMSCW(other, mem) ~ " = 0;\n";
				result ~= getMSC(other, mem) ~ " = 0;\n";
			}
			return result;
		}

		pure string updateRmwStatement(size_t currThread, string mem){
			string result;
			// Thread learns from MEM
			// Memory learns from thread
			foreach (ref other; globals){
				if (mem == other) {
					result ~=  "%s = 1;\n".format(getVSC(currThread, mem));
				} else {
					result ~= "%s = %s | %s;\n".format(getVSC(currThread, other), getVSC(currThread, other), getMSC(mem, other));
					result ~= "%s = %s | %s;\n".format(getMSCW(mem, other), getVSC(currThread, other), getMSC(mem, other));
					result ~= "%s = %s | %s;\n".format(getMSC(mem, other), getVSC(currThread, other), getMSC(mem, other));

					// Other SC memory forget MEM
					result ~= "%s = 0;\n".format(getMSCW(other, mem));
					result ~= "%s = 0;\n".format(getMSC(other, mem));
				}
			}
			// Other threads forget about MEM in SC
			// (Thread)(Mem)
			foreach (i; iota(threads)){
				if (i != currThread) {
					result ~= "%s = 0;\n".format(getVSC(i, mem));
				}
			}
			return result;
		}
	}
}
