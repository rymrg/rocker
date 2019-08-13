module instruments.ra.factory;

import instruments.instrument;
import instruments.config;

import instruments.ra.value;
import instruments.ra.vra;
import instruments.ra.allornothing;
import instruments.ra.tracksome;

import std.conv : to, ConvException;

enum VerificationMode { trackSome, value, vra };

@safe struct Factory{
	pure static Instrument getInstrument(string smode, Config config = Config()){
		VerificationMode mode;
		try{
			mode = smode.to!VerificationMode;
			return getInstrument(mode, config);
		} catch (ConvException)
		return null;
	}

	pure static Instrument getInstrument(VerificationMode mode, Config config = Config()){
		with (config){
			final switch (mode) with (VerificationMode){
				case value:
					return new Value(vars, naVars, threads, moduloNumber);
				case vra:
					return new Vra(vars, naVars, threads);
				// case allOrNothing:
				// 	return new AllOrNothing(vars, threads, moduloNumber, parseTree);
				case trackSome:
					return new TrackSome(vars, naVars, threads, moduloNumber, parseTree);
			}
		}
	}

	pure static @nogc string listInstruments(){
		return "Memory Model ra
			trackSome \tTrack only some values for some variables
			vra \tDon't track values
			value \tTrack all values for all variables"
;
	}
}

