#!/usr/bin/env rdmd
import std.process : spawnProcess, wait, spawnShell, pipeProcess, Redirect;
import std.stdio;
import std.path : baseName, stripExtension, dirName, absolutePath, buildPath;
import std.string : join, StringException;
import std.file : mkdirRecurse, chdir, getcwd, tempDir, exists;
import std.algorithm.searching: canFind;
import std.algorithm : map, filter, until, any, joiner ;
import std.string : format;
import std.datetime.stopwatch : StopWatch, AutoStart, Duration;
import std.getopt;
import std.conv : to;
import std.parallelism : TaskPool;
import std.array : array, split;

enum tplProg = "./tplspin";

struct Run{
	int _returnCode;
	Duration _duration;
	this(int returnCode, Duration duration) {
		_returnCode = returnCode;
		_duration = duration;
	}
	this(Duration duration) {
		_duration = duration;
	}
	@property returnCode() { return _returnCode; }
	@property duration() { return _duration; }
}

enum Robust{
	yes,
	no,
	unknown,
}

struct Benchmark{
	string _name;
	Run[] _runs;
	Robust _robust;
	Robust _expected;

	this(string name, Run[] runs, Robust robust, Robust expected){
		_name = name;
		_runs = runs;
		_robust = robust;
		_expected = expected;
	}

	@property name() { return _name; }
	@property runs() { return _runs; }
	@property robust() { return _robust; }
	@property expected() { return _expected; }

	static string tsvHeader(){
		enum string[] t = ["Program", "TPL", "Spin", "Compile", "Pan", "Res", "Expected"];
		return t.join("\t");
	}
	string tsv(){
		string[] t;
		t ~= _name;
		foreach (r ; runs){
			t ~= "%.1f".format(r.duration.total!"msecs" / 1000.0);
		}
		t ~= "%s".format(robust);
		t ~= "%s".format(expected);
		return t.join("\t");
	}
}



Run[] chainCallsBenchmark(in string[][] calls, in string tmpFolder){
	Run[] result;
	foreach (args; calls){
		static import std.process;
		auto sw = StopWatch(AutoStart.yes);
		auto pid = spawnProcess(args,
				std.stdio.stdin, std.stdio.stdout, std.stdio.stderr,
				null, std.process.Config.none,
				tmpFolder);
		auto exitcode = wait(pid);
		sw.stop();
		result ~= Run(exitcode, sw.peek);

		import std.exception : enforce;
		enforce(exitcode == 0, format("%d code returned from: %s", exitcode, args.join(" ")));
	}
	return result;
}


int main(string[] args){
	// Get options
	int stepsLimit = 6;
	string memoryModel = "ra";
	string verificationMode = "trackSome";
	bool listInstruments = false;
	bool bfs = false;
	size_t parallelInput = 1;
	Robustness robustness;
	try{
		static import std.traits;
		auto stepsText = "Step limit 1 * 10^n (-m to pan) ["~stepsLimit.to!string~"]";
		auto helpInformation = getopt(
				args,
				"mode|m", "Verification Mode",  &verificationMode,
				"memory", "Memory Model",  &memoryModel,
				"robustness", "Robustness Type",  &robustness,
				"steps|s", stepsText, &stepsLimit,
				"list-instruments", "Print list of memory models and modes", &listInstruments,
				"bfs", "Run BFS for shorter trace", &bfs,
				"parallel|p", "Run tests in parallel, useful for checking correctness instead of time", &parallelInput,
				);

		if (helpInformation.helpWanted){
			enum helpMessage = format("Tpl\n\n" ~
					"Helper program to benchmark RA robustness");
			defaultGetoptPrinter(helpMessage, helpInformation.options);
			return 0;
		}

		if (listInstruments){
			auto pid = spawnProcess([tplProg, "--list-instruments", ]);
			auto exitcode = wait(pid);
			return exitcode;
		}

	} catch(GetOptException e) {
		stderr.writeln("Error parsing arguments: ", e.msg);
		return -1;
	} catch(std.conv.ConvException e) {
		stderr.writeln("Error parsing arguments: ", e.msg);
		return -1;
	}

	write(Benchmark.tsvHeader);
	writeln("\t#T\t#LoC");
	TaskPool taskPool;

	if (parallelInput == 0){
		taskPool = new TaskPool;
	} else {
		taskPool = new TaskPool(parallelInput - 1);
	}
	scope(exit) taskPool.finish(true);
	foreach (arg; taskPool.parallel(args[1..$])){
		auto runs = benchmark(arg, memoryModel, verificationMode, stepsLimit, robustness, bfs);
		// writeln(runs);
		import std.conv : to;
		writeln(runs.tsv,
		"\t" ~ arg.threadsCount.to!string,
		"\t" ~ arg.linesOfCode.to!string,
		);
		
	}
	return 0;
}

