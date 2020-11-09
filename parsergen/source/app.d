int main(string[] args){
	import pegged.grammar : asModule;
	import std.datetime : SysTime;
	import std.file : timeLastModified, readText;
	import std.path : stripExtension;
	auto source = "../parser/source/peg.txt";
	auto target = "../parser/source/peg.d";
	try{
		if (target.timeLastModified(SysTime.min) > source.timeLastModified){
			return 0;
		}
	} catch (Exception) {}
	auto peg = source.readText;
	asModule("parser.peg", target.stripExtension, peg);

	return 0;
}
