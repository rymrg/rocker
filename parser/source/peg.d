/++
This module was automatically generated from the following grammar:

Tpl:
Program <  (MaxValue :Spacing)? Globals :Spacing (NotAtomic :Spacing)? (TrackedValue :Spacing)* Function+
Globals <  :"global" VariableAssignment (:',' VariableAssignment)* :";" 
NotAtomic <  :"na" VariableAssignment (:',' VariableAssignment)* :";" 
MaxValue < :"max_value" [0-9_]+ :Spacing :";"
TrackedValue < :"track" :Spacing Identifier :':' :Spacing (
		Number :Spacing (:',' :Spacing Number :Spacing)* /
		~"all"
		) :Spacing :';'
Variables <- IdentifierList :";"
VariableAssignment < Identifier :'=' Number / Identifier
Function < :"fn" Identifier :"{" ("local" Variables)? Statements :"}"

Statements <- Statement (:Spacing Statement)*
Statement < LabeledStatement
          / IfGotoStatement
          / IfStatement
          / WhileStatement
          / GotoStatement
		  / AssignmentExpression
		  / StoreStatement
		  / NAStoreStatement
		  / FenceStatement
		  / LockStatement
		  / UnlockStatement
		  / NonDeterministic
		  / WaitStatement
		  / BCASStatement
		  / SkipStatement
		  / AssertStatement
		  / AssumeStatement
		  / VerifyStatement

StoreStatement <- Identifier :".store" :'(' Expression (:',' :Spacing StoreType)? :')' :Spacing :';'
NAStoreStatement <- Identifier :".nastore" :'(' Expression :')' :Spacing :';'
LabeledStatement < Identifier :':' Statement
IfGotoStatement < :"if" :'(' Expression :')' GotoStatement
WhileStatement < :"while" :'(' Expression :')' :'{' Statements :'}'
GotoStatement < "goto" Identifier ';'
AssumeStatement < :"assume" :'(' Expression :')' :';'
VerifyStatement < :"verify" :'(' Identifier :')' :';'

AssignmentExpression < Identifier :'=' AssignmentRHS :';'
AssignmentRHS <- NALoadStatement / LoadStatement / Expression / Identifier / CAS / FADD / Exchange / WaitRhs

WaitRhs < :"wait" :'(' Identifier :',' Expression ( :',' Expression )* ( :',' LoadType )? :')'
CAS < :"CAS" :'(' Identifier :',' Expression :',' Expression ( :',' LoadType  :',' StoreType )? :')'
Exchange < :"exchange" :'(' Identifier :',' Expression ( :',' LoadType  :',' StoreType )? :')'
LoadStatement <- Identifier :".load" :'(' (LoadType / :Spacing) :')'
NALoadStatement <- Identifier :".naload" :'(' :Spacing :')'
FADD < :"FADD" :'(' Identifier :',' Expression ( :',' LoadType  :',' StoreType )? :')'

BCASStatement < :"BCAS" :'(' Identifier :',' Expression :',' Expression ( :',' LoadType  :',' StoreType )? :')' :';'
WaitStatement < :"wait" :'(' Identifier :',' Expression ( :',' Expression )* ( :',' LoadType )? :')' :';'
FenceStatement < "fence" (:'(' FenceType :')')? :';'
LockStatement < :"lock" :'(' Identifier :')' :';'
UnlockStatement < :"unlock" :'(' Identifier :')' :';'
SkipStatement < "skip" :';'
AssertStatement < :"assert" :'(' Expression :')' ';'

LoadType < "rlx" / "acq"
StoreType < "rlx" / "rel"
FenceType < "acq_rel" / "acq" / "rel" / "seq_cst" / "upd"

NonDeterministic < :"oneof" :'(' (:'{' Statements :'}')+ :')' :';'

IfStatement < "if" '(' Expression ')' '{' Statements '}' ( "else" '{' Statements '}' )?

Identifier <~  Keyword [a-zA-Z0-9_]+ / !Keyword [a-zA-Z_] [a-zA-Z0-9_]*
Number <~ [1-9] [0-9]* | '0'
Keyword <- "BCAS" / "wait"
		 / "FADD" / "CAS" / "goto" / "if" / "else" / "elif"
         / "while" / "until" / "do" / "assert" / "fi"
		 / "local" / "global" / "lock" / "unlock" / "fence"
		 / "oneof" / "exchange" / "store" / "load"
		 / "rlx" / "acq" / "rel" / "acq_rel" / "seq_cst"
		 / "print"

		/ "active"		/ "assert"		/ "atomic"		/ "bit"
		/ "bool"		/ "break"		/ "byte"		/ "chan"
		/ "d_step"		/ "D_proctype"	/ "do"		/ "else"
		/ "empty"		/ "enabled"		/ "fi"		/ "full"
		/ "goto"		/ "hidden"		/ "if"		/ "init"
		/ "int"		/ "len"		/ "mtype"		/ "nempty"
		/ "never"		/ "nfull"		/ "od"		/ "of"
		/ "pc_value"	/ "printf"		/ "priority"	/ "proctype"
		/ "provided"	/ "run"		/ "short"		/ "skip"
		/ "timeout"		/ "typedef"		/ "unless"		/ "unsigned"
		/ "xr"		/ "xs"	/	"skip"

Spacing <~ (space / endOfLine / Comment)*
Comment <~ "//" (!endOfLine .)* endOfLine
IntegerLiteral <~ Sign? Integer 
Integer <~ digit+
Sign <- "-" / "+"

PrimaryExpression < Identifier
                  / IntegerLiteral
                  / '(' Expression ')'
PostfixExpression < PrimaryExpression ( '[' Expression ']'
                                      )*
UnaryExpression < PostfixExpression
                / UnaryOperator UnaryExpression
UnaryOperator <- [-+!]
MultiplicativeExpression    < UnaryExpression ([*%/] MultiplicativeExpression)*
AdditiveExpression          < MultiplicativeExpression ([-+] AdditiveExpression)*
RelationalExpression        < AdditiveExpression (("<=" / ">=" / "<" / ">") RelationalExpression)*
EqualityExpression          < RelationalExpression (("==" / "!=") EqualityExpression)*

ANDExpression               < EqualityExpression ('&' ANDExpression)*
ExclusiveORExpression       < ANDExpression ('^' ExclusiveORExpression)*
InclusiveORExpression       < ExclusiveORExpression ('|' InclusiveORExpression)*

LogicalANDExpression        < InclusiveORExpression ("&&" LogicalANDExpression)*
#LogicalANDExpression        < EqualityExpression ("&&" LogicalANDExpression)*
LogicalORExpression         < LogicalANDExpression ("||" LogicalORExpression)*

Expression <- LogicalORExpression

IdentifierList < Identifier (:',' Identifier)*


+/
module parser.peg;

public import pegged.peg;
import std.algorithm: startsWith;
import std.functional: toDelegate;

struct GenericTpl(TParseTree)
{
    import std.functional : toDelegate;
    import pegged.dynamic.grammar;
    static import pegged.peg;
    struct Tpl
    {
    enum name = "Tpl";
    static ParseTree delegate(ParseTree)[string] before;
    static ParseTree delegate(ParseTree)[string] after;
    static ParseTree delegate(ParseTree)[string] rules;
    import std.typecons:Tuple, tuple;
    static TParseTree[Tuple!(string, size_t)] memo;
    static this()
    {
        rules["Program"] = toDelegate(&Program);
        rules["Globals"] = toDelegate(&Globals);
        rules["NotAtomic"] = toDelegate(&NotAtomic);
        rules["MaxValue"] = toDelegate(&MaxValue);
        rules["TrackedValue"] = toDelegate(&TrackedValue);
        rules["Variables"] = toDelegate(&Variables);
        rules["VariableAssignment"] = toDelegate(&VariableAssignment);
        rules["Function"] = toDelegate(&Function);
        rules["Statements"] = toDelegate(&Statements);
        rules["Statement"] = toDelegate(&Statement);
        rules["StoreStatement"] = toDelegate(&StoreStatement);
        rules["NAStoreStatement"] = toDelegate(&NAStoreStatement);
        rules["LabeledStatement"] = toDelegate(&LabeledStatement);
        rules["IfGotoStatement"] = toDelegate(&IfGotoStatement);
        rules["WhileStatement"] = toDelegate(&WhileStatement);
        rules["GotoStatement"] = toDelegate(&GotoStatement);
        rules["AssumeStatement"] = toDelegate(&AssumeStatement);
        rules["VerifyStatement"] = toDelegate(&VerifyStatement);
        rules["AssignmentExpression"] = toDelegate(&AssignmentExpression);
        rules["AssignmentRHS"] = toDelegate(&AssignmentRHS);
        rules["WaitRhs"] = toDelegate(&WaitRhs);
        rules["CAS"] = toDelegate(&CAS);
        rules["Exchange"] = toDelegate(&Exchange);
        rules["LoadStatement"] = toDelegate(&LoadStatement);
        rules["NALoadStatement"] = toDelegate(&NALoadStatement);
        rules["FADD"] = toDelegate(&FADD);
        rules["BCASStatement"] = toDelegate(&BCASStatement);
        rules["WaitStatement"] = toDelegate(&WaitStatement);
        rules["FenceStatement"] = toDelegate(&FenceStatement);
        rules["LockStatement"] = toDelegate(&LockStatement);
        rules["UnlockStatement"] = toDelegate(&UnlockStatement);
        rules["SkipStatement"] = toDelegate(&SkipStatement);
        rules["AssertStatement"] = toDelegate(&AssertStatement);
        rules["LoadType"] = toDelegate(&LoadType);
        rules["StoreType"] = toDelegate(&StoreType);
        rules["FenceType"] = toDelegate(&FenceType);
        rules["NonDeterministic"] = toDelegate(&NonDeterministic);
        rules["IfStatement"] = toDelegate(&IfStatement);
        rules["Identifier"] = toDelegate(&Identifier);
        rules["Number"] = toDelegate(&Number);
        rules["Keyword"] = toDelegate(&Keyword);
        rules["Spacing"] = toDelegate(&Spacing);
    }

