module instruments.lib.vsc.memory;

package (instruments){
/// Mixin common operations for tracking paths similar to VSC
mixin template MemoryOps(){
	/**
	  Make aware of last write (and forget every other stale write)

	  Params:
	  var = Tracked Variable
	  fst = Whose Knowledge
	  loc = Which location should be learnt

	  Returns:
	  Var[fst][loc] = \emptyset
	 */
	string clearViewMem(string var, T)(T fst, string loc) @safe pure {
		mixin("auto getVar = &get%s;".format(var));
		mixin("auto getVarC = &get%sC;".format(var));
		string result;
		foreach (v ; trackedVariablesValues[loc].byKey){
			result ~= "%1$s = 0;\n".format(getVar(fst, loc, v));
		}
		result ~= "%1$s = 0;\n".format(getVarC(fst, loc));
		return result;
	}

	/**
	  Make a location learn everything from another location (specific location)

	  Params:
	  lhsVar = Tracking Variable type (Left)
	  rhsVar = Tracking Variable type (Right)
	  lhsFst = Whose knowledge should be updated
	  rhsFst = Whose knowledge should be taken
	  loc = Location

	  Returns:
	  Code to intersect view, T[x][loc] \cap= U[y][loc]
	  */
	string intersectViewMemLeft(string lhsVar, string rhsVar, T, U)(T lhsFst, U rhsFst, string loc) @safe pure {
		mixin("auto getLhsVar = &get%s;".format(lhsVar));
		mixin("auto getLhsVarC = &get%sC;".format(lhsVar));
		mixin("auto getRhsVar = &get%s;".format(rhsVar));
		mixin("auto getRhsVarC = &get%sC;".format(rhsVar));
		string result;
		foreach (v ; trackedVariablesValues[loc].byKey){
			result ~= "%1$s = %1$s && %2$s;\n".format(getLhsVar(lhsFst, loc, v), getRhsVar(rhsFst, loc, v));
		}
		result ~= "%1$s = %1$s && %2$s;\n".format(getLhsVarC(lhsFst, loc), getRhsVarC(rhsFst, loc));
		return result;
	}

	/**
	  Make a location learn everything from another location

	  Params:
	  lhsVar = Tracking Variable type (Left)
	  rhsVar = Tracking Variable type (Right)
	  lhsFst = Whose knowledge should be updated
	  rhsFst = Whose knowledge should be taken
	  locs = Locations to learn about

	  Returns:
	  Code to intersect view, \forall loc \in locs: T[x][loc] \cap= U[y][loc]

	  Bugs:
		Assumes T[x][x] is an invariant and does not change it
	  */
	string intersectViewMemLeft(string lhsVar, string rhsVar, T, U)(T lhsFst, U rhsFst, in string[] locs) @safe pure {
		string result;
		foreach (l; locs){
			static if (is(T == string)) {
				if (l == lhsFst){
					continue;
				}
			}
			static if (is(U == string)) {
				if (l == rhsFst){
					continue;
				}
			}
			result ~= intersectViewMemLeft!(lhsVar, rhsVar)(lhsFst, rhsFst, l);
		}
		return result;
	}

	/** 
	  Make tracking locations forget about last write to loc

	  Params:
	  vars = Tracking variables to forget
	  fst = Who should forget
	  loc = Location to forget

	  Returns:
	  Promela code to make vars[fst] forget about loc
	  */
	string makePlacesForgetLastWriteLoc(string[] vars, T)(T fst, string loc){
		mixin(q{auto getVar = [%-(&get%s, %)];}.format(vars));
		mixin(q{auto getVarC =[%-(&get%sC%|, %)];}.format(vars));
		string result;
		result ~= "if\n";
		foreach (v ; trackedVariablesValues[loc].byKey){
			auto targets = getVar.map!(f => f(fst, loc, v));
			result ~= ":: (%s == %s) -> { %-(%s = 1; %|%) }\n".format(loc, v, targets);
		}
		auto targetsC = getVarC.map!(f => f(fst, loc));
		result ~= ":: else -> { %-(%s = 1; %|%) }\n".format(targetsC);
		result ~= "fi;\n";
		return result;
	}

	/**
	  Clones view of tracking variables (specific location)

	  Params:
	  lhsVar = Tracking Variable type (Left)
	  rhsVar = Tracking Variable type (Right)
	  lhsFst = Whose knowledge should be updated
	  rhsFst = Whose knowledge should be taken
	  loc = Location

	  Returns:
	  Code to clone view, T[x][loc] = U[y][loc]
	  */
	string cloneViewMem(string lhsVar, string rhsVar, T, U)(T lhsFst, U rhsFst, string loc) @safe pure {
		mixin("enum getLhsVar = &get%s;".format(lhsVar));
		mixin("enum getLhsVarC = &get%sC;".format(lhsVar));
		mixin("enum getRhsVar = &get%s;".format(rhsVar));
		mixin("enum getRhsVarC = &get%sC;".format(rhsVar));
		string result;
		foreach (v ; trackedVariablesValues[loc].byKey){
			result ~= "%1$s = %2$s;\n".format(getLhsVar(lhsFst, loc, v), getRhsVar(rhsFst, loc, v));
		}
		result ~= "%1$s = %2$s;\n".format(getLhsVarC(lhsFst, loc), getRhsVarC(rhsFst, loc));
		return result;
	}

	/**
	  Clones view of tracking variables

	  Params:
	  lhsVar = Tracking Variable type (Left)
	  rhsVar = Tracking Variable type (Right)
	  lhsFst = Whose knowledge should be updated
	  rhsFst = Whose knowledge should be taken
	  locs = Array of Locations

	  Returns:
	  Code to clone view, \forall loc \in locs: T[x][loc] = U[y][loc]
	  */
	string cloneViewMem(string lhsVar, string rhsVar, T, U)(T lhsFst, U rhsFst, in string[] locs) @safe pure {
		string result;
		foreach (l; locs){
			static if (is(T == string)) {
				if (l == lhsFst) continue;
			}
			static if (is(U == string)) {
				if (l == rhsFst){
					continue;
				}
			}
			result ~= cloneViewMem!(lhsVar, rhsVar)(lhsFst, rhsFst, l);
		}
		return result;
	}

}
}