Benchmark benchmark(string prog, string memoryModel, string mode, int stepsLimit, Robustness robustness, bool bfs = false){
	const tplProg = tplProg.absolutePath;
	immutable string progName = prog.stripExtension.baseName;
	immutable string targetDir = buildPath(prog.dirName, "pml");
	immutable string targetFile = buildPath(targetDir, progName ~ ".pml");
	immutable string fullTargetFile = targetFile.absolutePath;
	immutable string fullProgPath = prog.absolutePath;
	immutable MemoryModel memoryModelS = memoryModel.to!MemoryModel;

	Run[] runs;
	string tmpFolder;
	do {
		import std.random;
		import std.range;
		auto rnd = rndGen;
		tmpFolder = buildPath(tempDir, "tplspin_" ~ rnd.takeOne.front.to!string);
	} while (tmpFolder.exists);

	mkdirRecurse(targetDir);
	mkdirRecurse(tmpFolder);
	static import std.file;
	scope(exit) if (tmpFolder.exists) std.file.rmdirRecurse(tmpFolder);

	auto callsChained = 
		[
		[tplProg, "-i", fullProgPath, "-o", fullTargetFile, "-m", mode, "--memory", memoryModel, ],
		["spin", "-a", fullTargetFile],
		];
		if (!bfs){
			callsChained ~= 
				//["gcc", "-DVECTORSZ=1024000", "-O0", "-o", "pan", "pan.c", "-DMEMLIM=4096", "-DCOLLAPSE", "-DSAFETY"]
				//["gcc", "-DVECTORSZ=102400", "-O2", "-o", "pan", "pan.c", "-DMEMLIM=8192", "-DCOLLAPSE", "-DSAFETY"]
				//["gcc", "-DVECTORSZ=102400", "-O2", "-o", "pan", "pan.c", "-DSAFETY", "-DNOBOUNDCHECK", "-DNOCOMP", "-DNOFAIR", "-DNOSTUTTER", "-DSFH"]
				["gcc", "-DVECTORSZ=102400", "-O2", "-o", "pan", "pan.c", "-DSAFETY", "-DNOBOUNDCHECK", "-DNOCOMP", "-DNOFAIR", "-DNOSTUTTER", "-DSFH", "-DBITSTATE"]
				//["gcc", "-DVECTORSZ=102400", "-O2", "-o", "pan", "pan.c", "-DSAFETY", "-DNOBOUNDCHECK", "-DNOCOMP", "-DNOFAIR", "-DNOSTUTTER", "-DSFH", "-DBITSTATE", "-DQUADCORE"]
				;
		} else {
			callsChained ~= 
				//["gcc", "-DVECTORSZ=102400", "-O2", "-o", "pan", "pan.c", "-DMEMLIM=8192", "-DCOLLAPSE", "-DSAFETY", "-DSPACE", "-DHC", "-DBFS"]
				//["gcc", "-DVECTORSZ=102400", "-O2", "-o", "pan", "pan.c", "-DMEMLIM=8192", "-DCOLLAPSE", "-DSAFETY", "-DSPACE", "-DBFS_PAR"]
				["gcc", "-DVECTORSZ=102400", "-O2", "-o", "pan", "pan.c", "-DSAFETY", "-DNOBOUNDCHECK", "-DNOCOMP", "-DNOFAIR", "-DNOSTUTTER", "-DSFH", "-DBFS_PAR"]
				//["gcc", "-DVECTORSZ=102400", "-O2", "-o", "pan", "pan.c", "-DSAFETY", "-DNOBOUNDCHECK", "-DNOFAIR", "-DNOSTUTTER", "-DSPACE", "-DBITSTATE", "-DBFS"]
				;
		}
		runs = chainCallsBenchmark(callsChained, tmpFolder);


	// Read spin depth from file
	{
		import std.file : readText;
		import std.string : splitLines, stripLeft, startsWith;
		import std.algorithm : find;
		import std.array : split, empty;
		auto src = readText(prog).splitLines.find!(x=>x.stripLeft.startsWith("//") && x.canFind("spin_depth"));
		if (!src.empty){
			stepsLimit = src[0].split()[$-1].to!int;
		}
	}

	auto sw = StopWatch(AutoStart.yes);
	Robust robust = Robust.yes;
	{
		scope(exit) sw.stop();
		import std.math : pow;
		static import std.process;
		auto pipes = pipeProcess(
				[buildPath(tmpFolder, "pan"), "-b", "-m" ~ (pow(10, stepsLimit)).to!string, "-n", "-E"],
				Redirect.stdout,
				null,
				std.process.Config.none,
				tmpFolder);
		scope(exit) pipes.pid.wait;
		foreach (line; pipes.stdout.byLine) {
			if (line.canFind("error, VECTORSZ too small")) {
				stderr.writeln(targetFile ~": " ~ line);
				//throw new StringException("VECTORZ is too smal");
				robust = Robust.unknown;
			} else if (line.canFind("reached -DMEMLIM bound")) {
				stderr.writeln(targetFile ~": "~ line);
				//throw new StringException("Not enough Memory. DMEMLIM is too smal");
				robust = Robust.unknown;
			} else if (line.canFind("error") && !line.canFind("errors:")){
				stderr.writeln(targetFile ~": "~ line);
				robust = Robust.unknown;
			}
			if (line.canFind("assertion violated")) robust = Robust.no;
			if (line.canFind("assertion violated") && line.canFind("assertion violated assertion_var")){
				robust = Robust.unknown;
				stderr.writeln(targetFile ~": "~ "TPL Assertion violated");
			}
			if (line.canFind("Warning: Search not completed") && robust == Robust.yes) {
				//robust = Robust.unknown;
				stderr.writeln(targetFile ~": "~ line);
			}
			debug line.writeln;
		}
	}
	runs ~= Run(sw.peek);
	debug writefln("\nIs %s robust? %s", prog, robust);


	Robust expected = Robust.unknown;
	{
		import std.file : readText;
		import std.string : splitLines, stripLeft, startsWith;
		import std.array : split, empty;
		import std.regex;
		//auto r = ctRegex!(`ROBUSTNESS\s+(?P<notion>\w+):\s*(robust:\s*(?P<robust>\w+(\s*,\s*\w+)*)\s*\.)?\s*(not:\s*(?P<notrobust>\w+(\s*,\s*\w+)*)\s*\.)?`);
		auto r = regex(`ROBUSTNESS\s+(?P<notion>\w+):\s*(robust:\s*(?P<robust>\w+(\s*,\s*\w+)*)\s*\.)?\s*(not:\s*(?P<notrobust>\w+(\s*,\s*\w+)*)\s*\.)?`);
		auto src = readText(prog).splitLines.until!(x=>!x.stripLeft.startsWith("//")).filter!(x=>x.canFind("ROBUSTNESS")).map!(x=>x.matchFirst(r)).array;
		const isRobust = src.filter!(x=>robustness.robustIf(x["notion"].to!Robustness)).map!(x=>x["robust"].split(',').map!(to!MemoryModel)).joiner.any!(x=>memoryModelS.robustIf(x));
		const isNotRobust = src.filter!(x=>robustness.notRobustIf(x["notion"].to!Robustness)).map!(x=>x["notrobust"].split(',').map!(to!MemoryModel)).joiner.any!(x=>memoryModelS.notRobustIf(x));
		if (isRobust){
			if (isNotRobust){
				stderr.writefln("%s MISMATCH: Marked as both robust and not robust ", prog);
			}
			expected = Robust.yes;
		} else if (isNotRobust){
			expected = Robust.no;
		}
		if (expected != Robust.unknown){
			if (expected != robust){
				stderr.writefln("%s MISMATCH: expected: %s ; result: %s", prog, expected, robust);
			}
		} else {
			stderr.writefln("%s isn't marked for robustness.", prog);
		}

		// Copy trace (trail) in case it exists
		{
			const fname = progName ~ ".pml.trail";
			// TODO: FIXME: Find file name automatically. Sometimes it is not simply .trail
			const srcTrail = buildPath(tmpFolder, fname);
			const dstTrail = buildPath(targetDir, fname);
			import std.file : exists, copy;
			if (dstTrail.exists){
				import std.file : remove;
				dstTrail.remove;
			}
			if (srcTrail.exists){
				srcTrail.copy(dstTrail);
			}
		}
	}

	return Benchmark(prog, runs, robust, expected);
}

