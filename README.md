# Rocker - RObustness CheKER
> Rocker is a tool to verify robustness of programs written in TPL against C11 semantics.

## Prerequisites
* `dub`
* D compiler (`dmd` / `ldc` / `gdc`) 
* `dmd` (for `rdmd`)
* Spin verifier
* `gcc`

## Tested versions
* `dmd`		2.092.1
* `dub`		1.21.0
* `gcc`		10.1.0
* `spin`	6.5.2

### Archlinux
  - `pacman -S dub dmd dtools spin`

### Homebrew (macOS)
  - `brew install dub dmd spin`

------

The code was only tested under Linux (Archlinux) and macOS.

## Compilation
Simply run the following command in the project folder.

```sh
dub build --build=release
```

## Usage
The tool is made from two utilities.

- `tplspin` which transpiles TPL code to instrumented Promela.
- `spinify.d` which takes a TPL program, transforms it to Prolema and runs it through Spin.

```sh
./tplspin --help
./tplspin -i path/to/tpl.tpl -o path/to/promela.pml --memory rlx -m noScFence
```

```sh
./spinify.d --help
./spinify.d --robustness egr --memory rlx -m noScFence path/to/tpl/file.tpl
./spinify.d --robustness wegr --memory rlx -m obsNoFence path/to/tpl/file.tpl
```

### Available Memory Models

#### Sequential Consistency
Memory Model `sc`

Simple interleaving of the threads atomic commands with a shared atomic memory.

| Verification Mode | Description                                                    |
|-------------------|----------------------------------------------------------------|
| none              | No instrumentation is done as spin is already running under SC |

#### Release Acquire (C/C++ 11)
Memory Model `ra`

The Release Acquire semantics provided by C/C++ 11.

| Verification Mode | Description                                                                                                                              |
|-------------------|------------------------------------------------------------------------------------------------------------------------------------------|
| trackSome         | Tracks only specific values for specific variables. This is the mode defined in the paper "Robustness against Release/Acquire Semantics" |

#### RC20
Memory Model `rlx`

The repaired C/C++20 model.

| Verification Mode | Description                         |
|-------------------|-------------------------------------|
| noScFence         | Robustness under RC20               |
| obsNoFence        | Observational Robustness under RC20 |

### Robustness Definition

Multiple robustness definitions are available for the spinify tool. These are
used to make sure the expected robustness is found.

| Flag | Robustness               | Description                                                                                                              |
|------|--------------------------|--------------------------------------------------------------------------------------------------------------------------|
| egr  | Robustness               | Execution graph robustness - If all WMM-consistent graphs are also SC-consistent                                         |
| wegr | Observational Robustness | Observational robustness - If all WMM-consistent graphs can be transformed to SC-consistent by changing irrelevant reads |


## Usage example

Assume the program `sb.tpl` exists in the current folder.
```
// ROBUSTNESS egr: not: ra.
// ROBUSTNESS wegr: robust: ra.
max_value 2;
global x, y;

fn proca {
	local r;
	x.store(1);
	r = y.load();
}

fn procb {
	local r;
	y.store(1);
	r = x.load();
}
```

Running the program trough `./spinify.d` results in the following output:
```
$ ./spinify.d --robustness egr  --memory ra -m trackSome sb.tpl
Program	TPL	Spin	Compile	Pan	Res	Expected	#T	#LoC
sb.tpl	0.0	0.0	1.7	0.0	no	no	2	12
```

The output shows in TSV format the following information.

- Program name (or path)
- Time taken to transform the TPL program to a spin instrumented program
- Time taken to generate the verifier in C from Promela
- Compilation time of the verifier
- Time taken to run the verifier
- Whether or not the program is robust against the provided memory model
- The expected robustness of the program based on the first line comment in the TPL input
- Number of threads in the provided TPL program
- Lines of code in the provided TPL program

_For more examples and usage, please refer to doc/ folder._

