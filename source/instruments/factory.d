module instruments.factory;

import instruments.instrument;
import instruments.config;

import Rlx = instruments.rlx.factory;
import Ra = instruments.ra.factory;
import Sc = instruments.sc.factory;

import std.conv : to, ConvException;

public enum MemoryModel { rlx, ra, sc };

/**
  Factory for Instruments

  This factory passes the configuration to the correct factory based on memory model
  */
@safe struct Factory{
	pure static Instrument getInstrument(string memoryModel, string mode, Config config = Config()){
		MemoryModel mm;
		try{
			mm = memoryModel.to!MemoryModel;
			return getInstrument(mm, mode, config);
		} catch (ConvException)
		return null;
	}

	pure static Instrument getInstrument(MemoryModel mm, string mode, Config config = Config()){
		final switch (mm) with (MemoryModel){
			case rlx:
				return Rlx.Factory.getInstrument(mode, config);
			case ra:
				return Ra.Factory.getInstrument(mode, config);
			case sc:
				return Sc.Factory.getInstrument(mode, config);
		}
	}

	pure static string listInstruments(){
		import std.array : join;
		string m = [
			Sc.Factory.listInstruments,
			Ra.Factory.listInstruments,
			Rlx.Factory.listInstruments,
				].join("\n");
		return m;
	}
}