size_t linesOfCode(string prog){
	import std.file : readText;
	import std.algorithm : filter, map, startsWith;
	import std.string : splitLines, strip;
	import std.array : array, empty;
	return prog.readText.splitLines.map!(strip).filter!(a => !a.empty && !a.startsWith("//")).array.length;
}
size_t threadsCount(string prog){
	import std.file : readText;
	import std.algorithm : filter, map, startsWith;
	import std.string : splitLines, strip;
	import std.array : array;
	return prog.readText.splitLines.map!(strip).filter!(a => a.startsWith("fn ")).array.length;
}



enum MemoryModel{
	ra, // C/C++ Release Acquire
	rlx, // C/C++ Memory Model
	sc, // SC consistency
}
bool robustIf(MemoryModel lhs, MemoryModel rhs){
	// HACK: Improve code here
	if (lhs == rhs) return true;
	with (MemoryModel) if (lhs == ra && rhs == rlx) return true;
	return false;
}
bool notRobustIf(MemoryModel lhs, MemoryModel rhs){
	return robustIf(rhs, lhs);
}
enum Robustness{
	egr,  // Execution Graph Robustness
	wegr, // HACK: Name this
}
bool robustIf(Robustness lhs, Robustness rhs){
	// HACK: Improve code here
	if (lhs == rhs) return true;
	with (Robustness) if (lhs == wegr && rhs == egr) return true;
	return false;
}
bool notRobustIf(Robustness lhs, Robustness rhs){
	return robustIf(rhs,lhs);
}
