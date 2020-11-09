/**
  A program for testing RA strong robustness using Spin
 **/
import std.stdio;
import std.range : iota, zip, repeat;
import std.algorithm : uniq, sort, equal, any;
import std.algorithm.iteration : filter, map, joiner;
import std.algorithm.searching : find;
import std.algorithm.setops : setIntersection;
import std.range : walkLength;
import std.string : format, join;
import std.conv : to;
import std.getopt;
import std.file : isFile, exists, readText, writeFile = write;
import std.path : dirName;
import pegged.grammar;
import std.exception : assumeWontThrow, enforce;
import peg;
import std.array : assocArray, array, empty;

import instruments;

enum upperLimitValue = 255;
enum moduloNumberPre = upperLimitValue.to!string;
auto moduloNumber = moduloNumberPre;

int main(string[] args)
{
	// Get options
	string ifile; // Input file
	string ofile = "-"; // Input file
	bool debuginfo;
	bool printInstruments;
	string verificationMode = "trackSome";
	MemoryModel memoryModel = MemoryModel.ra;

	try{
		static import std.traits;
		auto helpInformation = getopt(
				args,
				"in|i", "tpl program to spinify", &ifile,
				"out|o", "Output promela file", &ofile,
				"debug|d", "Print debug info", &debuginfo,
				"mode|m", "Verification Mode",  &verificationMode,
				"memory", "Memory Model", &memoryModel,
				"list-instruments", "Print list of memory models and modes", &printInstruments,
				);
		if (helpInformation.helpWanted){
			enum helpMessage = format("Tpl\n\n" ~
					"Convert your tpl programs to promela. Then check with spin to see if they are graph robust against RA semantics");
			defaultGetoptPrinter(helpMessage, helpInformation.options);
			return 0;
		}
	} catch(GetOptException e) {
		stderr.writeln("Error parsing arguments: ", e.msg);
		return -1;
	} catch(std.conv.ConvException e) {
		stderr.writeln("Error parsing arguments: ", e.msg);
		return -1;
	}
	
	if (printInstruments){
		writeln("Available Instruments:\n\n", Factory.listInstruments);
		return 0;
	}


	// Verify input file exists
	if (ifile.empty) {
		stderr.writeln("You need to provide an input file");
		return -1;
	} else if (!exists(ifile)) {
		stderr.writefln("%s does not exist.", ifile);
		return -1;
	} else if (!isFile(ifile)) {
		stderr.writefln("%s is not a file.", ifile);
		return -1;
	}
	string contents = ifile.readText;
	auto tree = Tpl(contents);
	if (debuginfo)
		stderr.writeln(tree);
	{
		import std.string : strip;
		if (!contents[tree.end .. $].strip.empty){
			stderr.writefln("%s Failed to parse entire program", ifile);
			stderr.writeln(contents[tree.end .. $]);
			return -1;
		}
	}
	auto config = getConfigForTree(tree);
	auto instrument = Factory.getInstrument(memoryModel.to!string, verificationMode.to!string, config);
	assert (instrument, "No instrument provided by factory");
	auto promela = toPromela(tree, instrument, config);
	if (!ofile.empty && ofile != "-"){
		if (exists(dirName(ofile))){
			ofile.writeFile(promela);
		} else {
			stderr.writefln("path to %s does not exist", ofile);
			return -1;
		}
	} else {
		writeln(promela);
	}

	return 0;
}

/** 
  Generate Configuration for program

  Params:
  p = ParseTree of program

  Returns:
  Conifguration for instrument
  */

