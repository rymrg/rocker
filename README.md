# Rocker - RObustness CheKER
> Rocker is a tool to verify robustness of programs written in TPL against RA semantics.

## Prerequisites
* `dub`
* D compiler (`dmd` / `ldc` / `gdc`) 
* `dmd` (for `rdmd`)
* Spin verifier
* `gcc`

## Tested versions
* `dmd`		2.084.0
* `dub`		1.13.0
* `gcc`		8.2.1
* `spin`	6.4.8

### Archlinux
  - `pacman -S dub dmd dtools`
  - Install `spin` from AUR
 
### Ubuntu
  - `apt-get install spin dub libphobos2-ldc-shared-dev libphobos2-ldc-shared78 ldc`
  - `snap install dmd --classic`

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
./tplspin -i path/to/tpl.tpl -o path/to/promela.pml --memory ra -m trackSome
```

```sh
./spinify.d --help
./spinify.d path/to/tpl/file.tpl
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

| Verification Mode   | Description                                                                                                                                                                 |
|---------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| trackSome           | Tracks only specific values for specific variables. This makes use of the optimization mentioned in the paper.                                                              |
| vra                 | Does not track any values                                                                                                                                                   |
| value               | Tracks all values for all variables.                                                                                                                                        |

## Usage example

Assume the program `sb.tpl` exists in the current folder.
```
// NOTROBUST
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
$ ./spinify.d --memory ra -m trackSome sb.tpl
Program	TPL	Spin	Compile	Pan	Res	Expected	#T	#LoC
sb.tpl	0.0	0.0	1.7	0.0	no	no	2	12
```

The output shows in TSV format the following information.

- Program name (or path)
- Time taken to transform the TPL program to a spin instrumented program
- Time taken to generate the verifer in C from Promela
- Compliation time of the verifier
- Time taken to run the verifier
- Whether or not the program is robust against the provided memory model
- The expected robustness of the program based on the first line comment in the TPL input
- Number of threads in the provided TPL program
- Lines of code in the provided TPL program

_For more examples and usage, please refer to doc/ folder._

