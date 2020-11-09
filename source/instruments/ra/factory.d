module instruments.ra.factory;

import instruments.instrument;
import instruments.config;

import instruments.ra.tracksome;

import std.conv : to, ConvException;

enum VerificationMode { trackSome, };

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
				case trackSome:
					return new TrackSome(vars, naVars, threads, moduloNumber, parseTree);
			}
		}
	}

	pure static @nogc string listInstruments(){
		return "Memory Model ra
			trackSome \tTrack only some values for some variables"
;
	}
}

