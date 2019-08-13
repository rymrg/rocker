module instruments.utils;
import std.string : format;
import std.conv : to;
import pegged.grammar;

package (instruments){
	/// Simple mixin to create functions that map meta variables (VRA, VSC, etc.) to Spin variables
	mixin template GetVarName(string T, string name){
		mixin("string get%s(%s fst, string loc) @safe pure { return \"__%s_\" ~ fst.to!string ~ '_' ~ loc;}".format(name, T, name));
	}
	/// Simple mixin to create functions that map meta variables (VRA, VSC, etc.) to Spin variables
	mixin template GetVarNameValue(string T, string name){
		mixin("string get%s(%s fst, string loc, size_t val) @safe pure { return \"__%s_\" ~ fst.to!string ~ '_' ~ loc ~ '_' ~ val.to!string;}".format(name, T, name));
	}

	enum assignFields=q{{
		import std.traits;
		static foreach(x;ParameterIdentifierTuple!(__traits(parent,{})))
			static if(__traits(hasMember, this, x))
			__traits(getMember,this,x)=mixin(x);
	}};

	/**
	  Find variables used as locks

	  Params:
	  P = ParseTree
	  Returns:
	  	List of globals used as locks
		**/
	const(string)[] findLocks(const ref ParseTree p) @safe nothrow pure{
		const(string)[] result;
		switch (p.name){
			case "Tpl.LockStatement":
				result ~= p.children[0].matches[0];
				break;
			default:
				foreach (pc ; p.children){
					result ~= findLocks(pc);
				}
				break;
		}
		return result;
	}
}