Config getConfigForTree(ref const ParseTree p) pure @safe{
	import std.algorithm : map, find, filter;
	import std.range : walkLength;
	Config config = {parseTree: p};
	// Assume Tpl -> Program
	auto t = p.children[0];
	config.moduloNumber = moduloNumberPre;
	auto maxValNode = t.children.find!(a=>a.name == "Tpl.MaxValue");
	if (!maxValNode.empty){
		import std.conv : to;
		auto moduloNumber = maxValNode[0].matches.join;
		auto d = moduloNumber.to!int;
		enforce(d<= upperLimitValue, "Max Value %d is higher than allowed limit %d".format(d, upperLimitValue));
		enforce(d>=1, "Max Value is too low");
		++d;
		config.moduloNumber = d.to!string;
	}

	auto gpa = t.children.find!(a=>a.name == "Tpl.Globals");
	enforce(gpa.length > 0, "No globals");

	auto globals = gpa[0].children.map!(a=>a.matches[0]).array;

	globals ~= fenceGlobal;
	config.vars = globals;

	auto nap = t.children.find!(a=>a.name == "Tpl.NotAtomic");
	if (nap.length > 0){
		auto na = nap[0].children.map!(a=>a.matches[0]).array;
		config.naVars = na;
	}

	config.threads = t.children.filter!(a=>a.name == "Tpl.Function").walkLength;

	pure @safe const(string)[] extractVars(const ref ParseTree p)  {
		string[] locals;
		if (p.children[1].name == "Tpl.Variables"){
			locals = p.children[1].matches.dup.array;
			locals.sort;
		} else {
			// No local variables
			locals = [];
		}
		locals ~= [fenceVar, lockVar];
		return locals;
	}
	config.locals = zip(config.threads.iota, t.children.filter!(a=>a.name == "Tpl.Function").map!extractVars).assocArray;
	return config;
}

/**
  Append modulo operation to expression

  Params:
  s = String expression

  Returns:
  The string with modulo operation
 */
string appendModulo(string s) @safe{
	return "((" ~ s ~ ") %" ~ moduloNumber ~ ")";
}

enum fenceGlobal = "__FGlob";
enum endLabel = "__END";
enum fenceVar = "__F";
enum lockVar = "__L";
enum sysVar = "__S"; // Syscalls / print / while / if...

/**
  Convert the PEG tree to Promela code.
  This adds meta variables as needed to store / load procedures.
  This allows to test strong robustness of RA program in Spin.

  Params:
  p = Valid parse tree
  verificationMode = Mode of verification
  Returns: Promela code matching the program
 **/
