module instruments.ra.allornothing;
version (none){
import instruments.instrument;
import instruments.utils;
import instruments.ra.vsc;
import instruments.ra.value;
import instruments.ra.vra;

import std.string : format;
import std.range : iota;

import pegged.grammar;

pure @safe class AllOrNothing : Instrument{
	const string[] globals;
	size_t threads;
	string moduloNumber;
	bool[string] trackedVariables;
	Vsc vsc;
	Vra vra;
	Value value;
	pure this(const string[] _vars, size_t _threads, string _moduloNumber, const ref ParseTree p){
		globals = _vars.dup;
		threads = _threads;
		moduloNumber = _moduloNumber;
		vsc = new Vsc(globals, threads);
		vra = new Vra(globals, threads);
		value = new Value(globals, _threads, _moduloNumber);

		// Locks should track value 0
		foreach (lock; findLocks(p)){
			trackedVariables[lock] = true;
		}
		foreach (var; findVariablesForAll(p)){
			trackedVariables[var] = true;
		}
	}

	pure override string initializeMemoryMetadata(){
		string result;
		result ~= vsc.initializeMemoryMetadata();
		foreach (ref to; globals){
			if (to in trackedVariables){
				result ~= value.initializeMemoryMetadata(to);
			} else {
				result ~= vra.initializeMemoryMetadata(to);
			}
		}
		result ~= "\n";
		return result;
	}


	/**
	  Finds variables that should be tracked

	  Currently only tracks from BCAS and Lock automatically

	  Params:
	  p = ParseTree of the program

	  Returns:
	  Variables that must be tracked
	  */
	string[] findVariablesForAll(const ref ParseTree p) pure nothrow{
		string[] result;
		switch (p.name){
			case "Tpl.CAS":
			case "Tpl.WaitStatement":
			case "Tpl.BCASStatement":
				result ~= p.matches[0];
				break;
			case "Tpl.LockStatement":
				result ~= p.children[0].matches[0];
				break;
			default:
				foreach (pc ; p.children){
					result ~=findVariablesForAll(pc);
				}
				break;
		}
		return result;
	}

	pure override string storeStatementBefore(size_t currThread, string mem){
		string result;
		if (mem in trackedVariables){
			result ~= value.assertVscMemU(currThread, mem);
		} else {
			result ~= vra.assertVrauVsc(currThread, mem);
		}
		result ~= updateStoreStatement(currThread, mem);
		return result;
	}
	pure override string loadStatementBefore(size_t currThread, string mem){
		string result;
		if (mem in trackedVariables){
			result ~= value.assertVscMemR(currThread, mem);
		} else {
			result ~= vra.assertVraVsc(currThread, mem);
		}
		result ~= updateLoadStatement(currThread, mem);
		return result;
	}
	pure override string waitStatementAfterWaiting(size_t currThread, string mem){
		return updateLoadStatement(currThread, mem);
	}
	pure override string waitStatementBeforeWaiting(size_t currThread, string mem, string[] vals){
		if (mem in trackedVariables){
			return value.waitStatementBeforeWaiting(currThread, mem, vals);
		} else {
			return vra.waitStatementBeforeWaiting(currThread, mem, vals);
		}
	}
	pure override string bcasStatementBeforeWaiting(size_t currThread, string mem, string expBefore){
		if (mem in trackedVariables){
			return value.bcasStatementBeforeWaiting(currThread, mem, expBefore);
		} else {
			return vra.bcasStatementBeforeWaiting(currThread, mem, expBefore);
		}
	}
	pure override string bcasStatementBefore(size_t currThread, string mem){
		return updateRmwStatement(currThread, mem);
	}
	pure override string casStatementBefore(size_t currThread, string mem, string expr){
		string result;
		if (mem in trackedVariables){
			result ~= value.casStatementBefore(currThread, mem, expr);
		} else {
			result ~= vra.casStatementBefore(currThread, mem, expr);
		}
		return result;
	}
	pure override string casStatementBeforeRead(size_t currThread, string mem, string expr){
		string result;
		if (mem in trackedVariables){
			result ~= updateLoadStatement(currThread, mem);
		} else {
			result ~= vra.assertVraVsc(currThread, mem);
			result ~= updateLoadStatement(currThread, mem);
		}
		return result;
	}
	pure override string casStatementBeforeUpdate(size_t currThread, string mem, string expr){
		string result;
		if (mem in trackedVariables){
			result ~= updateRmwStatement(currThread, mem);
			result ~= value.casStatementBefore(currThread, mem, expr);
		} else {
			result ~= vra.assertVrauVsc(currThread, mem);
			result ~= updateRmwStatement(currThread, mem);
		}
		return result;
	}
	pure override string rmwStatementBefore(size_t currThread, string mem){
		string result;
		if (mem in trackedVariables){
			result ~= value.assertVscMemU(currThread, mem);
		} else {
			result ~= vra.assertVrauVsc(currThread, mem);
		}
		result ~= updateRmwStatement(currThread, mem);
		return result;
	}
	string updateLoadStatement(size_t currThread, in string mem) pure {
		string result;
		result ~= vsc.updateLoadStatement(currThread, mem);
		// Thread learns from MEM
		foreach (ref other; globals){
			if (other in trackedVariables){
				result ~= value.updateLoadStatement(currThread, mem, other);
			} else {
				result ~= vra.updateLoadStatement(currThread, mem, other);
			}
		}
		return result;
	}
	string updateStoreStatement(size_t currThread, string mem) pure {
		string result;
		result ~= vsc.updateStoreStatement(currThread, mem);

		// Every thread forget MEM, current thread learns MEM
		// (Thread)(Location)
		if (mem in trackedVariables){
			result ~= value.updateStoreStatementMem(currThread, mem);
		} else {
			result ~= vra.updateStoreStatementMem(currThread, mem);
		}
		// MEM learns about changes in thread
		// (Mem)(Other)
		foreach (ref other; globals) {
			//if (other == mem) continue;
			if (other in trackedVariables){
				result ~= value.updateStoreStatementOther(currThread, mem, other);
			} else {
				result ~= vra.updateStoreStatementOther(currThread, mem, other);
			}

		}
		return result;
	}
	string updateRmwStatement(size_t currThread, string mem) pure {
		string result;
		result ~= vsc.updateRmwStatement(currThread, mem);

		if (mem in trackedVariables){
			result ~= value.updateRmwStatementMem(currThread, mem);
		} else {
			result ~= vra.updateRmwStatementMem(currThread, mem);
		}
		// Thread learns from MEM
		// Memory learns from thread
		foreach (ref other; globals){
			if (mem == other) continue;
			// (Mem)(Other)
			// (currThread)(Other)
			if (other in trackedVariables){
				result ~= value.updateRmwStatementOther(currThread, mem, other);
			} else {
				result ~= vra.updateRmwStatementOther(currThread, mem, other);
			}
		}
		return result;
	}

	pure override string[string] getLocals(){
		return value.getLocals();
	}

	override string naLoadStatementBefore(size_t currThread, string mem){
		import std.exception : enforce;
		enforce(false, "Mode does not support non atomic access");
	}
	override string naStoreStatementBefore(size_t currThread, string mem){
		import std.exception : enforce;
		enforce(false, "Mode does not support non atomic access");
	}
}
}
