# Toy Programming Language (TPL) - Syntax
This document explains the syntax of Rocker's input files.

## Introduction
Rocker's input files describe a parallel program consisting of a fixed number of threads.
Each thread is function working on some local and global variables.

Names of threads and variables can be any alphanumeric string that does not start with a number and isn't a reserved keyword.

At any point in line, one may use // to write a comment.
Comments start from // and end at EOL.

## Preamble
The program operates on a limited set of values. Default being 255. One can limit the maximal value by using the first optional line in the file:

```
max_value 7;
```

The first mandatory line is declaration of atomic variables used in the program.

```
global x, y, z=5;
```

A global may have a defined initial value as shown above. In case the variable is not initialized explicitly, it is initialized to 0.

One may declare non atomic variables by adding the following optional line after the global line.

```
na x=2, y;
```


## Functions
Each thread is defined as a function with the first line defining the locals. Similar to how globals are defined.
```
fn threadname{
	local r;
	...
}
```


## Statements
The following statements are available.
### Assignments
#### Expressions
Expressions are available only using local variables. They include the following operators as in C. `+` `-` `*` `/` `%` `<` `<=` `==` `=>` `>` `!=` `!`. Parenthesis `(` `)` are also available.`

For example:
```
t = a * 2 + 6 * b - 32;
```

#### Atomic global variables
To access atomic globals assuming `t` is a local and `x` is an atomic global the following syntax is available.
```
t = x.load();
x.store(t + 3);
```
##### Read-Modify-Write (RMW) operations
```
// Atomically increment x by 5.
FADD(x, 5); 
// Put the value of x in a. If x == before, set its value to after.
a = CAS(x, before, after); 
// Block until x == before, then change its value to after.
BCAS(x, before, after); 
// Put the value of x inside a and atomically write newval into x
a = exchange(x, newval); 
```
#### Non-Atomic global variables
To access non-atomic globals assuming `t` is a local and `x` is a non-atomic global the following syntax is available over the global atomic variable `lck`.
```
t = x.naload();
x.nastore(t + 3);
```
### Flow control
All conditionals work only on local variables. If you would like to condition on a global variables, you'll have to load it first in order to make the load statement explicit.
#### GOTO
The following syntax allows for jumping around the code.
```
labelname: t = 0;
if t == 0 goto labelname;
goto labelname;
```
#### If
```
if (t == 0) {
} else {
}
```
#### While
```
while (t == 0) {
}
```
### Fences, Locks and wait
#### Fence
To issue a fence use
```
fence;
```
#### Locks
Locks are available assuming value tracking is available.
```
lock(lck);
unlock(lck);
```

#### Wait
To block a thread until a value can be read from global atomic location use wait.
```
wait(x, 5);
a = wait(x, 2, 3, 5);
```

### Assertions
#### Assert
To assert a condition.
```
assert(a == 5);
```
#### Assume
Assume something happens. If the condition does not happen, this run of the thread is terminated.
```
assume(a == 5);
```
### No-op
For empty statements, use the `skip` statement.
```
skip;
```
### Non-determinism
For simulating random, you can use `oneof`. Which will result in only one block getting executed for each trace.
```
oneof(
	{
	...
	}
	{
		...
	}
);
```

