module instruments.config;
import pegged.grammar;

/**
  Configuration struct for instruments
  */
struct Config{
	const(string)[] vars;
	const(string)[] naVars;
	size_t threads;
	string moduloNumber;
	const ParseTree parseTree;
}
