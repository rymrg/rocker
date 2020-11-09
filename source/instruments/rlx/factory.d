module instruments.rlx.factory;

import instruments.instrument;
import instruments.config;
import instruments.rlx.register;

import std.typecons : tuple, Tuple;
import std.exception : assumeUnique;
import std.format: format;


private static immutable Tuple!(Make,string)[const string] _factories;
shared static this(){
	// Ugly hack to circumvent the type system as order of shared static cannot be guaranteed.
	factories["a__"] = tuple(Make.init,"");
	factories.remove("a__");
	_factories = cast(immutable)factories;
}
@safe struct Factory{
	
	@trusted static pure Instrument getInstrument(string smode, Config config = Config()){
		if (const inst1 = smode in _factories){
			const inst2 = *inst1;
			const inst = inst2[0];
			return inst(config);
		}
		return null;
	}


	/**
	  Returns a string with available instrumentations for the given module.

	  Returns:
	  	The string
	  **/
	pure static string listInstruments(){
		string result = "Memory Model rlx\n";
		foreach (k,v; _factories){
			result ~= "\t\t\t%s \t%s\n".format(k,v[1]);
		}
		return result;
	}
}
