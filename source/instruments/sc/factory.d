module instruments.sc.factory;

import instruments.instrument;
import instruments.config;

import std.conv : to, ConvException;

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
		return "";
	}
	override string storeStatementBefore(size_t currThread, string mem) @safe pure nothrow @nogc {
		return skip;
	}
	override string loadStatementBefore(size_t currThread, string mem) @safe pure nothrow @nogc {
		return skip;
	}
	override string waitStatementAfterWaiting(size_t currThread, string mem) @safe pure nothrow @nogc {
		return skip;
	}
	override string waitStatementBeforeWaiting(size_t currThread, string mem, string[] vals) @safe pure nothrow @nogc {
		return skip;
	}
	override string bcasStatementBeforeWaiting(size_t currThread, string mem, string val) @safe pure nothrow @nogc {
		return skip;
	}
	override string bcasStatementBefore(size_t currThread, string mem) @safe pure nothrow @nogc {
		return skip;
	}
	override string casStatementBefore(size_t currThread, string mem, string expr) @safe pure nothrow @nogc {
		return skip;
	}
	override string casStatementBeforeRead(size_t currThread, string mem, string expr) @safe pure nothrow @nogc {
		return skip;
	}
	override string casStatementBeforeUpdate(size_t currThread, string mem, string expr) @safe pure nothrow @nogc {
		return skip;
	}
	override string rmwStatementBefore(size_t currThread, string mem) @safe pure nothrow @nogc {
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

	override string[string] getLocals() @safe pure nothrow @nogc {
		return null;
	}
}