    template hooked(alias r, string name)
    {
        static ParseTree hooked(ParseTree p)
        {
            ParseTree result;

            if (name in before)
            {
                result = before[name](p);
                if (result.successful)
                    return result;
            }

            result = r(p);
            if (result.successful || name !in after)
                return result;

            result = after[name](p);
            return result;
        }

        static ParseTree hooked(string input)
        {
            return hooked!(r, name)(ParseTree("",false,[],input));
        }
    }

    static void addRuleBefore(string parentRule, string ruleSyntax)
    {
        // enum name is the current grammar name
        DynamicGrammar dg = pegged.dynamic.grammar.grammar(name ~ ": " ~ ruleSyntax, rules);
        foreach(ruleName,rule; dg.rules)
            if (ruleName != "Spacing") // Keep the local Spacing rule, do not overwrite it
                rules[ruleName] = rule;
        before[parentRule] = rules[dg.startingRule];
    }

    static void addRuleAfter(string parentRule, string ruleSyntax)
    {
        // enum name is the current grammar named
        DynamicGrammar dg = pegged.dynamic.grammar.grammar(name ~ ": " ~ ruleSyntax, rules);
        foreach(name,rule; dg.rules)
        {
            if (name != "Spacing")
                rules[name] = rule;
        }
        after[parentRule] = rules[dg.startingRule];
    }

    static bool isRule(string s)
    {
		import std.algorithm : startsWith;
        return s.startsWith("Tpl.");
    }
    mixin decimateTree;