string toPromela(ref ParseTree p, Instrument instrument, const ref Config config) @safe
{
	/**
	  Initalize variables

	  Params:
	  strings = An array of variable names used in the program
	  Returns: Spin code that initializes the variables at the scope.
	 **/
	string initializeVariables(in string[] strings) @safe pure nothrow{
		string result;
		foreach (ref s; strings){
			result ~= "byte " ~ s ~ " = 0;\n";
		}
		result ~= "\n";
		return result;
	}

	/**
	  Initalize variables with initial value

	  Params:
	  strings = A dictionary of strings and their initial value
	  Returns: Spin code that initializes the variables at the scope.
	 **/
	string initializeVariablesWithValue(in size_t[string] strings) @safe pure nothrow{
		string result;
		if (strings != null){
			try{
				foreach (ref s, n; strings){
					assumeWontThrow(result ~= "byte %s = %s;\n".format(s, n), "Globals can't be parsed");
				}
				result ~= "\n";
			} catch (Exception e) {
				result = "// Globals failed to parse\n";
			}
		}
		return result;
	}

	/// Global variables in the program
	bool[const(string)] globalsSet;
	/// Non Atomic Global variables in the program
	bool[const(string)] naGlobalsSet;
	/// Local variables in current scope
	string[] locals;
	/// Functions in the program
	string[] functions;
	/// Amount of threads in the program
	size_t threads;
	/// Current thread being processed
	size_t currThread;
	/// String containing the entire result
	string result;
	/// Counter for locks
	uint lockCounter = 0;
	/// Counter for asserts
	uint assertCounter = 0;

	string getLockLabel(){
		return "__lock_%d".format(++lockCounter);
	}
	string getAssertVariableLocal(){
		return "__assertion_var"; //.format(++assertCounter);
	}

	/**
	  Check if a global exists within expression

	  Params:
	  p = ParseTree
	  Returns: True if a global identifier is found in expression.
	 **/
	bool globalInExpression(ref ParseTree p) pure @safe nothrow{
		if (p.name == "Tpl.Identifier")
			if (p.matches[0] in globalsSet)
				return true;
		return p.children.any!globalInExpression;
	}

	/**
	  Check if a global non atomic exists within expression

	  Params:
	  p = ParseTree
	  Returns: True if a global non atomic identifier is found in expression.
	 **/
	bool naGlobalInExpression(ref ParseTree p) pure @safe nothrow{
		if (p.name == "Tpl.Identifier")
			if (p.matches[0] in naGlobalsSet)
				return true;
		return p.children.any!naGlobalInExpression;
	}

	/**
	  Returns identifiers used in expression

	  Params:
	  p = ParseTree
	  Returns: identifiers used in an expression
	 **/
	const(string)[] identifiersInExpression(ref ParseTree p) pure @safe nothrow{
		//import std.container : DList;
		string[] result;
		const(ParseTree)[] s;
		s ~= p;
		while (!s.empty){
			const curr = s[$-1];
			s = s[0 .. $-1];
			if (curr.name == "Tpl.Identifier"){
				result ~= [curr.matches[0]];
				continue;
			} else {
				s ~= curr.children;
				//q.insertBack(curr.children);
			}

		}
		return result.sort.uniq.setIntersection(config.locals[currThread]).array;
		//return result.sort.uniq.array;
		//return p.children.map!identifiersInExpression.joiner.array;
	}

	/** Write code for Wait Statement

	  Params:
	  mem = Memory location to wait for
	  vals = values to wait for
	  loadType = Access mode for reading
	  reg = Optional register to read the value into

	  Returns: Promela code for waiting
	  **/
	string waitStatement(string mem, in string[] vals, LoadType loadType, string reg = "") @safe{
		import std.string : empty;
		string result;
		auto vals2 = vals.map!appendModulo.array;
		enforce(mem in globalsSet, "%s is not a global".format(mem));
		result ~= instrument.verifyLocal(currThread, vals);
		result = "atomic {\n";
		result ~= instrument.waitStatementBeforeWaiting(currThread, mem, vals2);
		result ~= "};\n";
		result ~= "atomic {\n";
		result ~= vals2.map!(val => "%s == %s".format(mem, val)).join(" || ") ~ ";\n";
		if (!reg.empty){
			result ~= "%s = %s;\n".format(reg, mem);
		}
		result ~= instrument.waitStatementAfterWaiting(currThread, mem, loadType);
		result ~= "};\n";
		return result;
	}

	/** Allow for the tree to write code and parse

	  Params:
	  s = Expression to Parse
	  returns ParseTree
	 **/
	ParseTree parseExpression(string s) @trusted {
		return Tpl.decimateTree(Tpl.AssignmentExpression(s));
	}

	/** Allow for the tree to write code and parse

	  Params:
	  s = Statements to Parse
	  returns ParseTree
	 **/
	ParseTree parseStatements(string s) @trusted {
		return Tpl.decimateTree(Tpl.Statements(s));
	}

	/** Parse the tree recursivly
	  Params:
	  p = Sub-tree to parse
	  Returns: text matching the subtree
	 **/
	string parseToCode(ParseTree p) @safe {
		switch(p.name)
		{
			case "Tpl":
				enforce(p.successful, "Can't create ParseTree");
				return parseToCode(p.children[0]); // The grammar result has only child: the start rule's parse tree

			case "Tpl.Program":
				string result;
				moduloNumber = config.moduloNumber;

				// Globals
				auto gpa = p.children.find!(a=>a.name == "Tpl.Globals");
				enforce(gpa.length>0, "No globals");

				auto globChildren = gpa[0].children;
				auto globalsInit = assocArray(zip(
							globChildren.map!(a=>a.matches[0]),
							globChildren.map!(a=> a.children.length > 1 ? a.matches[1].to!size_t : 0),
							));
				globalsSet = assocArray(zip(config.vars, true.repeat(globalsInit.length)));

				enforce(globalsInit.byValue.filter!(a=> a >= moduloNumber.to!size_t).walkLength == 0,
					"Can't initialize variable with value greater than max_memory (%s)".format(moduloNumber.to!size_t - 1));

				globalsInit[fenceGlobal] = 0;
				globalsSet[fenceGlobal] = true;

				result ~= initializeVariablesWithValue(globalsInit);
				threads = config.threads;
				result ~= instrument.initializeMemoryMetadata();

				// Not atomic
				auto nap = p.children.find!(a=>a.name == "Tpl.NotAtomic");
				if (nap.length > 0){
					auto naChildren = nap[0].children;
					auto vars = naChildren.map!(a=>a.matches[0]).array;
					auto naInit = assocArray(zip(
								vars,
								naChildren.map!(a=> a.children.length > 1 ? a.matches[1].to!size_t : 0),
								));
					naGlobalsSet = assocArray(zip(vars, true.repeat(naInit.length)));

					enforce(naInit.byValue.filter!(a=> a >= moduloNumber.to!size_t).walkLength == 0,
						"Can't initialize variable with value greater than max_memory (%s)".format(moduloNumber.to!size_t - 1));

					foreach (v; vars){
						enforce (v !in globalsSet, "%s can't be both atomic and non atmoic".format(v));
					}

					result ~= initializeVariablesWithValue(naInit);
				}

				// Functions

				foreach(ref child; p.children.filter!(a=>a.name == "Tpl.Function"))
					result ~= parseToCode(child);

				enforce (equal(functions.uniq, functions), "Function names are not unique");
				result ~= "init{\natomic{\n";
				foreach (ref s; functions)
					result ~= "run %s ();\n".format(s);
				result ~= "skip\n}\n}\n";
				return result;

			case "Tpl.Function":
				functions ~= p.matches[0];
				string result = "proctype " ~ p.matches[0] ~ "(){\n";
				foreach (k, t; instrument.getLocals(currThread)){
					result ~= t ~ " " ~ k ~ ";\n";
				}
				result ~= "bit " ~ fenceVar ~ ";\n";
				result ~= "bool " ~ getAssertVariableLocal ~";\n";
				result ~= "bit " ~ lockVar ~ ";\n";
				if (p.children[1].name == "Tpl.Variables"){
					locals = p.children[1].matches;
					locals.sort;
					enforce (equal(locals.uniq, locals), "Locals with same name declared twice");
					foreach (const ref l; locals){
						enforce (l !in globalsSet, "%s cannot be defined as both global and local".format(l));
						enforce (l !in naGlobalsSet, "%s cannot be defined as both non atomic and local".format(l));
					}
					result ~= initializeVariables(locals);
					result ~= parseToCode(p.children[2]);
				} else {
					// No local variables
					locals = [];
					result ~= parseToCode(p.children[1]);
				}
				result ~= endLabel ~ ":";
				result ~= "skip\n}\n\n";
				currThread += 1;
				return result;

			case "Tpl.Statements":
				string result;
				foreach (ref child; p.children)
					result ~= parseToCode(child);
				return result;
			case "Tpl.Statement":
				return "/* " ~ p.input[p.begin..p.end] ~ " */\n" ~ parseToCode(p.children[0]);

			case "Tpl.WhileStatement":
				return "do\n :: (%1$s) -> %3$s %2$s \n:: else -> %3$s break\nod;skip;".format(parseToCode(p.children[0]).appendModulo, parseToCode(p.children[1]), instrument.verifyLocal(currThread, identifiersInExpression(p.children[0])));

			case "Tpl.StoreStatement":
				string expr = p.children[1].matches.join(" ").appendModulo;
				string mem = p.matches[0];
				enforce (mem in globalsSet, "%s is not a global".format(mem));
				auto access = StoreType.rlx;
				auto accessTree = p.children.find!(a=>a.name == "Tpl.StoreType");
				if (!accessTree.empty){
					access = accessTree[0].matches[0].to!StoreType;
				}
				string result = "d_step {\n";
				result ~= instrument.verifyLocal(currThread, identifiersInExpression(p.children[1]));
				result ~= instrument.storeStatementBefore(currThread, mem, access);
				result ~= mem ~ " = " ~ expr ~ "\n";
				result ~= "};\n";
				return result;

			case "Tpl.NAStoreStatement":
				string expr = p.matches[1..$].join(" ").appendModulo;
				string mem = p.matches[0];
				enforce (mem in naGlobalsSet, "%s is not a non atomic".format(mem));
				string result = instrument.naStoreStatementBeforeAtomic(currThread, mem);
				result ~= "d_step {\n";
				result ~= instrument.verifyLocal(currThread, identifiersInExpression(p.children[1]));
				result ~= instrument.naStoreStatementBefore(currThread, mem);
				result ~= mem ~ " = " ~ expr ~ "\n";
				result ~= "};\n";
				return result;

			case "Tpl.WaitStatement":
				string mem = p.matches[0];
				auto access = LoadType.rlx;
				auto accessTree = p.children.find!(a=>a.name == "Tpl.LoadType");
				if (!accessTree.empty){
					access = accessTree[0].matches[0].to!LoadType;
				}
				enforce (mem in globalsSet, "%s is not a global".format(mem));
				import std.algorithm.searching : until;
				string[] vals = p.children[1..$].until!(a=>a.name == "Tpl.LoadType").map!(x=>x.matches[0]).array;
				return waitStatement(mem, vals, access);

			case "Tpl.BCASStatement":
				string mem = p.matches[0];
				string expBefore = p.children[1].matches.join.appendModulo;
				string expAfter = p.children[2].matches.join.appendModulo;
				enforce (mem in globalsSet, "%s is not a global".format(mem));
				auto loadType = LoadType.rlx;
				auto storeType = StoreType.rlx;
				auto accessTree = p.children.find!(a=>a.name == "Tpl.LoadType");
				if (!accessTree.empty){
					loadType = accessTree[0].matches[0].to!LoadType;
					auto accessTree2 = accessTree.find!(a=>a.name == "Tpl.StoreType");
					storeType = accessTree2[0].matches[0].to!StoreType;
				}
				string result = "d_step {\n";
				result ~= instrument.verifyLocal(currThread, identifiersInExpression(p.children[1]));
				result ~= instrument.verifyLocal(currThread, identifiersInExpression(p.children[2]));
				result ~= instrument.bcasStatementBeforeWaiting(currThread, mem, expBefore);
				result ~= "};\n";
				result ~= "d_step {\n";
				result ~= "%s == %s;\n".format(mem, expBefore);
				result ~= instrument.bcasStatementBefore(currThread, mem, loadType, storeType);
				result ~= "%s = %s;\n".format(mem, expAfter);
				result ~= "};\n";
				return result;

			case "Tpl.AssignmentExpression":
				string result;
				auto register = p.children[0].matches[0];
				enforce (register !in globalsSet, "%s is a global, can't assign into it".format(register));
				enforce (register !in naGlobalsSet, "%s is a non atomic, can't assign into it".format(register));
				auto rightchild = p.children[1].children[0];
				switch (rightchild.name){
					case "Tpl.Expression":
						result ~= instrument.verifyLocal(currThread, identifiersInExpression(rightchild));
						result ~= instrument.cleanLocal(currThread, register);
						return result ~ "%s = %s;\n".format(register, parseToCode(rightchild).appendModulo);
					case "Tpl.CAS":
					case "Tpl.FADD":
					case "Tpl.Exchange":
						// Shared code for RMW operation
						string mem = p.matches[1];
						enforce (mem in globalsSet, "%s is not a global".format(mem));
						auto loadType = LoadType.rlx;
						auto storeType = StoreType.rlx;
						auto accessTree = rightchild.children.find!(a=>a.name == "Tpl.LoadType");
						if (!accessTree.empty){
							loadType = accessTree[0].matches[0].to!LoadType;
							auto accessTree2 = accessTree.find!(a=>a.name == "Tpl.StoreType");
							storeType = accessTree2[0].matches[0].to!StoreType;
						}
						result ~= "d_step {\n";
						enforce (!rightchild.children[1..$].any!globalInExpression, "Found global in expression %s".format(p.input[p.begin..p.end]));
						enforce (!rightchild.children[1..$].any!naGlobalInExpression, "Found non atomic in expression %s".format(p.input[p.begin..p.end]));
						result ~= instrument.verifyLocal(currThread, identifiersInExpression(rightchild.children[1]));
						switch (rightchild.name) {
							case "Tpl.CAS":
								string assertStringRead;
								string assertStringUpdate;
								string expr = parseToCode(rightchild.children[1]).appendModulo;
								string exprNew = parseToCode(rightchild.children[2]).appendModulo;
								result ~= instrument.verifyLocal(currThread, identifiersInExpression(rightchild.children[2]));


								result ~= instrument.casStatementBefore(currThread, mem, expr);
								result ~= "if\n :: %1$s == %2$s -> %3$s;\n :: else %4$s;\nfi;\n".format(
										mem, expr,
										instrument.casStatementBeforeUpdate(currThread, mem, expr, loadType, storeType),
										instrument.casStatementBeforeRead(currThread, mem, expr, loadType),
										);
								result ~= "%s = %s;\n".format(p.matches[0], mem);
								result ~= "if\n :: %s == %s -> %s = %s\n :: else\nfi;\n".format(mem, expr, mem, exprNew);
								break;
							case "Tpl.FADD":
							case "Tpl.Exchange":
								result ~= instrument.rmwStatementBefore(currThread, mem, register, loadType, storeType);
								result ~= "%s = %s;\n".format(p.matches[0], mem);
								if (rightchild.name == "Tpl.FADD")
									result ~= mem ~ " = " ~ ( mem ~ " + " ~ parseToCode(rightchild.children[1])).appendModulo ~ ";\n";
								if (rightchild.name == "Tpl.Exchange")
									result ~= "%s = %s;\n".format(mem, parseToCode(rightchild.children[1]).appendModulo);
								break;
							default:
								assert(0);
						}


						result ~= "};\n";
						return result;
					case "Tpl.LoadStatement":
						string mem = p.matches[1];
						enforce (mem in globalsSet, "%s is not a global".format(mem));
						auto access = LoadType.rlx;
						auto accessTree = rightchild.children.find!(a=>a.name == "Tpl.LoadType");
						if (!accessTree.empty){
							access = accessTree[0].matches[0].to!LoadType;
						}
						result = "d_step {\n";
						result ~= instrument.loadStatementBefore(currThread, mem, register, access);
						result ~= register ~ " = " ~ mem ~ "\n";
						result ~= "};\n";
						return result;
					case "Tpl.NALoadStatement":
						string mem = p.matches[1];
						enforce (mem in naGlobalsSet, "%s is not a non atomic".format(mem));
						result ~= instrument.naLoadStatementBefore(currThread, mem);
						result ~= register ~ " = " ~ mem ~ "\n";
						return result;
					case "Tpl.WaitRhs":
						string reg = p.matches[0];
						string mem = p.matches[1];
						string[] vals = p.matches[2..$];

						auto access = LoadType.rlx;
						auto accessTree = rightchild.children.find!(a=>a.name == "Tpl.LoadType");
						if (!accessTree.empty){
							access = accessTree[0].matches[0].to!LoadType;
							vals = vals[1..$-1];
						}
						return waitStatement(mem, vals, access, reg);
					default:
						throw new Exception(format("Invalid assignment: %s", p.input[p.begin..p.end]));
				}

				assert(0);

			case "Tpl.LabeledStatement":
				return p.matches[0] ~ ": skip; " ~ parseToCode(p.children[1]);
			case "Tpl.GotoStatement":
				return p.matches.join(" ");
			case "Tpl.IfGotoStatement":
				enforce (!globalInExpression(p.children[0]), "Found global in expression %s".format(p.input[p.begin..p.end]));
				enforce (!naGlobalInExpression(p.children[0]), "Found non atomic in expression %s".format(p.input[p.begin..p.end]));
				string result;
				result ~= instrument.verifyLocal(currThread, identifiersInExpression(p.children[0]));
				return result ~ "if\n :: %s -> %s\n :: else\nfi;\n".format(p.children[0].matches.join.appendModulo, p.children[1].matches.join(" "));
			case "Tpl.IfStatement":
				enforce (!globalInExpression(p.children[0]), "Found global in expression %s".format(p.input[p.begin..p.end]));
				enforce (!naGlobalInExpression(p.children[0]), "Found non atomic in expression %s".format(p.input[p.begin..p.end]));
				string result;
				result ~= instrument.verifyLocal(currThread, identifiersInExpression(p.children[0]));
				return result ~ "if\n :: %1$s -> %2$s\n :: else -> %3$s \nfi;\n".format(p.children[0].matches.join.appendModulo, parseToCode(p.children[1]), p.children.length > 2 ? parseToCode(p.children[2]) : "skip;");
			case "Tpl.Expression":
				// NOTE: We are do not verify the if the locals in the expression are allowed to be used here.
				// The calling function is responsible for this
				enforce (!globalInExpression(p), "Found global in expression %s".format(p.input[p.begin..p.end]));
				enforce (!naGlobalInExpression(p), "Found non atomic in expression %s".format(p.input[p.begin..p.end]));
				return p.input[p.begin..p.end].appendModulo;

			case "Tpl.FenceStatement":
				auto access = FenceType.upd;
				auto accessTree = p.children.find!(a=>a.name == "Tpl.FenceType");
				if (!accessTree.empty){
					access = accessTree[0].matches[0].to!FenceType;
				}
				auto toFence = instrument.fence(currThread, access);
				if (toFence[0]){
					return "atomic {\n %s \n}".format(toFence[1]);
				}
				//enum fenceText = "fence(acq); %s = FADD(%s, 0, acq, rel); fence(rel);".format(fenceVar, fenceGlobal);
				//enum fenceText = "fence(acq_rel); %s = FADD(%s, 0, rlx, rlx); fence(acq_rel);".format(fenceVar, fenceGlobal);
				enum fenceText = "fence(acq); %s = FADD(%s, 0, acq, rel); fence(rel);".format(fenceVar, fenceGlobal);
				//auto tree = parseExpression(fenceText);
				auto tree = parseStatements(fenceText);
				return parseToCode(tree);

			case "Tpl.LockStatement":
				string lockName = p.children[0].matches[0];
				string lockLabel = getLockLabel();
				//string lockText = "%s = 1;\n%s: %s = CAS(%s, 0, 1);\nif (%s != 0) goto %s;".format(lockVar, lockLabel, lockVar, lockName, lockVar, lockLabel);
				string lockText = "BCAS(%s, 0, 1, acq, rlx);\n;".format(lockName);
				auto tree = parseStatements(lockText);
				return parseToCode(tree);

			case "Tpl.UnlockStatement":
				string text = "%s.store(0, rel);".format(p.children[0].matches[0]);
				auto tree = parseStatements(text);
				return parseToCode(tree);

			case "Tpl.NonDeterministic":
				string result = "if\n";
				foreach (c; p.children){
					result ~= ":: true -> %s".format(parseToCode(c));
				}
				result ~= "fi;\n";
				return result;
			case "Tpl.AssumeStatement":
				// TODO: What should assume do about tainted expressions?
				return "if\n :: %s -> skip;\n :: else -> goto %s;\nfi;\n".format(parseToCode(p.children[0]), endLabel);
			case "Tpl.SkipStatement":
				return "skip;\n";
			case "Tpl.AssertStatement":
				// TODO: What should assert do about tainted expressions?
				return "%1$s = %2$s;\nassert(%1$s);\n".format(getAssertVariableLocal, p.matches.join);
			case "Tpl.VerifyStatement":
				string var = p.children[0].matches[0];
				enforce (var !in globalsSet, "%s is a global".format(var));
				enforce (var !in naGlobalsSet, "%s is a non atomic global".format(var));
				return instrument.verifyLocal(currThread, var);
			default:
				return null;
		}
	}


	return parseToCode(p);
}

