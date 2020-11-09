module instruments.sc.factory;

import instruments.instrument;
import instruments.config;
import instruments.access;

import std.conv : to, ConvException;
import std.typecons;

@safe struct Factory{
	pure static Instrument getInstrument(string smode, Config config = Config()){
		return new Sc();
	}
	pure static @nogc string listInstruments(){
		return "Memory Model sc
			none \tNo instrumentation";
	}
}

class Sc : Instrument{
	enum skip = "skip;\n";
	override string initializeMemoryMetadata() @safe pure nothrow @nogc {
		return null;
	}
	override string storeStatementBefore(size_t currThread, string mem, StoreType) @safe pure nothrow @nogc {
		return skip;
	}
	override string loadStatementBefore(size_t currThread, string mem, string, LoadType) @safe pure nothrow @nogc {
		return skip;
	}
	override string waitStatementAfterWaiting(size_t currThread, string mem, LoadType) @safe pure nothrow @nogc {
		return skip;
	}
	override string waitStatementBeforeWaiting(size_t currThread, string mem, string[] vals) @safe pure nothrow @nogc {
		return skip;
	}
	override string bcasStatementBeforeWaiting(size_t currThread, string mem, string val) @safe pure nothrow @nogc {
		return skip;
	}
	override string bcasStatementBefore(size_t currThread, string mem, LoadType, StoreType) @safe pure nothrow @nogc {
		return skip;
	}
	override string casStatementBefore(size_t currThread, string mem, string expr) @safe pure nothrow @nogc {
		return skip;
	}
	override string casStatementBeforeRead(size_t currThread, string mem, string expr, LoadType) @safe pure nothrow @nogc {
		return skip;
	}
	override string casStatementBeforeUpdate(size_t currThread, string mem, string expr, LoadType, StoreType) @safe pure nothrow @nogc {
		return skip;
	}
	override string rmwStatementBefore(size_t currThread, string mem, string, LoadType, StoreType) @safe pure nothrow @nogc {
		return skip;
	}

	override string naStoreStatementBeforeAtomic(size_t currThread, string mem) @safe pure nothrow @nogc {
		return skip;
	}
	override string naStoreStatementBefore(size_t currThread, string mem) @safe pure nothrow @nogc {
		return skip;
	}
	override string naLoadStatementBefore(size_t currThread, string mem) @safe pure nothrow @nogc {
		return skip;
	}

	override string[string] getLocals(size_t) @safe pure nothrow @nogc {
		return null;
	}

	override Tuple!(bool, string) fence(size_t, FenceType){
		//return Tuple!(bool, string)(false, null);
		return typeof(return)(true, skip);
	}

	override string verifyLocal(size_t currThread, string var) const pure nothrow @nogc {
		return null;
	}
	override string cleanLocal(size_t currThread, string var) const pure nothrow @nogc {
		return null;
	}

	override string transetiveTaint(size_t, in string, in string[]) const pure nothrow @nogc {
		return null;
	}

}
