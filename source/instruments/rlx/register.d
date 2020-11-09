module instruments.rlx.register;

import std.typecons : tuple, Tuple;
import instruments.instrument;
import instruments.config;

alias Make = @safe pure Instrument function(Config);
package static Tuple!(Make,string)[const string] factories;
package mixin template register(){
	@safe shared static this() { 
		assert(name !in factories, "Cannot add %s to factories as an item with the same name already exist".format(name));
		factories[name] = tuple(&make, desc); 
	}
}

static this(){
	// Keep the promise about not keeping a mutable reference by normal runtime
	factories = null;
}