    static TParseTree Program(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, MaxValue, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, Globals, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, NotAtomic, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing))), Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, TrackedValue, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing))), Spacing)), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Function, Spacing))), "Tpl.Program")(p);
        }
        else
        {
            if (auto m = tuple(`Program`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, MaxValue, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, Globals, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, NotAtomic, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing))), Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, TrackedValue, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing))), Spacing)), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Function, Spacing))), "Tpl.Program"), "Program")(p);
                memo[tuple(`Program`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Program(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, MaxValue, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, Globals, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, NotAtomic, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing))), Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, TrackedValue, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing))), Spacing)), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Function, Spacing))), "Tpl.Program")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, MaxValue, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, Globals, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, NotAtomic, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing))), Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, TrackedValue, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing))), Spacing)), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Function, Spacing))), "Tpl.Program"), "Program")(TParseTree("", false,[], s));
        }
    }
    static string Program(GetName g)
    {
        return "Tpl.Program";
    }

    static TParseTree Globals(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("global"), Spacing)), pegged.peg.wrapAround!(Spacing, VariableAssignment, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, VariableAssignment, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.Globals")(p);
        }
        else
        {
            if (auto m = tuple(`Globals`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("global"), Spacing)), pegged.peg.wrapAround!(Spacing, VariableAssignment, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, VariableAssignment, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.Globals"), "Globals")(p);
                memo[tuple(`Globals`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Globals(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("global"), Spacing)), pegged.peg.wrapAround!(Spacing, VariableAssignment, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, VariableAssignment, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.Globals")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("global"), Spacing)), pegged.peg.wrapAround!(Spacing, VariableAssignment, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, VariableAssignment, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.Globals"), "Globals")(TParseTree("", false,[], s));
        }
    }
    static string Globals(GetName g)
    {
        return "Tpl.Globals";
    }

    static TParseTree NotAtomic(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("na"), Spacing)), pegged.peg.wrapAround!(Spacing, VariableAssignment, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, VariableAssignment, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.NotAtomic")(p);
        }
        else
        {
            if (auto m = tuple(`NotAtomic`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("na"), Spacing)), pegged.peg.wrapAround!(Spacing, VariableAssignment, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, VariableAssignment, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.NotAtomic"), "NotAtomic")(p);
                memo[tuple(`NotAtomic`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree NotAtomic(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("na"), Spacing)), pegged.peg.wrapAround!(Spacing, VariableAssignment, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, VariableAssignment, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.NotAtomic")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("na"), Spacing)), pegged.peg.wrapAround!(Spacing, VariableAssignment, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, VariableAssignment, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.NotAtomic"), "NotAtomic")(TParseTree("", false,[], s));
        }
    }
    static string NotAtomic(GetName g)
    {
        return "Tpl.NotAtomic";
    }

    static TParseTree MaxValue(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("max_value"), Spacing)), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.literal!("_")), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.MaxValue")(p);
        }
        else
        {
            if (auto m = tuple(`MaxValue`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("max_value"), Spacing)), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.literal!("_")), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.MaxValue"), "MaxValue")(p);
                memo[tuple(`MaxValue`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree MaxValue(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("max_value"), Spacing)), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.literal!("_")), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.MaxValue")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("max_value"), Spacing)), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.literal!("_")), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.MaxValue"), "MaxValue")(TParseTree("", false,[], s));
        }
    }
    static string MaxValue(GetName g)
    {
        return "Tpl.MaxValue";
    }

    static TParseTree TrackedValue(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("track"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing))), Spacing))), pegged.peg.fuse!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("all"), Spacing))), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.TrackedValue")(p);
        }
        else
        {
            if (auto m = tuple(`TrackedValue`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("track"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing))), Spacing))), pegged.peg.fuse!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("all"), Spacing))), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.TrackedValue"), "TrackedValue")(p);
                memo[tuple(`TrackedValue`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree TrackedValue(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("track"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing))), Spacing))), pegged.peg.fuse!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("all"), Spacing))), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.TrackedValue")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("track"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing))), Spacing))), pegged.peg.fuse!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("all"), Spacing))), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Spacing, Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.TrackedValue"), "TrackedValue")(TParseTree("", false,[], s));
        }
    }
    static string TrackedValue(GetName g)
    {
        return "Tpl.TrackedValue";
    }

    static TParseTree Variables(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(IdentifierList, pegged.peg.discard!(pegged.peg.literal!(";"))), "Tpl.Variables")(p);
        }
        else
        {
            if (auto m = tuple(`Variables`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(IdentifierList, pegged.peg.discard!(pegged.peg.literal!(";"))), "Tpl.Variables"), "Variables")(p);
                memo[tuple(`Variables`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Variables(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(IdentifierList, pegged.peg.discard!(pegged.peg.literal!(";"))), "Tpl.Variables")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(IdentifierList, pegged.peg.discard!(pegged.peg.literal!(";"))), "Tpl.Variables"), "Variables")(TParseTree("", false,[], s));
        }
    }
    static string Variables(GetName g)
    {
        return "Tpl.Variables";
    }

    static TParseTree VariableAssignment(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing)), pegged.peg.wrapAround!(Spacing, Number, Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing)), "Tpl.VariableAssignment")(p);
        }
        else
        {
            if (auto m = tuple(`VariableAssignment`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing)), pegged.peg.wrapAround!(Spacing, Number, Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing)), "Tpl.VariableAssignment"), "VariableAssignment")(p);
                memo[tuple(`VariableAssignment`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree VariableAssignment(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing)), pegged.peg.wrapAround!(Spacing, Number, Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing)), "Tpl.VariableAssignment")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing)), pegged.peg.wrapAround!(Spacing, Number, Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing)), "Tpl.VariableAssignment"), "VariableAssignment")(TParseTree("", false,[], s));
        }
    }
    static string VariableAssignment(GetName g)
    {
        return "Tpl.VariableAssignment";
    }

    static TParseTree Function(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("fn"), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("{"), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("local"), Spacing), pegged.peg.wrapAround!(Spacing, Variables, Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, Statements, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}"), Spacing))), "Tpl.Function")(p);
        }
        else
        {
            if (auto m = tuple(`Function`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("fn"), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("{"), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("local"), Spacing), pegged.peg.wrapAround!(Spacing, Variables, Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, Statements, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}"), Spacing))), "Tpl.Function"), "Function")(p);
                memo[tuple(`Function`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Function(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("fn"), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("{"), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("local"), Spacing), pegged.peg.wrapAround!(Spacing, Variables, Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, Statements, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}"), Spacing))), "Tpl.Function")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("fn"), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("{"), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("local"), Spacing), pegged.peg.wrapAround!(Spacing, Variables, Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, Statements, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}"), Spacing))), "Tpl.Function"), "Function")(TParseTree("", false,[], s));
        }
    }
    static string Function(GetName g)
    {
        return "Tpl.Function";
    }

    static TParseTree Statements(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Statement, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(Spacing), Statement))), "Tpl.Statements")(p);
        }
        else
        {
            if (auto m = tuple(`Statements`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(Statement, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(Spacing), Statement))), "Tpl.Statements"), "Statements")(p);
                memo[tuple(`Statements`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Statements(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Statement, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(Spacing), Statement))), "Tpl.Statements")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(Statement, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(Spacing), Statement))), "Tpl.Statements"), "Statements")(TParseTree("", false,[], s));
        }
    }
    static string Statements(GetName g)
    {
        return "Tpl.Statements";
    }

    static TParseTree Statement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, LabeledStatement, Spacing), pegged.peg.wrapAround!(Spacing, IfGotoStatement, Spacing), pegged.peg.wrapAround!(Spacing, IfStatement, Spacing), pegged.peg.wrapAround!(Spacing, WhileStatement, Spacing), pegged.peg.wrapAround!(Spacing, GotoStatement, Spacing), pegged.peg.wrapAround!(Spacing, AssignmentExpression, Spacing), pegged.peg.wrapAround!(Spacing, StoreStatement, Spacing), pegged.peg.wrapAround!(Spacing, NAStoreStatement, Spacing), pegged.peg.wrapAround!(Spacing, FenceStatement, Spacing), pegged.peg.wrapAround!(Spacing, LockStatement, Spacing), pegged.peg.wrapAround!(Spacing, UnlockStatement, Spacing), pegged.peg.wrapAround!(Spacing, NonDeterministic, Spacing), pegged.peg.wrapAround!(Spacing, WaitStatement, Spacing), pegged.peg.wrapAround!(Spacing, BCASStatement, Spacing), pegged.peg.wrapAround!(Spacing, SkipStatement, Spacing), pegged.peg.wrapAround!(Spacing, AssertStatement, Spacing), pegged.peg.wrapAround!(Spacing, AssumeStatement, Spacing), pegged.peg.wrapAround!(Spacing, VerifyStatement, Spacing)), "Tpl.Statement")(p);
        }
        else
        {
            if (auto m = tuple(`Statement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, LabeledStatement, Spacing), pegged.peg.wrapAround!(Spacing, IfGotoStatement, Spacing), pegged.peg.wrapAround!(Spacing, IfStatement, Spacing), pegged.peg.wrapAround!(Spacing, WhileStatement, Spacing), pegged.peg.wrapAround!(Spacing, GotoStatement, Spacing), pegged.peg.wrapAround!(Spacing, AssignmentExpression, Spacing), pegged.peg.wrapAround!(Spacing, StoreStatement, Spacing), pegged.peg.wrapAround!(Spacing, NAStoreStatement, Spacing), pegged.peg.wrapAround!(Spacing, FenceStatement, Spacing), pegged.peg.wrapAround!(Spacing, LockStatement, Spacing), pegged.peg.wrapAround!(Spacing, UnlockStatement, Spacing), pegged.peg.wrapAround!(Spacing, NonDeterministic, Spacing), pegged.peg.wrapAround!(Spacing, WaitStatement, Spacing), pegged.peg.wrapAround!(Spacing, BCASStatement, Spacing), pegged.peg.wrapAround!(Spacing, SkipStatement, Spacing), pegged.peg.wrapAround!(Spacing, AssertStatement, Spacing), pegged.peg.wrapAround!(Spacing, AssumeStatement, Spacing), pegged.peg.wrapAround!(Spacing, VerifyStatement, Spacing)), "Tpl.Statement"), "Statement")(p);
                memo[tuple(`Statement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Statement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, LabeledStatement, Spacing), pegged.peg.wrapAround!(Spacing, IfGotoStatement, Spacing), pegged.peg.wrapAround!(Spacing, IfStatement, Spacing), pegged.peg.wrapAround!(Spacing, WhileStatement, Spacing), pegged.peg.wrapAround!(Spacing, GotoStatement, Spacing), pegged.peg.wrapAround!(Spacing, AssignmentExpression, Spacing), pegged.peg.wrapAround!(Spacing, StoreStatement, Spacing), pegged.peg.wrapAround!(Spacing, NAStoreStatement, Spacing), pegged.peg.wrapAround!(Spacing, FenceStatement, Spacing), pegged.peg.wrapAround!(Spacing, LockStatement, Spacing), pegged.peg.wrapAround!(Spacing, UnlockStatement, Spacing), pegged.peg.wrapAround!(Spacing, NonDeterministic, Spacing), pegged.peg.wrapAround!(Spacing, WaitStatement, Spacing), pegged.peg.wrapAround!(Spacing, BCASStatement, Spacing), pegged.peg.wrapAround!(Spacing, SkipStatement, Spacing), pegged.peg.wrapAround!(Spacing, AssertStatement, Spacing), pegged.peg.wrapAround!(Spacing, AssumeStatement, Spacing), pegged.peg.wrapAround!(Spacing, VerifyStatement, Spacing)), "Tpl.Statement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, LabeledStatement, Spacing), pegged.peg.wrapAround!(Spacing, IfGotoStatement, Spacing), pegged.peg.wrapAround!(Spacing, IfStatement, Spacing), pegged.peg.wrapAround!(Spacing, WhileStatement, Spacing), pegged.peg.wrapAround!(Spacing, GotoStatement, Spacing), pegged.peg.wrapAround!(Spacing, AssignmentExpression, Spacing), pegged.peg.wrapAround!(Spacing, StoreStatement, Spacing), pegged.peg.wrapAround!(Spacing, NAStoreStatement, Spacing), pegged.peg.wrapAround!(Spacing, FenceStatement, Spacing), pegged.peg.wrapAround!(Spacing, LockStatement, Spacing), pegged.peg.wrapAround!(Spacing, UnlockStatement, Spacing), pegged.peg.wrapAround!(Spacing, NonDeterministic, Spacing), pegged.peg.wrapAround!(Spacing, WaitStatement, Spacing), pegged.peg.wrapAround!(Spacing, BCASStatement, Spacing), pegged.peg.wrapAround!(Spacing, SkipStatement, Spacing), pegged.peg.wrapAround!(Spacing, AssertStatement, Spacing), pegged.peg.wrapAround!(Spacing, AssumeStatement, Spacing), pegged.peg.wrapAround!(Spacing, VerifyStatement, Spacing)), "Tpl.Statement"), "Statement")(TParseTree("", false,[], s));
        }
    }
    static string Statement(GetName g)
    {
        return "Tpl.Statement";
    }

    static TParseTree StoreStatement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Identifier, pegged.peg.discard!(pegged.peg.literal!(".store")), pegged.peg.discard!(pegged.peg.literal!("(")), Expression, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!(",")), pegged.peg.discard!(Spacing), StoreType)), pegged.peg.discard!(pegged.peg.literal!(")")), pegged.peg.discard!(Spacing), pegged.peg.discard!(pegged.peg.literal!(";"))), "Tpl.StoreStatement")(p);
        }
        else
        {
            if (auto m = tuple(`StoreStatement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(Identifier, pegged.peg.discard!(pegged.peg.literal!(".store")), pegged.peg.discard!(pegged.peg.literal!("(")), Expression, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!(",")), pegged.peg.discard!(Spacing), StoreType)), pegged.peg.discard!(pegged.peg.literal!(")")), pegged.peg.discard!(Spacing), pegged.peg.discard!(pegged.peg.literal!(";"))), "Tpl.StoreStatement"), "StoreStatement")(p);
                memo[tuple(`StoreStatement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree StoreStatement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Identifier, pegged.peg.discard!(pegged.peg.literal!(".store")), pegged.peg.discard!(pegged.peg.literal!("(")), Expression, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!(",")), pegged.peg.discard!(Spacing), StoreType)), pegged.peg.discard!(pegged.peg.literal!(")")), pegged.peg.discard!(Spacing), pegged.peg.discard!(pegged.peg.literal!(";"))), "Tpl.StoreStatement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(Identifier, pegged.peg.discard!(pegged.peg.literal!(".store")), pegged.peg.discard!(pegged.peg.literal!("(")), Expression, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!(",")), pegged.peg.discard!(Spacing), StoreType)), pegged.peg.discard!(pegged.peg.literal!(")")), pegged.peg.discard!(Spacing), pegged.peg.discard!(pegged.peg.literal!(";"))), "Tpl.StoreStatement"), "StoreStatement")(TParseTree("", false,[], s));
        }
    }
    static string StoreStatement(GetName g)
    {
        return "Tpl.StoreStatement";
    }

    static TParseTree NAStoreStatement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Identifier, pegged.peg.discard!(pegged.peg.literal!(".nastore")), pegged.peg.discard!(pegged.peg.literal!("(")), Expression, pegged.peg.discard!(pegged.peg.literal!(")")), pegged.peg.discard!(Spacing), pegged.peg.discard!(pegged.peg.literal!(";"))), "Tpl.NAStoreStatement")(p);
        }
        else
        {
            if (auto m = tuple(`NAStoreStatement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(Identifier, pegged.peg.discard!(pegged.peg.literal!(".nastore")), pegged.peg.discard!(pegged.peg.literal!("(")), Expression, pegged.peg.discard!(pegged.peg.literal!(")")), pegged.peg.discard!(Spacing), pegged.peg.discard!(pegged.peg.literal!(";"))), "Tpl.NAStoreStatement"), "NAStoreStatement")(p);
                memo[tuple(`NAStoreStatement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree NAStoreStatement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Identifier, pegged.peg.discard!(pegged.peg.literal!(".nastore")), pegged.peg.discard!(pegged.peg.literal!("(")), Expression, pegged.peg.discard!(pegged.peg.literal!(")")), pegged.peg.discard!(Spacing), pegged.peg.discard!(pegged.peg.literal!(";"))), "Tpl.NAStoreStatement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(Identifier, pegged.peg.discard!(pegged.peg.literal!(".nastore")), pegged.peg.discard!(pegged.peg.literal!("(")), Expression, pegged.peg.discard!(pegged.peg.literal!(")")), pegged.peg.discard!(Spacing), pegged.peg.discard!(pegged.peg.literal!(";"))), "Tpl.NAStoreStatement"), "NAStoreStatement")(TParseTree("", false,[], s));
        }
    }
    static string NAStoreStatement(GetName g)
    {
        return "Tpl.NAStoreStatement";
    }

    static TParseTree LabeledStatement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":"), Spacing)), pegged.peg.wrapAround!(Spacing, Statement, Spacing)), "Tpl.LabeledStatement")(p);
        }
        else
        {
            if (auto m = tuple(`LabeledStatement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":"), Spacing)), pegged.peg.wrapAround!(Spacing, Statement, Spacing)), "Tpl.LabeledStatement"), "LabeledStatement")(p);
                memo[tuple(`LabeledStatement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree LabeledStatement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":"), Spacing)), pegged.peg.wrapAround!(Spacing, Statement, Spacing)), "Tpl.LabeledStatement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":"), Spacing)), pegged.peg.wrapAround!(Spacing, Statement, Spacing)), "Tpl.LabeledStatement"), "LabeledStatement")(TParseTree("", false,[], s));
        }
    }
    static string LabeledStatement(GetName g)
    {
        return "Tpl.LabeledStatement";
    }

    static TParseTree IfGotoStatement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("if"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.wrapAround!(Spacing, GotoStatement, Spacing)), "Tpl.IfGotoStatement")(p);
        }
        else
        {
            if (auto m = tuple(`IfGotoStatement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("if"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.wrapAround!(Spacing, GotoStatement, Spacing)), "Tpl.IfGotoStatement"), "IfGotoStatement")(p);
                memo[tuple(`IfGotoStatement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree IfGotoStatement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("if"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.wrapAround!(Spacing, GotoStatement, Spacing)), "Tpl.IfGotoStatement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("if"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.wrapAround!(Spacing, GotoStatement, Spacing)), "Tpl.IfGotoStatement"), "IfGotoStatement")(TParseTree("", false,[], s));
        }
    }
    static string IfGotoStatement(GetName g)
    {
        return "Tpl.IfGotoStatement";
    }

    static TParseTree WhileStatement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("while"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("{"), Spacing)), pegged.peg.wrapAround!(Spacing, Statements, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}"), Spacing))), "Tpl.WhileStatement")(p);
        }
        else
        {
            if (auto m = tuple(`WhileStatement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("while"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("{"), Spacing)), pegged.peg.wrapAround!(Spacing, Statements, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}"), Spacing))), "Tpl.WhileStatement"), "WhileStatement")(p);
                memo[tuple(`WhileStatement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree WhileStatement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("while"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("{"), Spacing)), pegged.peg.wrapAround!(Spacing, Statements, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}"), Spacing))), "Tpl.WhileStatement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("while"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("{"), Spacing)), pegged.peg.wrapAround!(Spacing, Statements, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}"), Spacing))), "Tpl.WhileStatement"), "WhileStatement")(TParseTree("", false,[], s));
        }
    }
    static string WhileStatement(GetName g)
    {
        return "Tpl.WhileStatement";
    }

    static TParseTree GotoStatement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("goto"), Spacing), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing)), "Tpl.GotoStatement")(p);
        }
        else
        {
            if (auto m = tuple(`GotoStatement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("goto"), Spacing), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing)), "Tpl.GotoStatement"), "GotoStatement")(p);
                memo[tuple(`GotoStatement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree GotoStatement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("goto"), Spacing), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing)), "Tpl.GotoStatement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("goto"), Spacing), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing)), "Tpl.GotoStatement"), "GotoStatement")(TParseTree("", false,[], s));
        }
    }
    static string GotoStatement(GetName g)
    {
        return "Tpl.GotoStatement";
    }

    static TParseTree AssumeStatement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("assume"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.AssumeStatement")(p);
        }
        else
        {
            if (auto m = tuple(`AssumeStatement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("assume"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.AssumeStatement"), "AssumeStatement")(p);
                memo[tuple(`AssumeStatement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree AssumeStatement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("assume"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.AssumeStatement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("assume"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.AssumeStatement"), "AssumeStatement")(TParseTree("", false,[], s));
        }
    }
    static string AssumeStatement(GetName g)
    {
        return "Tpl.AssumeStatement";
    }

    static TParseTree VerifyStatement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("verify"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.VerifyStatement")(p);
        }
        else
        {
            if (auto m = tuple(`VerifyStatement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("verify"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.VerifyStatement"), "VerifyStatement")(p);
                memo[tuple(`VerifyStatement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree VerifyStatement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("verify"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.VerifyStatement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("verify"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.VerifyStatement"), "VerifyStatement")(TParseTree("", false,[], s));
        }
    }
    static string VerifyStatement(GetName g)
    {
        return "Tpl.VerifyStatement";
    }

    static TParseTree AssignmentExpression(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing)), pegged.peg.wrapAround!(Spacing, AssignmentRHS, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.AssignmentExpression")(p);
        }
        else
        {
            if (auto m = tuple(`AssignmentExpression`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing)), pegged.peg.wrapAround!(Spacing, AssignmentRHS, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.AssignmentExpression"), "AssignmentExpression")(p);
                memo[tuple(`AssignmentExpression`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree AssignmentExpression(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing)), pegged.peg.wrapAround!(Spacing, AssignmentRHS, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.AssignmentExpression")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing)), pegged.peg.wrapAround!(Spacing, AssignmentRHS, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.AssignmentExpression"), "AssignmentExpression")(TParseTree("", false,[], s));
        }
    }
    static string AssignmentExpression(GetName g)
    {
        return "Tpl.AssignmentExpression";
    }

    static TParseTree AssignmentRHS(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(NALoadStatement, LoadStatement, Expression, Identifier, CAS, FADD, Exchange, WaitRhs), "Tpl.AssignmentRHS")(p);
        }
        else
        {
            if (auto m = tuple(`AssignmentRHS`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(NALoadStatement, LoadStatement, Expression, Identifier, CAS, FADD, Exchange, WaitRhs), "Tpl.AssignmentRHS"), "AssignmentRHS")(p);
                memo[tuple(`AssignmentRHS`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree AssignmentRHS(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(NALoadStatement, LoadStatement, Expression, Identifier, CAS, FADD, Exchange, WaitRhs), "Tpl.AssignmentRHS")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(NALoadStatement, LoadStatement, Expression, Identifier, CAS, FADD, Exchange, WaitRhs), "Tpl.AssignmentRHS"), "AssignmentRHS")(TParseTree("", false,[], s));
        }
    }
    static string AssignmentRHS(GetName g)
    {
        return "Tpl.AssignmentRHS";
    }

    static TParseTree WaitRhs(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("wait"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, LoadType, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), "Tpl.WaitRhs")(p);
        }
        else
        {
            if (auto m = tuple(`WaitRhs`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("wait"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, LoadType, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), "Tpl.WaitRhs"), "WaitRhs")(p);
                memo[tuple(`WaitRhs`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree WaitRhs(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("wait"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, LoadType, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), "Tpl.WaitRhs")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("wait"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, LoadType, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), "Tpl.WaitRhs"), "WaitRhs")(TParseTree("", false,[], s));
        }
    }
    static string WaitRhs(GetName g)
    {
        return "Tpl.WaitRhs";
    }

    static TParseTree CAS(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("CAS"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, LoadType, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, StoreType, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), "Tpl.CAS")(p);
        }
        else
        {
            if (auto m = tuple(`CAS`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("CAS"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, LoadType, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, StoreType, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), "Tpl.CAS"), "CAS")(p);
                memo[tuple(`CAS`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree CAS(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("CAS"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, LoadType, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, StoreType, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), "Tpl.CAS")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("CAS"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, LoadType, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, StoreType, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), "Tpl.CAS"), "CAS")(TParseTree("", false,[], s));
        }
    }
    static string CAS(GetName g)
    {
        return "Tpl.CAS";
    }

    static TParseTree Exchange(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("exchange"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, LoadType, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, StoreType, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), "Tpl.Exchange")(p);
        }
        else
        {
            if (auto m = tuple(`Exchange`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("exchange"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, LoadType, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, StoreType, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), "Tpl.Exchange"), "Exchange")(p);
                memo[tuple(`Exchange`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Exchange(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("exchange"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, LoadType, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, StoreType, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), "Tpl.Exchange")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("exchange"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, LoadType, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, StoreType, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), "Tpl.Exchange"), "Exchange")(TParseTree("", false,[], s));
        }
    }
    static string Exchange(GetName g)
    {
        return "Tpl.Exchange";
    }

    static TParseTree LoadStatement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Identifier, pegged.peg.discard!(pegged.peg.literal!(".load")), pegged.peg.discard!(pegged.peg.literal!("(")), pegged.peg.or!(LoadType, pegged.peg.discard!(Spacing)), pegged.peg.discard!(pegged.peg.literal!(")"))), "Tpl.LoadStatement")(p);
        }
        else
        {
            if (auto m = tuple(`LoadStatement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(Identifier, pegged.peg.discard!(pegged.peg.literal!(".load")), pegged.peg.discard!(pegged.peg.literal!("(")), pegged.peg.or!(LoadType, pegged.peg.discard!(Spacing)), pegged.peg.discard!(pegged.peg.literal!(")"))), "Tpl.LoadStatement"), "LoadStatement")(p);
                memo[tuple(`LoadStatement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree LoadStatement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Identifier, pegged.peg.discard!(pegged.peg.literal!(".load")), pegged.peg.discard!(pegged.peg.literal!("(")), pegged.peg.or!(LoadType, pegged.peg.discard!(Spacing)), pegged.peg.discard!(pegged.peg.literal!(")"))), "Tpl.LoadStatement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(Identifier, pegged.peg.discard!(pegged.peg.literal!(".load")), pegged.peg.discard!(pegged.peg.literal!("(")), pegged.peg.or!(LoadType, pegged.peg.discard!(Spacing)), pegged.peg.discard!(pegged.peg.literal!(")"))), "Tpl.LoadStatement"), "LoadStatement")(TParseTree("", false,[], s));
        }
    }
    static string LoadStatement(GetName g)
    {
        return "Tpl.LoadStatement";
    }

    static TParseTree NALoadStatement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Identifier, pegged.peg.discard!(pegged.peg.literal!(".naload")), pegged.peg.discard!(pegged.peg.literal!("(")), pegged.peg.discard!(Spacing), pegged.peg.discard!(pegged.peg.literal!(")"))), "Tpl.NALoadStatement")(p);
        }
        else
        {
            if (auto m = tuple(`NALoadStatement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(Identifier, pegged.peg.discard!(pegged.peg.literal!(".naload")), pegged.peg.discard!(pegged.peg.literal!("(")), pegged.peg.discard!(Spacing), pegged.peg.discard!(pegged.peg.literal!(")"))), "Tpl.NALoadStatement"), "NALoadStatement")(p);
                memo[tuple(`NALoadStatement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree NALoadStatement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Identifier, pegged.peg.discard!(pegged.peg.literal!(".naload")), pegged.peg.discard!(pegged.peg.literal!("(")), pegged.peg.discard!(Spacing), pegged.peg.discard!(pegged.peg.literal!(")"))), "Tpl.NALoadStatement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(Identifier, pegged.peg.discard!(pegged.peg.literal!(".naload")), pegged.peg.discard!(pegged.peg.literal!("(")), pegged.peg.discard!(Spacing), pegged.peg.discard!(pegged.peg.literal!(")"))), "Tpl.NALoadStatement"), "NALoadStatement")(TParseTree("", false,[], s));
        }
    }
    static string NALoadStatement(GetName g)
    {
        return "Tpl.NALoadStatement";
    }

    static TParseTree FADD(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("FADD"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, LoadType, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, StoreType, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), "Tpl.FADD")(p);
        }
        else
        {
            if (auto m = tuple(`FADD`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("FADD"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, LoadType, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, StoreType, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), "Tpl.FADD"), "FADD")(p);
                memo[tuple(`FADD`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree FADD(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("FADD"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, LoadType, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, StoreType, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), "Tpl.FADD")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("FADD"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, LoadType, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, StoreType, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), "Tpl.FADD"), "FADD")(TParseTree("", false,[], s));
        }
    }
    static string FADD(GetName g)
    {
        return "Tpl.FADD";
    }

    static TParseTree BCASStatement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("BCAS"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, LoadType, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, StoreType, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.BCASStatement")(p);
        }
        else
        {
            if (auto m = tuple(`BCASStatement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("BCAS"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, LoadType, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, StoreType, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.BCASStatement"), "BCASStatement")(p);
                memo[tuple(`BCASStatement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree BCASStatement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("BCAS"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, LoadType, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, StoreType, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.BCASStatement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("BCAS"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, LoadType, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, StoreType, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.BCASStatement"), "BCASStatement")(TParseTree("", false,[], s));
        }
    }
    static string BCASStatement(GetName g)
    {
        return "Tpl.BCASStatement";
    }

    static TParseTree WaitStatement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("wait"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, LoadType, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.WaitStatement")(p);
        }
        else
        {
            if (auto m = tuple(`WaitStatement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("wait"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, LoadType, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.WaitStatement"), "WaitStatement")(p);
                memo[tuple(`WaitStatement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree WaitStatement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("wait"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, LoadType, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.WaitStatement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("wait"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, LoadType, Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.WaitStatement"), "WaitStatement")(TParseTree("", false,[], s));
        }
    }
    static string WaitStatement(GetName g)
    {
        return "Tpl.WaitStatement";
    }

    static TParseTree FenceStatement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("fence"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, FenceType, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.FenceStatement")(p);
        }
        else
        {
            if (auto m = tuple(`FenceStatement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("fence"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, FenceType, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.FenceStatement"), "FenceStatement")(p);
                memo[tuple(`FenceStatement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree FenceStatement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("fence"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, FenceType, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.FenceStatement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("fence"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, FenceType, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.FenceStatement"), "FenceStatement")(TParseTree("", false,[], s));
        }
    }
    static string FenceStatement(GetName g)
    {
        return "Tpl.FenceStatement";
    }

    static TParseTree LockStatement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("lock"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.LockStatement")(p);
        }
        else
        {
            if (auto m = tuple(`LockStatement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("lock"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.LockStatement"), "LockStatement")(p);
                memo[tuple(`LockStatement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree LockStatement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("lock"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.LockStatement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("lock"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.LockStatement"), "LockStatement")(TParseTree("", false,[], s));
        }
    }
    static string LockStatement(GetName g)
    {
        return "Tpl.LockStatement";
    }

    static TParseTree UnlockStatement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("unlock"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.UnlockStatement")(p);
        }
        else
        {
            if (auto m = tuple(`UnlockStatement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("unlock"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.UnlockStatement"), "UnlockStatement")(p);
                memo[tuple(`UnlockStatement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree UnlockStatement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("unlock"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.UnlockStatement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("unlock"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.UnlockStatement"), "UnlockStatement")(TParseTree("", false,[], s));
        }
    }
    static string UnlockStatement(GetName g)
    {
        return "Tpl.UnlockStatement";
    }

    static TParseTree SkipStatement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("skip"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.SkipStatement")(p);
        }
        else
        {
            if (auto m = tuple(`SkipStatement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("skip"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.SkipStatement"), "SkipStatement")(p);
                memo[tuple(`SkipStatement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree SkipStatement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("skip"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.SkipStatement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("skip"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.SkipStatement"), "SkipStatement")(TParseTree("", false,[], s));
        }
    }
    static string SkipStatement(GetName g)
    {
        return "Tpl.SkipStatement";
    }

    static TParseTree AssertStatement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("assert"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing)), "Tpl.AssertStatement")(p);
        }
        else
        {
            if (auto m = tuple(`AssertStatement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("assert"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing)), "Tpl.AssertStatement"), "AssertStatement")(p);
                memo[tuple(`AssertStatement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree AssertStatement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("assert"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing)), "Tpl.AssertStatement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("assert"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing)), "Tpl.AssertStatement"), "AssertStatement")(TParseTree("", false,[], s));
        }
    }
    static string AssertStatement(GetName g)
    {
        return "Tpl.AssertStatement";
    }

    static TParseTree LoadType(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("rlx"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("acq"), Spacing)), "Tpl.LoadType")(p);
        }
        else
        {
            if (auto m = tuple(`LoadType`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("rlx"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("acq"), Spacing)), "Tpl.LoadType"), "LoadType")(p);
                memo[tuple(`LoadType`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree LoadType(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("rlx"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("acq"), Spacing)), "Tpl.LoadType")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("rlx"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("acq"), Spacing)), "Tpl.LoadType"), "LoadType")(TParseTree("", false,[], s));
        }
    }
    static string LoadType(GetName g)
    {
        return "Tpl.LoadType";
    }

    static TParseTree StoreType(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("rlx"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("rel"), Spacing)), "Tpl.StoreType")(p);
        }
        else
        {
            if (auto m = tuple(`StoreType`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("rlx"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("rel"), Spacing)), "Tpl.StoreType"), "StoreType")(p);
                memo[tuple(`StoreType`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree StoreType(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("rlx"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("rel"), Spacing)), "Tpl.StoreType")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("rlx"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("rel"), Spacing)), "Tpl.StoreType"), "StoreType")(TParseTree("", false,[], s));
        }
    }
    static string StoreType(GetName g)
    {
        return "Tpl.StoreType";
    }

    static TParseTree FenceType(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("acq_rel"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("acq"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("rel"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("seq_cst"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("upd"), Spacing)), "Tpl.FenceType")(p);
        }
        else
        {
            if (auto m = tuple(`FenceType`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("acq_rel"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("acq"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("rel"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("seq_cst"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("upd"), Spacing)), "Tpl.FenceType"), "FenceType")(p);
                memo[tuple(`FenceType`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree FenceType(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("acq_rel"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("acq"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("rel"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("seq_cst"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("upd"), Spacing)), "Tpl.FenceType")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("acq_rel"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("acq"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("rel"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("seq_cst"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("upd"), Spacing)), "Tpl.FenceType"), "FenceType")(TParseTree("", false,[], s));
        }
    }
    static string FenceType(GetName g)
    {
        return "Tpl.FenceType";
    }

    static TParseTree NonDeterministic(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("oneof"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("{"), Spacing)), pegged.peg.wrapAround!(Spacing, Statements, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}"), Spacing))), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.NonDeterministic")(p);
        }
        else
        {
            if (auto m = tuple(`NonDeterministic`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("oneof"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("{"), Spacing)), pegged.peg.wrapAround!(Spacing, Statements, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}"), Spacing))), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.NonDeterministic"), "NonDeterministic")(p);
                memo[tuple(`NonDeterministic`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree NonDeterministic(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("oneof"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("{"), Spacing)), pegged.peg.wrapAround!(Spacing, Statements, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}"), Spacing))), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.NonDeterministic")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("oneof"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("{"), Spacing)), pegged.peg.wrapAround!(Spacing, Statements, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}"), Spacing))), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "Tpl.NonDeterministic"), "NonDeterministic")(TParseTree("", false,[], s));
        }
    }
    static string NonDeterministic(GetName g)
    {
        return "Tpl.NonDeterministic";
    }

    static TParseTree IfStatement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("if"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("{"), Spacing), pegged.peg.wrapAround!(Spacing, Statements, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("else"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("{"), Spacing), pegged.peg.wrapAround!(Spacing, Statements, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}"), Spacing)), Spacing))), "Tpl.IfStatement")(p);
        }
        else
        {
            if (auto m = tuple(`IfStatement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("if"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("{"), Spacing), pegged.peg.wrapAround!(Spacing, Statements, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("else"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("{"), Spacing), pegged.peg.wrapAround!(Spacing, Statements, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}"), Spacing)), Spacing))), "Tpl.IfStatement"), "IfStatement")(p);
                memo[tuple(`IfStatement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree IfStatement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("if"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("{"), Spacing), pegged.peg.wrapAround!(Spacing, Statements, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("else"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("{"), Spacing), pegged.peg.wrapAround!(Spacing, Statements, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}"), Spacing)), Spacing))), "Tpl.IfStatement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("if"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("{"), Spacing), pegged.peg.wrapAround!(Spacing, Statements, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("else"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("{"), Spacing), pegged.peg.wrapAround!(Spacing, Statements, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}"), Spacing)), Spacing))), "Tpl.IfStatement"), "IfStatement")(TParseTree("", false,[], s));
        }
    }
    static string IfStatement(GetName g)
    {
        return "Tpl.IfStatement";
    }

    static TParseTree Identifier(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(pegged.peg.and!(Keyword, pegged.peg.oneOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.charRange!('0', '9'), pegged.peg.literal!("_")))), pegged.peg.and!(pegged.peg.negLookahead!(Keyword), pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.charRange!('0', '9'), pegged.peg.literal!("_")))))), "Tpl.Identifier")(p);
        }
        else
        {
            if (auto m = tuple(`Identifier`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(pegged.peg.and!(Keyword, pegged.peg.oneOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.charRange!('0', '9'), pegged.peg.literal!("_")))), pegged.peg.and!(pegged.peg.negLookahead!(Keyword), pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.charRange!('0', '9'), pegged.peg.literal!("_")))))), "Tpl.Identifier"), "Identifier")(p);
                memo[tuple(`Identifier`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Identifier(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(pegged.peg.and!(Keyword, pegged.peg.oneOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.charRange!('0', '9'), pegged.peg.literal!("_")))), pegged.peg.and!(pegged.peg.negLookahead!(Keyword), pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.charRange!('0', '9'), pegged.peg.literal!("_")))))), "Tpl.Identifier")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(pegged.peg.and!(Keyword, pegged.peg.oneOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.charRange!('0', '9'), pegged.peg.literal!("_")))), pegged.peg.and!(pegged.peg.negLookahead!(Keyword), pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.charRange!('0', '9'), pegged.peg.literal!("_")))))), "Tpl.Identifier"), "Identifier")(TParseTree("", false,[], s));
        }
    }
    static string Identifier(GetName g)
    {
        return "Tpl.Identifier";
    }

    static TParseTree Number(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.longest_match!(pegged.peg.and!(pegged.peg.charRange!('1', '9'), pegged.peg.zeroOrMore!(pegged.peg.charRange!('0', '9'))), pegged.peg.literal!("0"))), "Tpl.Number")(p);
        }
        else
        {
            if (auto m = tuple(`Number`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.longest_match!(pegged.peg.and!(pegged.peg.charRange!('1', '9'), pegged.peg.zeroOrMore!(pegged.peg.charRange!('0', '9'))), pegged.peg.literal!("0"))), "Tpl.Number"), "Number")(p);
                memo[tuple(`Number`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Number(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.longest_match!(pegged.peg.and!(pegged.peg.charRange!('1', '9'), pegged.peg.zeroOrMore!(pegged.peg.charRange!('0', '9'))), pegged.peg.literal!("0"))), "Tpl.Number")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.longest_match!(pegged.peg.and!(pegged.peg.charRange!('1', '9'), pegged.peg.zeroOrMore!(pegged.peg.charRange!('0', '9'))), pegged.peg.literal!("0"))), "Tpl.Number"), "Number")(TParseTree("", false,[], s));
        }
    }
    static string Number(GetName g)
    {
        return "Tpl.Number";
    }

    static TParseTree Keyword(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.keywords!("BCAS", "wait", "FADD", "CAS", "goto", "if", "else", "elif", "while", "until", "do", "assert", "fi", "local", "global", "lock", "unlock", "fence", "oneof", "exchange", "store", "load", "rlx", "acq", "rel", "acq_rel", "seq_cst", "print", "active", "assert", "atomic", "bit", "bool", "break", "byte", "chan", "d_step", "D_proctype", "do", "else", "empty", "enabled", "fi", "full", "goto", "hidden", "if", "init", "int", "len", "mtype", "nempty", "never", "nfull", "od", "of", "pc_value", "printf", "priority", "proctype", "provided", "run", "short", "skip", "timeout", "typedef", "unless", "unsigned", "xr", "xs", "skip"), "Tpl.Keyword")(p);
        }
        else
        {
            if (auto m = tuple(`Keyword`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.keywords!("BCAS", "wait", "FADD", "CAS", "goto", "if", "else", "elif", "while", "until", "do", "assert", "fi", "local", "global", "lock", "unlock", "fence", "oneof", "exchange", "store", "load", "rlx", "acq", "rel", "acq_rel", "seq_cst", "print", "active", "assert", "atomic", "bit", "bool", "break", "byte", "chan", "d_step", "D_proctype", "do", "else", "empty", "enabled", "fi", "full", "goto", "hidden", "if", "init", "int", "len", "mtype", "nempty", "never", "nfull", "od", "of", "pc_value", "printf", "priority", "proctype", "provided", "run", "short", "skip", "timeout", "typedef", "unless", "unsigned", "xr", "xs", "skip"), "Tpl.Keyword"), "Keyword")(p);
                memo[tuple(`Keyword`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Keyword(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.keywords!("BCAS", "wait", "FADD", "CAS", "goto", "if", "else", "elif", "while", "until", "do", "assert", "fi", "local", "global", "lock", "unlock", "fence", "oneof", "exchange", "store", "load", "rlx", "acq", "rel", "acq_rel", "seq_cst", "print", "active", "assert", "atomic", "bit", "bool", "break", "byte", "chan", "d_step", "D_proctype", "do", "else", "empty", "enabled", "fi", "full", "goto", "hidden", "if", "init", "int", "len", "mtype", "nempty", "never", "nfull", "od", "of", "pc_value", "printf", "priority", "proctype", "provided", "run", "short", "skip", "timeout", "typedef", "unless", "unsigned", "xr", "xs", "skip"), "Tpl.Keyword")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.keywords!("BCAS", "wait", "FADD", "CAS", "goto", "if", "else", "elif", "while", "until", "do", "assert", "fi", "local", "global", "lock", "unlock", "fence", "oneof", "exchange", "store", "load", "rlx", "acq", "rel", "acq_rel", "seq_cst", "print", "active", "assert", "atomic", "bit", "bool", "break", "byte", "chan", "d_step", "D_proctype", "do", "else", "empty", "enabled", "fi", "full", "goto", "hidden", "if", "init", "int", "len", "mtype", "nempty", "never", "nfull", "od", "of", "pc_value", "printf", "priority", "proctype", "provided", "run", "short", "skip", "timeout", "typedef", "unless", "unsigned", "xr", "xs", "skip"), "Tpl.Keyword"), "Keyword")(TParseTree("", false,[], s));
        }
    }
    static string Keyword(GetName g)
    {
        return "Tpl.Keyword";
    }

    static TParseTree Spacing(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.zeroOrMore!(pegged.peg.or!(space, endOfLine, Comment))), "Tpl.Spacing")(p);
        }
        else
        {
            if (auto m = tuple(`Spacing`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.zeroOrMore!(pegged.peg.or!(space, endOfLine, Comment))), "Tpl.Spacing"), "Spacing")(p);
                memo[tuple(`Spacing`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Spacing(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.zeroOrMore!(pegged.peg.or!(space, endOfLine, Comment))), "Tpl.Spacing")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.zeroOrMore!(pegged.peg.or!(space, endOfLine, Comment))), "Tpl.Spacing"), "Spacing")(TParseTree("", false,[], s));
        }
    }
    static string Spacing(GetName g)
    {
        return "Tpl.Spacing";
    }

    static TParseTree Comment(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.literal!("//"), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(endOfLine), pegged.peg.any)), endOfLine)), "Tpl.Comment")(p);
        }
        else
        {
            if (auto m = tuple(`Comment`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.literal!("//"), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(endOfLine), pegged.peg.any)), endOfLine)), "Tpl.Comment"), "Comment")(p);
                memo[tuple(`Comment`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Comment(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.literal!("//"), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(endOfLine), pegged.peg.any)), endOfLine)), "Tpl.Comment")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.literal!("//"), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(endOfLine), pegged.peg.any)), endOfLine)), "Tpl.Comment"), "Comment")(TParseTree("", false,[], s));
        }
    }
    static string Comment(GetName g)
    {
        return "Tpl.Comment";
    }

    static TParseTree IntegerLiteral(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.option!(Sign), Integer)), "Tpl.IntegerLiteral")(p);
        }
        else
        {
            if (auto m = tuple(`IntegerLiteral`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.option!(Sign), Integer)), "Tpl.IntegerLiteral"), "IntegerLiteral")(p);
                memo[tuple(`IntegerLiteral`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree IntegerLiteral(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.option!(Sign), Integer)), "Tpl.IntegerLiteral")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.option!(Sign), Integer)), "Tpl.IntegerLiteral"), "IntegerLiteral")(TParseTree("", false,[], s));
        }
    }
    static string IntegerLiteral(GetName g)
    {
        return "Tpl.IntegerLiteral";
    }

    static TParseTree Integer(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.oneOrMore!(digit)), "Tpl.Integer")(p);
        }
        else
        {
            if (auto m = tuple(`Integer`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.oneOrMore!(digit)), "Tpl.Integer"), "Integer")(p);
                memo[tuple(`Integer`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Integer(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.oneOrMore!(digit)), "Tpl.Integer")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.oneOrMore!(digit)), "Tpl.Integer"), "Integer")(TParseTree("", false,[], s));
        }
    }
    static string Integer(GetName g)
    {
        return "Tpl.Integer";
    }

    static TParseTree Sign(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.keywords!("-", "+"), "Tpl.Sign")(p);
        }
        else
        {
            if (auto m = tuple(`Sign`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.keywords!("-", "+"), "Tpl.Sign"), "Sign")(p);
                memo[tuple(`Sign`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Sign(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.keywords!("-", "+"), "Tpl.Sign")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.keywords!("-", "+"), "Tpl.Sign"), "Sign")(TParseTree("", false,[], s));
        }
    }
    static string Sign(GetName g)
    {
        return "Tpl.Sign";
    }

    static TParseTree PrimaryExpression(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.wrapAround!(Spacing, IntegerLiteral, Spacing), pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), "Tpl.PrimaryExpression")(p);
        }
        else
        {
            if (auto m = tuple(`PrimaryExpression`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.wrapAround!(Spacing, IntegerLiteral, Spacing), pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), "Tpl.PrimaryExpression"), "PrimaryExpression")(p);
                memo[tuple(`PrimaryExpression`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree PrimaryExpression(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.wrapAround!(Spacing, IntegerLiteral, Spacing), pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), "Tpl.PrimaryExpression")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.wrapAround!(Spacing, IntegerLiteral, Spacing), pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), "Tpl.PrimaryExpression"), "PrimaryExpression")(TParseTree("", false,[], s));
        }
    }
    static string PrimaryExpression(GetName g)
    {
        return "Tpl.PrimaryExpression";
    }

    static TParseTree PostfixExpression(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, PrimaryExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("["), Spacing), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("]"), Spacing)), Spacing))), "Tpl.PostfixExpression")(p);
        }
        else
        {
            if (auto m = tuple(`PostfixExpression`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, PrimaryExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("["), Spacing), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("]"), Spacing)), Spacing))), "Tpl.PostfixExpression"), "PostfixExpression")(p);
                memo[tuple(`PostfixExpression`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree PostfixExpression(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, PrimaryExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("["), Spacing), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("]"), Spacing)), Spacing))), "Tpl.PostfixExpression")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, PrimaryExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("["), Spacing), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("]"), Spacing)), Spacing))), "Tpl.PostfixExpression"), "PostfixExpression")(TParseTree("", false,[], s));
        }
    }
    static string PostfixExpression(GetName g)
    {
        return "Tpl.PostfixExpression";
    }

    static TParseTree UnaryExpression(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, PostfixExpression, Spacing), pegged.peg.and!(pegged.peg.wrapAround!(Spacing, UnaryOperator, Spacing), pegged.peg.wrapAround!(Spacing, UnaryExpression, Spacing))), "Tpl.UnaryExpression")(p);
        }
        else
        {
            if (auto m = tuple(`UnaryExpression`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, PostfixExpression, Spacing), pegged.peg.and!(pegged.peg.wrapAround!(Spacing, UnaryOperator, Spacing), pegged.peg.wrapAround!(Spacing, UnaryExpression, Spacing))), "Tpl.UnaryExpression"), "UnaryExpression")(p);
                memo[tuple(`UnaryExpression`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree UnaryExpression(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, PostfixExpression, Spacing), pegged.peg.and!(pegged.peg.wrapAround!(Spacing, UnaryOperator, Spacing), pegged.peg.wrapAround!(Spacing, UnaryExpression, Spacing))), "Tpl.UnaryExpression")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, PostfixExpression, Spacing), pegged.peg.and!(pegged.peg.wrapAround!(Spacing, UnaryOperator, Spacing), pegged.peg.wrapAround!(Spacing, UnaryExpression, Spacing))), "Tpl.UnaryExpression"), "UnaryExpression")(TParseTree("", false,[], s));
        }
    }
    static string UnaryExpression(GetName g)
    {
        return "Tpl.UnaryExpression";
    }

    static TParseTree UnaryOperator(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.literal!("-"), pegged.peg.literal!("+"), pegged.peg.literal!("!")), "Tpl.UnaryOperator")(p);
        }
        else
        {
            if (auto m = tuple(`UnaryOperator`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.literal!("-"), pegged.peg.literal!("+"), pegged.peg.literal!("!")), "Tpl.UnaryOperator"), "UnaryOperator")(p);
                memo[tuple(`UnaryOperator`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree UnaryOperator(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.literal!("-"), pegged.peg.literal!("+"), pegged.peg.literal!("!")), "Tpl.UnaryOperator")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.literal!("-"), pegged.peg.literal!("+"), pegged.peg.literal!("!")), "Tpl.UnaryOperator"), "UnaryOperator")(TParseTree("", false,[], s));
        }
    }
    static string UnaryOperator(GetName g)
    {
        return "Tpl.UnaryOperator";
    }

    static TParseTree MultiplicativeExpression(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, UnaryExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.literal!("*"), pegged.peg.literal!("%"), pegged.peg.literal!("/")), Spacing), pegged.peg.wrapAround!(Spacing, MultiplicativeExpression, Spacing)), Spacing))), "Tpl.MultiplicativeExpression")(p);
        }
        else
        {
            if (auto m = tuple(`MultiplicativeExpression`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, UnaryExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.literal!("*"), pegged.peg.literal!("%"), pegged.peg.literal!("/")), Spacing), pegged.peg.wrapAround!(Spacing, MultiplicativeExpression, Spacing)), Spacing))), "Tpl.MultiplicativeExpression"), "MultiplicativeExpression")(p);
                memo[tuple(`MultiplicativeExpression`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree MultiplicativeExpression(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, UnaryExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.literal!("*"), pegged.peg.literal!("%"), pegged.peg.literal!("/")), Spacing), pegged.peg.wrapAround!(Spacing, MultiplicativeExpression, Spacing)), Spacing))), "Tpl.MultiplicativeExpression")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, UnaryExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.literal!("*"), pegged.peg.literal!("%"), pegged.peg.literal!("/")), Spacing), pegged.peg.wrapAround!(Spacing, MultiplicativeExpression, Spacing)), Spacing))), "Tpl.MultiplicativeExpression"), "MultiplicativeExpression")(TParseTree("", false,[], s));
        }
    }
    static string MultiplicativeExpression(GetName g)
    {
        return "Tpl.MultiplicativeExpression";
    }

    static TParseTree AdditiveExpression(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, MultiplicativeExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.literal!("-"), pegged.peg.literal!("+")), Spacing), pegged.peg.wrapAround!(Spacing, AdditiveExpression, Spacing)), Spacing))), "Tpl.AdditiveExpression")(p);
        }
        else
        {
            if (auto m = tuple(`AdditiveExpression`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, MultiplicativeExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.literal!("-"), pegged.peg.literal!("+")), Spacing), pegged.peg.wrapAround!(Spacing, AdditiveExpression, Spacing)), Spacing))), "Tpl.AdditiveExpression"), "AdditiveExpression")(p);
                memo[tuple(`AdditiveExpression`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree AdditiveExpression(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, MultiplicativeExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.literal!("-"), pegged.peg.literal!("+")), Spacing), pegged.peg.wrapAround!(Spacing, AdditiveExpression, Spacing)), Spacing))), "Tpl.AdditiveExpression")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, MultiplicativeExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.literal!("-"), pegged.peg.literal!("+")), Spacing), pegged.peg.wrapAround!(Spacing, AdditiveExpression, Spacing)), Spacing))), "Tpl.AdditiveExpression"), "AdditiveExpression")(TParseTree("", false,[], s));
        }
    }
    static string AdditiveExpression(GetName g)
    {
        return "Tpl.AdditiveExpression";
    }

    static TParseTree RelationalExpression(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, AdditiveExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<="), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">="), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">"), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, RelationalExpression, Spacing)), Spacing))), "Tpl.RelationalExpression")(p);
        }
        else
        {
            if (auto m = tuple(`RelationalExpression`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, AdditiveExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<="), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">="), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">"), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, RelationalExpression, Spacing)), Spacing))), "Tpl.RelationalExpression"), "RelationalExpression")(p);
                memo[tuple(`RelationalExpression`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree RelationalExpression(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, AdditiveExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<="), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">="), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">"), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, RelationalExpression, Spacing)), Spacing))), "Tpl.RelationalExpression")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, AdditiveExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<="), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">="), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">"), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, RelationalExpression, Spacing)), Spacing))), "Tpl.RelationalExpression"), "RelationalExpression")(TParseTree("", false,[], s));
        }
    }
    static string RelationalExpression(GetName g)
    {
        return "Tpl.RelationalExpression";
    }

    static TParseTree EqualityExpression(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, RelationalExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("=="), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("!="), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, EqualityExpression, Spacing)), Spacing))), "Tpl.EqualityExpression")(p);
        }
        else
        {
            if (auto m = tuple(`EqualityExpression`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, RelationalExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("=="), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("!="), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, EqualityExpression, Spacing)), Spacing))), "Tpl.EqualityExpression"), "EqualityExpression")(p);
                memo[tuple(`EqualityExpression`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree EqualityExpression(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, RelationalExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("=="), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("!="), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, EqualityExpression, Spacing)), Spacing))), "Tpl.EqualityExpression")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, RelationalExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("=="), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("!="), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, EqualityExpression, Spacing)), Spacing))), "Tpl.EqualityExpression"), "EqualityExpression")(TParseTree("", false,[], s));
        }
    }
    static string EqualityExpression(GetName g)
    {
        return "Tpl.EqualityExpression";
    }

    static TParseTree ANDExpression(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, EqualityExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("&"), Spacing), pegged.peg.wrapAround!(Spacing, ANDExpression, Spacing)), Spacing))), "Tpl.ANDExpression")(p);
        }
        else
        {
            if (auto m = tuple(`ANDExpression`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, EqualityExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("&"), Spacing), pegged.peg.wrapAround!(Spacing, ANDExpression, Spacing)), Spacing))), "Tpl.ANDExpression"), "ANDExpression")(p);
                memo[tuple(`ANDExpression`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree ANDExpression(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, EqualityExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("&"), Spacing), pegged.peg.wrapAround!(Spacing, ANDExpression, Spacing)), Spacing))), "Tpl.ANDExpression")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, EqualityExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("&"), Spacing), pegged.peg.wrapAround!(Spacing, ANDExpression, Spacing)), Spacing))), "Tpl.ANDExpression"), "ANDExpression")(TParseTree("", false,[], s));
        }
    }
    static string ANDExpression(GetName g)
    {
        return "Tpl.ANDExpression";
    }

    static TParseTree ExclusiveORExpression(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, ANDExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("^"), Spacing), pegged.peg.wrapAround!(Spacing, ExclusiveORExpression, Spacing)), Spacing))), "Tpl.ExclusiveORExpression")(p);
        }
        else
        {
            if (auto m = tuple(`ExclusiveORExpression`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, ANDExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("^"), Spacing), pegged.peg.wrapAround!(Spacing, ExclusiveORExpression, Spacing)), Spacing))), "Tpl.ExclusiveORExpression"), "ExclusiveORExpression")(p);
                memo[tuple(`ExclusiveORExpression`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree ExclusiveORExpression(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, ANDExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("^"), Spacing), pegged.peg.wrapAround!(Spacing, ExclusiveORExpression, Spacing)), Spacing))), "Tpl.ExclusiveORExpression")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, ANDExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("^"), Spacing), pegged.peg.wrapAround!(Spacing, ExclusiveORExpression, Spacing)), Spacing))), "Tpl.ExclusiveORExpression"), "ExclusiveORExpression")(TParseTree("", false,[], s));
        }
    }
    static string ExclusiveORExpression(GetName g)
    {
        return "Tpl.ExclusiveORExpression";
    }

    static TParseTree InclusiveORExpression(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, ExclusiveORExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("|"), Spacing), pegged.peg.wrapAround!(Spacing, InclusiveORExpression, Spacing)), Spacing))), "Tpl.InclusiveORExpression")(p);
        }
        else
        {
            if (auto m = tuple(`InclusiveORExpression`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, ExclusiveORExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("|"), Spacing), pegged.peg.wrapAround!(Spacing, InclusiveORExpression, Spacing)), Spacing))), "Tpl.InclusiveORExpression"), "InclusiveORExpression")(p);
                memo[tuple(`InclusiveORExpression`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree InclusiveORExpression(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, ExclusiveORExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("|"), Spacing), pegged.peg.wrapAround!(Spacing, InclusiveORExpression, Spacing)), Spacing))), "Tpl.InclusiveORExpression")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, ExclusiveORExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("|"), Spacing), pegged.peg.wrapAround!(Spacing, InclusiveORExpression, Spacing)), Spacing))), "Tpl.InclusiveORExpression"), "InclusiveORExpression")(TParseTree("", false,[], s));
        }
    }
    static string InclusiveORExpression(GetName g)
    {
        return "Tpl.InclusiveORExpression";
    }

    static TParseTree LogicalANDExpression(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, InclusiveORExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("&&"), Spacing), pegged.peg.wrapAround!(Spacing, LogicalANDExpression, Spacing)), Spacing))), "Tpl.LogicalANDExpression")(p);
        }
        else
        {
            if (auto m = tuple(`LogicalANDExpression`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, InclusiveORExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("&&"), Spacing), pegged.peg.wrapAround!(Spacing, LogicalANDExpression, Spacing)), Spacing))), "Tpl.LogicalANDExpression"), "LogicalANDExpression")(p);
                memo[tuple(`LogicalANDExpression`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree LogicalANDExpression(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, InclusiveORExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("&&"), Spacing), pegged.peg.wrapAround!(Spacing, LogicalANDExpression, Spacing)), Spacing))), "Tpl.LogicalANDExpression")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, InclusiveORExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("&&"), Spacing), pegged.peg.wrapAround!(Spacing, LogicalANDExpression, Spacing)), Spacing))), "Tpl.LogicalANDExpression"), "LogicalANDExpression")(TParseTree("", false,[], s));
        }
    }
    static string LogicalANDExpression(GetName g)
    {
        return "Tpl.LogicalANDExpression";
    }

    static TParseTree LogicalORExpression(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, LogicalANDExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("||"), Spacing), pegged.peg.wrapAround!(Spacing, LogicalORExpression, Spacing)), Spacing))), "Tpl.LogicalORExpression")(p);
        }
        else
        {
            if (auto m = tuple(`LogicalORExpression`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, LogicalANDExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("||"), Spacing), pegged.peg.wrapAround!(Spacing, LogicalORExpression, Spacing)), Spacing))), "Tpl.LogicalORExpression"), "LogicalORExpression")(p);
                memo[tuple(`LogicalORExpression`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree LogicalORExpression(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, LogicalANDExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("||"), Spacing), pegged.peg.wrapAround!(Spacing, LogicalORExpression, Spacing)), Spacing))), "Tpl.LogicalORExpression")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, LogicalANDExpression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("||"), Spacing), pegged.peg.wrapAround!(Spacing, LogicalORExpression, Spacing)), Spacing))), "Tpl.LogicalORExpression"), "LogicalORExpression")(TParseTree("", false,[], s));
        }
    }
    static string LogicalORExpression(GetName g)
    {
        return "Tpl.LogicalORExpression";
    }

    static TParseTree Expression(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(LogicalORExpression, "Tpl.Expression")(p);
        }
        else
        {
            if (auto m = tuple(`Expression`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(LogicalORExpression, "Tpl.Expression"), "Expression")(p);
                memo[tuple(`Expression`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Expression(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(LogicalORExpression, "Tpl.Expression")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(LogicalORExpression, "Tpl.Expression"), "Expression")(TParseTree("", false,[], s));
        }
    }
    static string Expression(GetName g)
    {
        return "Tpl.Expression";
    }

    static TParseTree IdentifierList(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing)), Spacing))), "Tpl.IdentifierList")(p);
        }
        else
        {
            if (auto m = tuple(`IdentifierList`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing)), Spacing))), "Tpl.IdentifierList"), "IdentifierList")(p);
                memo[tuple(`IdentifierList`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree IdentifierList(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing)), Spacing))), "Tpl.IdentifierList")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), pegged.peg.wrapAround!(Spacing, Identifier, Spacing)), Spacing))), "Tpl.IdentifierList"), "IdentifierList")(TParseTree("", false,[], s));
        }
    }
    static string IdentifierList(GetName g)
    {
        return "Tpl.IdentifierList";
    }

    static TParseTree opCall(TParseTree p)
    {
        TParseTree result = decimateTree(Program(p));
        result.children = [result];
        result.name = "Tpl";
        return result;
    }

    static TParseTree opCall(string input)
    {
        if(__ctfe)
        {
            return Tpl(TParseTree(``, false, [], input, 0, 0));
        }
        else
        {
            forgetMemo();
            return Tpl(TParseTree(``, false, [], input, 0, 0));
        }
    }
    static string opCall(GetName g)
    {
        return "Tpl";
    }


    static void forgetMemo()
    {
        memo = null;
    }
    }
}

alias GenericTpl!(ParseTree).Tpl Tpl;

