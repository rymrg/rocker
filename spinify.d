#!/usr/bin/env rdmd
import std.process : spawnProcess, wait, spawnShell, pipeProcess, Redirect;
import std.stdio;
import std.path : baseName, stripExtension, dirName;
import std.string : join, StringException;
import std.file : mkdirRecurse;
import std.algorithm.searching: canFind;
import std.string : format;
import std.datetime.stopwatch : StopWatch, AutoStart, Duration;
import std.getopt;
import std.conv : to;

enum tplProg = "./tplspin";

int chainCalls(string[][] calls){
	foreach (args; calls){
		auto pid = spawnProcess(args);
		auto exitcode = wait(pid);
		if (exitcode != 0){
			stderr.writefln("%d code returned from: %s", exitcode, args.join(" "));
			return exitcode;
		}
	}
	return 0;
}

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



Run[] chainCallsBenchmark(string[][] calls){
	Run[] result;
	foreach (args; calls){
		auto sw = StopWatch(AutoStart.yes);
		auto pid = spawnProcess(args);
		auto exitcode = wait(pid);
		sw.stop();
		result ~= Run(exitcode, sw.peek);

		if (exitcode != 0){
			stderr.writefln("%d code returned from: %s", exitcode, args.join(" "));
			break;
		}
	}
	return result;
}

int main(string[] args){
	// Get options
	int stepsLimit = 6;
	string memoryModel = "ra";
	string verificationMode = "trackSome";
	bool listInstruments = false;
	try{
		static import std.traits;
		auto stepsText = "Step limit 1 * 10^n (-m to pan) ["~stepsLimit.to!string~"]";
		auto helpInformation = getopt(
				args,
				"mode|m", "Verification Mode",  &verificationMode,
				"memory", "Memory Model",  &memoryModel,
				"steps|s", stepsText, &stepsLimit,
				"list-instruments", "Print list of memory models and modes", &listInstruments,
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
	foreach (arg; args[1..$]){
		auto runs = benchmark(arg, memoryModel, verificationMode, stepsLimit);
		// writeln(runs);
		write(runs.tsv);
		import std.conv : to;
		write("\t" ~ arg.threadsCount.to!string);
		write("\t" ~ arg.linesOfCode.to!string);
		writeln();
	}
	return 0;
}

Benchmark benchmark(string prog, string memoryModel, string mode, int stepsLimit){
	immutable string progName = prog.stripExtension.baseName;
	immutable string targetDir = prog.dirName ~ "/pml";
	immutable string targetFile = targetDir ~ "/" ~ progName ~ ".pml";

	mkdirRecurse(targetDir);
	auto runs = chainCallsBenchmark(
			[
			[tplProg, "-i", prog, "-o", targetFile, "-m", mode, "--memory", memoryModel, ],
			["spin", "-a", targetFile],
			//["gcc", "-DVECTORSZ=1024000", "-O0", "-o", "pan", "pan.c", "-DMEMLIM=4096", "-DCOLLAPSE", "-DSAFETY"],
			//["gcc", "-DVECTORSZ=102400", "-O2", "-o", "pan", "pan.c", "-DMEMLIM=8192", "-DCOLLAPSE", "-DSAFETY"],
			//["gcc", "-DVECTORSZ=102400", "-O2", "-o", "pan", "pan.c", "-DSAFETY", "-DNOBOUNDCHECK", "-DNOCOMP", "-DNOFAIR", "-DNOSTUTTER", "-DSFH"],
			//["gcc", "-DVECTORSZ=102400", "-O2", "-o", "pan", "pan.c", "-DMEMLIM=8192", "-DCOLLAPSE", "-DSAFETY", "-DSPACE", "-DHC", "-DBFS"],
			//["gcc", "-DVECTORSZ=102400", "-O2", "-o", "pan", "pan.c", "-DMEMLIM=8192", "-DCOLLAPSE", "-DSAFETY", "-DSPACE", "-DBFS_PAR"],
			//["gcc", "-DVECTORSZ=102400", "-O2", "-o", "pan", "pan.c", "-DSAFETY", "-DNOBOUNDCHECK", "-DNOCOMP", "-DNOFAIR", "-DNOSTUTTER", "-DSFH", "-DBFS_PAR"],
			["gcc", "-DVECTORSZ=102400", "-O2", "-o", "pan", "pan.c", "-DSAFETY", "-DNOBOUNDCHECK", "-DNOCOMP", "-DNOFAIR", "-DNOSTUTTER", "-DSFH", "-DBITSTATE"],
			//["gcc", "-DVECTORSZ=102400", "-O2", "-o", "pan", "pan.c", "-DSAFETY", "-DNOBOUNDCHECK", "-DNOFAIR", "-DNOSTUTTER", "-DSPACE", "-DBITSTATE", "-DBFS"],
			//["gcc", "-DVECTORSZ=102400", "-O2", "-o", "pan", "pan.c", "-DSAFETY", "-DNOBOUNDCHECK", "-DNOCOMP", "-DNOFAIR", "-DNOSTUTTER", "-DSFH", "-DBITSTATE", "-DQUADCORE"],
			]
			);

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
		auto pipes = pipeProcess(["./pan", "-b", "-m" ~ (pow(10, stepsLimit)).to!string, "-n", "-E"], Redirect.stdout);
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

	// Clean temp files
	{
		import std.parallelism;
		import std.file;
		foreach (f; ["%s.pml.trail".format(progName), "pan"].parallel){
			if (f.exists && f.isFile){
				f.remove;
			}
		}
		foreach (f ; dirEntries("", "pan.*", SpanMode.shallow).parallel){
			if (f.isFile){
				f.remove;
			}
		}
		foreach (f ; dirEntries("", "%s.pml_pan_*.trail".format(progName), SpanMode.shallow).parallel){
			if (f.isFile){
				f.remove;
			}
		}
	}

	Robust expected = Robust.unknown;
	{
		import std.file : readText;
		import std.string : splitLines;
		string src = readText(prog).splitLines[0];
		if (src.canFind("NOTROBUST")) {
			expected = Robust.no;
		} else if (src.canFind("ROBUST")) {
			expected = Robust.yes;
		}
		if (expected != Robust.unknown){
			if (expected != robust){
				stderr.writefln("%s MISMATCH: expected: %s ; result: %s", prog, expected, robust);
			}
		} else {
			stderr.writefln("%s isn't marked for robustness.", prog);
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
