--------------
What's inside?
--------------

Rocker is a robustness checker tool that implements the technique developed in
the paper:
	Verifying Observational Robustness Against a C11-style Memory Model
    Authors: Roy Margalit and Ori Lahav (Tel Aviv University)

This package extends Rocker first introduced in:
	Robustness Against Release/Acquire Semantics
    Authors: Ori Lahav and Roy Margalit (Tel Aviv University)

Rocker has different running modes based on the memory model used:

A) sc: Sequential Consistency
	- none: No robustness instrumentation. This is used for verifying all traces
			(under SC semantics) of the program without any instrumentation.

B) ra: Release/Acquire
	- trackSome: Final optimized version from the paper:
			Robustness Against Release/Acquire Semantics

C) rlx: Release/Acquire + Relaxed access
	- strongScFence: Extended support for relaxed access and release/acquire
			fences SC fences are implemented using Release/Acquire and RMW and
			thus have stronger semantics than in RC11.
	- obsStrongFence: Observational Robustness.
			SC fences are implemented using Release/Acquire and RMW and thus
			have stronger semantics than in RC11.

---------------
Getting Started
---------------

A detailed README is available in markdown format in (README.md).
Henceforth, this README assumes that the archive was extracted to the folder $PWD.

First install the following software: dmd, dub, spin & gcc.
We tested Rocker with the following versions:
* dmd		2.092.1
* dub		1.21.0
* spin		6.5.2
* gcc		10.1.0


In order to build Rocker, execute the following command in $PWD:
dub build --build=release

Once Rocker is built, you may run the litmus tests to make sure everything 
works correctly by executing the following commands in $PWD:
```sh
./spinify.d --robustness wegr --memory rlx -m obsStrongFence examples/submission/obs/*.tpl 
./spinify.d --robustness egr --memory rlx -m strongScFence examples/submission/obs/*.tpl 
./spinify.d --robustness egr --memory sc -m none examples/submission/obs/*.tpl 2> /dev/null # Masking warnings as no markings are done for SC. They are all robust under SC.
```

The expected output is available in a later segment of this README.

-------------------------
Step-by-Step Instructions
-------------------------

Rocker's output is a TSV file containing the following columns:
Program 	- Path to the program.
TPL			- Time spent by Rocker transforming TPL to instrumented Promela.
Spin		- Time spent by Spin creating the C Verifier from Promela.
Compile		- Compilation time of the verifier.
Pan			- Time spent running the verifier.
Res			- Robustness of the program in current mode.
Expected	- Expected robustness for the program under RA.
#T			- Number of threads in the input program.
#LoC		- Lines of code in the input program.

The benchmarks table in §6 Figure 6 of the paper has the following columns:
Program		- The name of the program without extension
#T			- Number of threads in the program.  It is shown as the #T column
				in Rocker's output.
LoC			- Lines of code in the input program. It is shown as #LoC in
				Rocker's output.
Rob			- A mark showing if the robustness is
			  This is derived from the column Res in Rocker's output given the
			  appropriate flag.
Time		- The duration of compilation and running of the verifier created 
				by Spin. This is the sum of the Compile and Pan columns in
				Rocker's output. The number in the parenthesis is the percentage
				of this time used for compiling, i.e., 
				(compile / (compile + pan)) * 100.
				The time spent by Rocker to create an instrumented Promela
				program and by Spin to create the C verifier is negligible and 
				thus ignored.

The sub columns for Time and Rob specify the following:
- R - Robustness, running rlx model with strongScFence
- O - Observational Robust, running rlx model with obsStrongFence
- SC - Sequential Consistency, running with no instrumentation by rocker


Program		- The name of the program without extension
#T			- Number of threads in the program.  It is shown as the #T column
				in Rocker's output.
LoC			- Lines of code in the input program. It is shown as #LoC in
				Rocker's output.
Rob			- A mark showing if the robustness is
			  This is derived from the column Res in Rocker's output given the
			  appropriate flag.
Time		- The duration of compilation and running of the verifier created 
				by Spin. This is the sum of the Compile and Pan columns in
				Rocker's output. The number in the parenthesis is the percentage
				of this time used for compiling, i.e., 
				(compile / (compile + pan)) * 100.
				The time spent by Rocker to create an instrumented Promela
				program and by Spin to create the C verifier is negligible and 
				thus ignored.

The examples in this benchmarks table are available in examples/submission/obs.

Comparing to RA:
The columns in §6 Figure 7 have the same meaning as in Figure 6.
All the examples are robust and thus no robustness mark is provided.
The column Rocker stands for running Rocker with its old release/acquire model.

The examples in this benchmarks table are available in examples/submission/ra.

Reference output is available farther ahead in this README.


Reproducing the benchmarks requires running the obs examples with Rocker
against RLX with the strongScFence and obsStrongFence modes, and against SC with the
none mode.  For SC only the time spent compiling and verifying is used.  In
addition, for the ra examples, it is required to run strongScFence, obsStrongFence
under rlx, and trackSome under ra.

In $PWD run the following for benchmarking against C20.

./spinify.d --robustness wegr --memory rlx -m obsStrongFence examples/submission/obs/*.tpl 
./spinify.d --robustness egr --memory rlx -m strongScFence examples/submission/obs/*.tpl 
./spinify.d --robustness egr --memory sc -m none examples/submission/obs/*.tpl 2> /dev/null # Masking warnings


In $PWD run the following for benchmarking against RA.

./spinify.d --robustness egr --memory rlx -m strongScFence examples/submission/ra/*.tpl
./spinify.d --robustness wegr --memory rlx -m obsStrongFence examples/submission/ra/*.tpl
./spinify.d --robustness egr --memory ra -m trackSome examples/submission/ra/*.tpl


The output format was explained earlier and is explained in a more complete
manner in (README.md). You may compare your results from running the tool to
the output provided later in this README.


You may write your own programs and check for their robustness against C11.
Please consult README.md and the docs/ folder. An explanation of the input
syntax is available there.



---------------
Expected Output
---------------

Please note;
* Rocker's output is TSV (Tab Separated Values). Extra tabs were
	added to this README in order to make the output easier to read.
* Time may vary based on the machine and compiler.

Submission items (Relaxed)
---------------------

/spinify.d --robustness wegr --memory rlx -m obsStrongFence examples/submission/obs/*.tpl 
Program                                      	 TPL 	 Spin 	 Compile 	 Pan  	 Res 	 Expected 	 #T 	 #LoC
examples/submission/obs/arc.tpl              	 0.1 	 0.1  	 5.6     	 64.0 	 yes 	 yes      	 3  	 102
examples/submission/obs/chase-lev.tpl        	 0.0 	 0.0  	 1.6     	 56.4 	 yes 	 yes      	 3  	 63
examples/submission/obs/dekker-rlx.tpl       	 0.0 	 0.0  	 1.8     	 0.0  	 yes 	 yes      	 2  	 61
examples/submission/obs/lock_exchange.tpl    	 0.0 	 0.0  	 1.1     	 0.0  	 yes 	 yes      	 2  	 28
examples/submission/obs/peterson-fix1.tpl    	 0.0 	 0.0  	 1.2     	 0.0  	 yes 	 yes      	 2  	 37
examples/submission/obs/peterson-fix2.tpl    	 0.0 	 0.0  	 1.3     	 0.0  	 yes 	 yes      	 2  	 39
examples/submission/obs/peterson.tpl         	 0.0 	 0.0  	 1.3     	 0.0  	 no  	 no       	 2  	 37
examples/submission/obs/seqlock_fence-rw.tpl 	 0.0 	 0.2  	 6.8     	 65.5 	 yes 	 yes      	 3  	 87
examples/submission/obs/seqlock_fence.tpl    	 0.0 	 0.2  	 8.0     	 69.5 	 yes 	 yes      	 3  	 90
examples/submission/obs/seqlock_rdmw-rw.tpl  	 0.0 	 0.2  	 6.6     	 44.3 	 yes 	 yes      	 3  	 81
examples/submission/obs/seqlock_rdmw.tpl     	 0.0 	 0.2  	 7.2     	 51.6 	 yes 	 yes      	 3  	 84
examples/submission/obs/singleton-rlx.tpl    	 0.0 	 0.0  	 2.9     	 0.1  	 yes 	 yes      	 4  	 147
examples/submission/obs/singleton.tpl        	 0.0 	 0.0  	 2.8     	 0.1  	 yes 	 yes      	 4  	 139
examples/submission/obs/spinlock4-rlx.tpl    	 0.0 	 0.0  	 1.7     	 4.2  	 yes 	 yes      	 4  	 71
examples/submission/obs/wait-free-ring.tpl   	 0.0 	 0.0  	 1.0     	 0.0  	 yes 	 yes      	 2  	 28

$ ./spinify.d --robustness egr --memory rlx -m strongScFence examples/submission/obs/*.tpl 
Program                                      	 TPL 	 Spin 	 Compile 	 Pan  	 Res 	 Expected 	 #T 	 #LoC
examples/submission/obs/arc.tpl              	 0.0 	 0.1  	 5.3     	 62.7 	 yes 	 yes      	 3  	 102
examples/submission/obs/chase-lev.tpl        	 0.0 	 0.0  	 1.4     	 56.8 	 yes 	 yes      	 3  	 63
examples/submission/obs/dekker-rlx.tpl       	 0.0 	 0.0  	 1.7     	 0.0  	 yes 	 yes      	 2  	 61
examples/submission/obs/lock_exchange.tpl    	 0.0 	 0.0  	 1.1     	 0.0  	 yes 	 yes      	 2  	 28
examples/submission/obs/peterson-fix1.tpl    	 0.0 	 0.0  	 1.2     	 0.0  	 yes 	 yes      	 2  	 37
examples/submission/obs/peterson-fix2.tpl    	 0.0 	 0.0  	 1.2     	 0.0  	 yes 	 yes      	 2  	 39
examples/submission/obs/peterson.tpl         	 0.0 	 0.0  	 1.2     	 0.0  	 no  	 no       	 2  	 37
examples/submission/obs/seqlock_fence-rw.tpl 	 0.0 	 0.2  	 6.9     	 0.0  	 no  	 no       	 3  	 87
examples/submission/obs/seqlock_fence.tpl    	 0.0 	 0.2  	 8.7     	 0.0  	 no  	 no       	 3  	 90
examples/submission/obs/seqlock_rdmw-rw.tpl  	 0.0 	 0.2  	 6.7     	 0.0  	 no  	 no       	 3  	 81
examples/submission/obs/seqlock_rdmw.tpl     	 0.0 	 0.2  	 7.5     	 0.0  	 no  	 no       	 3  	 84
examples/submission/obs/singleton-rlx.tpl    	 0.0 	 0.0  	 2.9     	 0.1  	 yes 	 yes      	 4  	 147
examples/submission/obs/singleton.tpl        	 0.0 	 0.0  	 2.8     	 0.1  	 yes 	 yes      	 4  	 139
examples/submission/obs/spinlock4-rlx.tpl    	 0.0 	 0.0  	 1.7     	 3.8  	 yes 	 yes      	 4  	 71
examples/submission/obs/wait-free-ring.tpl   	 0.0 	 0.0  	 0.9     	 0.0  	 yes 	 yes      	 2  	 28

./spinify.d --robustness egr --memory sc -m none examples/submission/obs/*.tpl 2> /dev/null # Masking warnings
Program                                      	 TPL 	 Spin 	 Compile 	 Pan  	 Res 	 Expected 	 #T 	 #LoC
examples/submission/obs/arc.tpl              	 0.0 	 0.0  	 1.0     	 3.1  	 yes 	 unknown  	 3  	 102
examples/submission/obs/chase-lev.tpl        	 0.0 	 0.0  	 0.9     	 26.0 	 yes 	 unknown  	 3  	 63
examples/submission/obs/dekker-rlx.tpl       	 0.0 	 0.0  	 0.9     	 0.0  	 yes 	 unknown  	 2  	 61
examples/submission/obs/lock_exchange.tpl    	 0.0 	 0.0  	 0.9     	 0.0  	 yes 	 unknown  	 2  	 28
examples/submission/obs/peterson-fix1.tpl    	 0.0 	 0.0  	 0.9     	 0.0  	 yes 	 unknown  	 2  	 37
examples/submission/obs/peterson-fix2.tpl    	 0.0 	 0.0  	 0.9     	 0.0  	 yes 	 unknown  	 2  	 39
examples/submission/obs/peterson.tpl         	 0.0 	 0.0  	 0.9     	 0.0  	 yes 	 unknown  	 2  	 37
examples/submission/obs/seqlock_fence-rw.tpl 	 0.0 	 0.0  	 1.0     	 39.7 	 yes 	 unknown  	 3  	 87
examples/submission/obs/seqlock_fence.tpl    	 0.0 	 0.0  	 1.1     	 38.9 	 yes 	 unknown  	 3  	 90
examples/submission/obs/seqlock_rdmw-rw.tpl  	 0.0 	 0.0  	 1.0     	 30.8 	 yes 	 unknown  	 3  	 81
examples/submission/obs/seqlock_rdmw.tpl     	 0.0 	 0.0  	 1.0     	 29.4 	 yes 	 unknown  	 3  	 84
examples/submission/obs/singleton-rlx.tpl    	 0.0 	 0.0  	 1.1     	 0.0  	 yes 	 unknown  	 4  	 147
examples/submission/obs/singleton.tpl        	 0.0 	 0.0  	 1.1     	 0.0  	 yes 	 unknown  	 4  	 139
examples/submission/obs/spinlock4-rlx.tpl    	 0.0 	 0.0  	 1.0     	 0.3  	 yes 	 unknown  	 4  	 71
examples/submission/obs/wait-free-ring.tpl   	 0.0 	 0.0  	 0.9     	 0.0  	 yes 	 unknown  	 2  	 28


Submission items (RA)
---------------------

$ ./spinify.d --robustness egr --memory rlx -m strongScFence examples/submission/ra/*.tpl
Program                                 	 TPL 	 Spin 	 Compile 	 Pan   	 Res 	 Expected 	 #T 	 #LoC
examples/submission/ra/chase-lev-ra.tpl 	 0.0 	 0.0  	 1.5     	 59.5  	 yes 	 yes      	 3  	 61
examples/submission/ra/dekker-ra.tpl    	 0.0 	 0.0  	 1.4     	 0.0   	 yes 	 yes      	 2  	 49
examples/submission/ra/lamport2-3.tpl   	 0.0 	 0.1  	 10.4    	 92.8  	 yes 	 yes      	 3  	 123
examples/submission/ra/peterson-ra.tpl  	 0.0 	 0.0  	 1.2     	 0.0   	 yes 	 yes      	 2  	 37
examples/submission/ra/rcu-offline.tpl  	 0.0 	 0.2  	 10.2    	 67.8  	 yes 	 yes      	 3  	 215
examples/submission/ra/rcu.tpl          	 0.0 	 0.0  	 4.3     	 143.2 	 yes 	 yes      	 4  	 75
examples/submission/ra/seqlock-ra.tpl   	 0.1 	 0.4  	 6.2     	 54.4  	 yes 	 yes      	 3  	 81
examples/submission/ra/spinlock4-ra.tpl 	 0.0 	 0.0  	 1.4     	 0.8   	 yes 	 yes      	 4  	 66
examples/submission/ra/ticketlock4.tpl  	 0.0 	 0.0  	 1.5     	 10.4  	 yes 	 yes      	 4  	 50

$ ./spinify.d --robustness wegr --memory rlx -m obsStrongFence examples/submission/ra/*.tpl
Program                                 	 TPL 	 Spin 	 Compile 	 Pan   	 Res 	 Expected 	 #T 	 #LoC
examples/submission/ra/chase-lev-ra.tpl 	 0.0 	 0.0  	 1.5     	 55.3  	 yes 	 yes      	 3  	 61
examples/submission/ra/dekker-ra.tpl    	 0.0 	 0.0  	 1.4     	 0.0   	 yes 	 yes      	 2  	 49
examples/submission/ra/lamport2-3.tpl   	 0.0 	 0.1  	 9.6     	 86.1  	 yes 	 yes      	 3  	 123
examples/submission/ra/peterson-ra.tpl  	 0.0 	 0.0  	 1.2     	 0.0   	 yes 	 yes      	 2  	 37
examples/submission/ra/rcu-offline.tpl  	 0.1 	 0.2  	 10.5    	 66.9  	 yes 	 yes      	 3  	 215
examples/submission/ra/rcu.tpl          	 0.0 	 0.0  	 3.8     	 144.1 	 yes 	 yes      	 4  	 75
examples/submission/ra/seqlock-ra.tpl   	 0.0 	 0.4  	 6.1     	 56.1  	 yes 	 yes      	 3  	 81
examples/submission/ra/spinlock4-ra.tpl 	 0.0 	 0.0  	 1.4     	 1.0   	 yes 	 yes      	 4  	 66
examples/submission/ra/ticketlock4.tpl  	 0.0 	 0.0  	 1.5     	 10.4  	 yes 	 yes      	 4  	 50


$ ./spinify.d --robustness egr --memory ra -m trackSome examples/submission/ra/*.tpl
Program                                 	 TPL 	 Spin 	 Compile 	 Pan  	 Res 	 Expected 	 #T 	 #LoC
examples/submission/ra/chase-lev-ra.tpl 	 0.0 	 0.0  	 1.1     	 39.4 	 yes 	 yes      	 3  	 61
examples/submission/ra/dekker-ra.tpl    	 0.0 	 0.0  	 1.1     	 0.0  	 yes 	 yes      	 2  	 49
examples/submission/ra/lamport2-3.tpl   	 0.0 	 0.1  	 5.4     	 64.4 	 yes 	 yes      	 3  	 123
examples/submission/ra/peterson-ra.tpl  	 0.0 	 0.0  	 1.0     	 0.0  	 yes 	 yes      	 2  	 37
examples/submission/ra/rcu-offline.tpl  	 0.1 	 0.1  	 7.2     	 53.9 	 yes 	 yes      	 3  	 215
examples/submission/ra/rcu.tpl          	 0.0 	 0.0  	 1.9     	 50.6 	 yes 	 yes      	 4  	 75
examples/submission/ra/seqlock-ra.tpl   	 0.0 	 0.1  	 4.6     	 50.8 	 yes 	 yes      	 3  	 81
examples/submission/ra/spinlock4-ra.tpl 	 0.0 	 0.0  	 1.3     	 0.8  	 yes 	 yes      	 4  	 66
examples/submission/ra/ticketlock4.tpl  	 0.0 	 0.0  	 1.3     	 10.1 	 yes 	 yes      	 4  	 50






Litmus
------

 $ ./spinify.d --robustness egr --memory ra -m trackSome examples/litmus/ra/*.tpl
Program                                 	 TPL 	 Spin 	 Compile 	 Pan 	 Res 	 Expected 	 #T 	 #LoC
examples/litmus/ra/2p2w.tpl             	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 2  	 10
examples/litmus/ra/2p2w_print2.tpl      	 0.0 	 0.0  	 0.8     	 0.0 	 yes 	 yes      	 2  	 14
examples/litmus/ra/2p2wp2r.tpl          	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 2  	 14
examples/litmus/ra/accesstype.tpl       	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 2  	 14
examples/litmus/ra/assert.tpl           	 0.0 	 0.0  	 0.8     	 0.0 	 yes 	 yes      	 1  	 6
examples/litmus/ra/assert2.tpl          	 0.0 	 0.0  	 0.8     	 0.0 	 yes 	 yes      	 1  	 6
examples/litmus/ra/assume.tpl           	 0.0 	 0.0  	 1.0     	 0.0 	 yes 	 yes      	 2  	 19
examples/litmus/ra/bar-loop.tpl         	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 2  	 15
examples/litmus/ra/bcas-test.tpl        	 0.0 	 0.0  	 0.8     	 0.0 	 yes 	 yes      	 1  	 7
examples/litmus/ra/bcas.tpl             	 0.0 	 0.0  	 0.9     	 0.0 	 yes 	 yes      	 2  	 14
examples/litmus/ra/bcas_goto.tpl        	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 2  	 17
examples/litmus/ra/cas.tpl              	 0.0 	 0.0  	 0.9     	 0.0 	 yes 	 yes      	 2  	 13
examples/litmus/ra/corr2.tpl            	 0.0 	 0.0  	 0.9     	 0.0 	 yes 	 yes      	 4  	 18
examples/litmus/ra/fadd-test.tpl        	 0.0 	 0.0  	 1.3     	 0.0 	 no  	 no       	 5  	 32
examples/litmus/ra/fttest.tpl           	 0.0 	 0.0  	 0.9     	 0.0 	 yes 	 yes      	 2  	 14
examples/litmus/ra/if.tpl               	 0.0 	 0.0  	 0.9     	 0.0 	 yes 	 yes      	 1  	 19
examples/litmus/ra/if_p.tpl             	 0.0 	 0.0  	 1.0     	 0.0 	 no  	 no       	 3  	 22
examples/litmus/ra/if_p2.tpl            	 0.0 	 0.0  	 1.0     	 0.0 	 no  	 no       	 3  	 22
examples/litmus/ra/iriw.tpl             	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 4  	 19
examples/litmus/ra/iriw_1f.tpl          	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 4  	 20
examples/litmus/ra/iriw_1f_weak.tpl     	 0.0 	 0.0  	 1.0     	 0.0 	 no  	 no       	 4  	 19
examples/litmus/ra/iriw_2f.tpl          	 0.0 	 0.0  	 1.0     	 0.0 	 yes 	 yes      	 4  	 20
examples/litmus/ra/iriw_weak.tpl        	 0.0 	 0.0  	 1.0     	 0.0 	 no  	 no       	 4  	 18
examples/litmus/ra/lock.tpl             	 0.0 	 0.0  	 0.9     	 0.0 	 yes 	 yes      	 2  	 16
examples/litmus/ra/lock_order.tpl       	 0.0 	 0.0  	 1.1     	 0.0 	 yes 	 yes      	 2  	 14
examples/litmus/ra/lock_test.tpl        	 0.0 	 0.0  	 1.1     	 0.0 	 yes 	 yes      	 2  	 16
examples/litmus/ra/mcs-lock.tpl         	 0.0 	 0.0  	 2.7     	 0.0 	 yes 	 yes      	 2  	 68
examples/litmus/ra/mfa.tpl              	 0.0 	 0.0  	 1.0     	 0.0 	 no  	 no       	 3  	 19
examples/litmus/ra/mo_so.tpl            	 0.0 	 0.0  	 1.1     	 0.0 	 no  	 no       	 3  	 19
examples/litmus/ra/mp.tpl               	 0.0 	 0.0  	 0.9     	 0.0 	 yes 	 yes      	 2  	 11
examples/litmus/ra/mp_cas.tpl           	 0.0 	 0.0  	 1.0     	 0.0 	 yes 	 yes      	 2  	 12
examples/litmus/ra/mp_na.tpl            	 0.0 	 0.0  	 0.9     	 0.0 	 yes 	 yes      	 2  	 15
examples/litmus/ra/mp_na2.tpl           	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 2  	 12
examples/litmus/ra/mp_write.tpl         	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 2  	 12
examples/litmus/ra/na-rr1.tpl           	 0.0 	 0.0  	 0.9     	 0.0 	 yes 	 yes      	 2  	 14
examples/litmus/ra/na-rr2.tpl           	 0.0 	 0.0  	 0.9     	 0.0 	 yes 	 yes      	 2  	 10
examples/litmus/ra/na-wr1.tpl           	 0.0 	 0.0  	 0.9     	 0.0 	 yes 	 yes      	 2  	 14
examples/litmus/ra/na-wr2.tpl           	 0.0 	 0.0  	 0.8     	 0.0 	 no  	 no       	 2  	 10
examples/litmus/ra/na-ww1.tpl           	 0.0 	 0.0  	 0.9     	 0.0 	 yes 	 yes      	 2  	 14
examples/litmus/ra/na-ww2.tpl           	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 2  	 10
examples/litmus/ra/nondeterministic.tpl 	 0.0 	 0.0  	 0.9     	 0.0 	 yes 	 yes      	 1  	 12
examples/litmus/ra/peterson-ninjalj.tpl 	 0.0 	 0.0  	 1.2     	 0.0 	 no  	 no       	 2  	 40
examples/litmus/ra/rmw-basic.tpl        	 0.0 	 0.0  	 0.9     	 0.0 	 yes 	 yes      	 2  	 10
examples/litmus/ra/sb.tpl               	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 2  	 13
examples/litmus/ra/sb_3rmw.tpl          	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 2  	 12
examples/litmus/ra/sb_3rmw_2.tpl        	 0.0 	 0.0  	 0.9     	 0.0 	 yes 	 yes      	 2  	 12
examples/litmus/ra/sb_3rmw_3.tpl        	 0.0 	 0.0  	 0.9     	 0.0 	 yes 	 yes      	 2  	 12
examples/litmus/ra/sb_3way.tpl          	 0.0 	 0.0  	 1.2     	 0.0 	 no  	 no       	 3  	 23
examples/litmus/ra/sb_3way2.tpl         	 0.0 	 0.0  	 1.0     	 0.0 	 no  	 no       	 3  	 22
examples/litmus/ra/sb_3way3.tpl         	 0.0 	 0.0  	 1.1     	 0.0 	 no  	 no       	 3  	 26
examples/litmus/ra/sb_3way4.tpl         	 0.0 	 0.0  	 1.0     	 0.0 	 no  	 no       	 3  	 19
examples/litmus/ra/sb_3way5.tpl         	 0.0 	 0.0  	 1.0     	 0.0 	 no  	 no       	 3  	 22
examples/litmus/ra/sb_4rmw.tpl          	 0.0 	 0.0  	 0.9     	 0.0 	 yes 	 yes      	 2  	 12
examples/litmus/ra/sb_cas.tpl           	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 2  	 13
examples/litmus/ra/sb_cas1.tpl          	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 2  	 13
examples/litmus/ra/sb_cas2.tpl          	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 2  	 14
examples/litmus/ra/sb_cas3.tpl          	 0.0 	 0.0  	 1.0     	 0.0 	 no  	 no       	 2  	 14
examples/litmus/ra/sb_interleaved.tpl   	 0.0 	 0.0  	 1.1     	 0.0 	 no  	 no       	 4  	 25
examples/litmus/ra/sb_rmw.tpl           	 0.0 	 0.0  	 1.0     	 0.0 	 yes 	 yes      	 2  	 15
examples/litmus/ra/sb_rmw_2.tpl         	 0.0 	 0.0  	 0.9     	 0.0 	 yes 	 yes      	 2  	 14
examples/litmus/ra/sb_t.tpl             	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 2  	 13
examples/litmus/ra/sb_t2.tpl            	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 2  	 15
examples/litmus/ra/sb_t2_1.tpl          	 0.0 	 0.0  	 1.0     	 0.0 	 no  	 no       	 3  	 20
examples/litmus/ra/sb_t2_2.tpl          	 0.0 	 0.0  	 1.0     	 0.0 	 no  	 no       	 3  	 20
examples/litmus/ra/sb_t3.tpl            	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 2  	 15
examples/litmus/ra/sb_t4.tpl            	 0.0 	 0.0  	 1.0     	 0.0 	 no  	 no       	 2  	 16
examples/litmus/ra/sb_t5.tpl            	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 3  	 16
examples/litmus/ra/sb_t6.tpl            	 0.0 	 0.0  	 1.0     	 0.0 	 no  	 no       	 3  	 19
examples/litmus/ra/sb_t_weak.tpl        	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 2  	 12
examples/litmus/ra/sb_wait.tpl          	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 2  	 12
examples/litmus/ra/sb_wait2.tpl         	 0.0 	 0.0  	 1.0     	 0.0 	 no  	 no       	 2  	 12
examples/litmus/ra/sb_wait3.tpl         	 0.0 	 0.0  	 1.0     	 0.0 	 yes 	 yes      	 2  	 12
examples/litmus/ra/sb_wait4.tpl         	 0.0 	 0.0  	 1.0     	 0.0 	 yes 	 yes      	 2  	 13
examples/litmus/ra/sb_wait5.tpl         	 0.0 	 0.0  	 1.0     	 0.0 	 no  	 no       	 2  	 14
examples/litmus/ra/sb_wait6.tpl         	 0.0 	 0.0  	 1.0     	 0.0 	 no  	 no       	 2  	 14
examples/litmus/ra/sb_weak.tpl          	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 2  	 12
examples/litmus/ra/sb_weak2.tpl         	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 2  	 14
examples/litmus/ra/sb_weak3.tpl         	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 2  	 13
examples/litmus/ra/sb_weak4.tpl         	 0.0 	 0.0  	 1.0     	 0.0 	 no  	 no       	 3  	 17
examples/litmus/ra/sb_with3.tpl         	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 3  	 16
examples/litmus/ra/sb_with3p.tpl        	 0.0 	 0.0  	 0.9     	 0.0 	 no  	 no       	 3  	 17
examples/litmus/ra/trf.tpl              	 0.0 	 0.0  	 0.9     	 0.0 	 yes 	 yes      	 2  	 10
examples/litmus/ra/wait.tpl             	 0.0 	 0.0  	 0.9     	 0.0 	 yes 	 yes      	 2  	 13
examples/litmus/ra/wait2.tpl            	 0.0 	 0.0  	 1.0     	 0.0 	 no  	 no       	 2  	 14
examples/litmus/ra/wait3.tpl            	 0.0 	 0.0  	 1.0     	 0.0 	 yes 	 yes      	 2  	 15
examples/litmus/ra/wait4.tpl            	 0.0 	 0.0  	 1.0     	 0.0 	 yes 	 yes      	 2  	 13


$ ./spinify.d --robustness egr --memory rlx -m strongScFence examples/litmus/obs/*.tpl
Program                                                     	 TPL 	 Spin 	 Compile 	 Pan  	 Res 	 Expected 	 #T 	 #LoC
examples/litmus/obs/2w1r.tpl                                	 0.0 	 0.0  	 0.9     	 0.0  	 no  	 no       	 2  	 14
examples/litmus/obs/arc-det.tpl                             	 0.0 	 0.0  	 2.9     	 0.0  	 yes 	 yes      	 3  	 44
examples/litmus/obs/event_counters.tpl                      	 0.0 	 0.0  	 1.8     	 20.1 	 yes 	 yes      	 4  	 50
examples/litmus/obs/flags_rat.tpl                           	 0.0 	 0.0  	 1.9     	 19.9 	 yes 	 yes      	 4  	 50
examples/litmus/obs/flags_rat_stop.tpl                      	 0.0 	 0.0  	 1.5     	 0.0  	 yes 	 yes      	 4  	 49
examples/litmus/obs/mgc_mp.tpl                              	 0.0 	 0.0  	 1.0     	 0.0  	 no  	 no       	 2  	 14
examples/litmus/obs/mgc_mp_ra.tpl                           	 0.0 	 0.0  	 1.1     	 0.0  	 yes 	 yes      	 2  	 14
examples/litmus/obs/mprs.tpl                                	 0.0 	 0.0  	 0.9     	 0.0  	 yes 	 yes      	 3  	 17
examples/litmus/obs/mprs2.tpl                               	 0.0 	 0.0  	 0.9     	 0.0  	 no  	 no       	 3  	 15
examples/litmus/obs/mprs3.tpl                               	 0.0 	 0.0  	 0.9     	 0.0  	 no  	 no       	 3  	 15
examples/litmus/obs/na.tpl                                  	 0.0 	 0.0  	 1.0     	 0.0  	 no  	 no       	 2  	 13
examples/litmus/obs/na2.tpl                                 	 0.0 	 0.0  	 1.1     	 0.0  	 no  	 no       	 3  	 18
examples/litmus/obs/peterson-rel.tpl                        	 0.0 	 0.0  	 1.2     	 0.0  	 no  	 no       	 2  	 37
examples/litmus/obs/refcounter_rats.tpl                     	 0.0 	 0.0  	 1.1     	 0.0  	 yes 	 yes      	 2  	 28
examples/litmus/obs/sb.tpl                                  	 0.0 	 0.0  	 0.9     	 0.0  	 no  	 no       	 2  	 12
examples/litmus/obs/sb_1extra_thrad.tpl                     	 0.0 	 0.0  	 1.1     	 0.0  	 no  	 no       	 3  	 17
examples/litmus/obs/sb_1p.tpl                               	 0.0 	 0.0  	 1.0     	 0.0  	 no  	 no       	 2  	 13
examples/litmus/obs/sb_2p.tpl                               	 0.0 	 0.0  	 1.0     	 0.0  	 no  	 no       	 2  	 14
examples/litmus/obs/sb_bad_rec.tpl                          	 0.0 	 0.0  	 1.1     	 0.0  	 no  	 no       	 2  	 19
examples/litmus/obs/sb_but_valid.tpl                        	 0.0 	 0.0  	 1.3     	 0.0  	 no  	 no       	 2  	 21
examples/litmus/obs/sb_conditional.tpl                      	 0.0 	 0.0  	 1.0     	 0.0  	 no  	 no       	 2  	 18
examples/litmus/obs/sb_conditional2.tpl                     	 0.0 	 0.0  	 1.0     	 0.0  	 no  	 no       	 2  	 18
examples/litmus/obs/sb_if.tpl                               	 0.0 	 0.0  	 1.0     	 0.0  	 no  	 no       	 2  	 17
examples/litmus/obs/sb_no_sync.tpl                          	 0.0 	 0.0  	 1.1     	 0.0  	 no  	 no       	 2  	 18
examples/litmus/obs/sb_recover.tpl                          	 0.0 	 0.0  	 1.0     	 0.0  	 no  	 no       	 2  	 16
examples/litmus/obs/sb_recover_overwrite.tpl                	 0.0 	 0.0  	 0.9     	 0.0  	 no  	 no       	 2  	 14
examples/litmus/obs/sb_recover_wait.tpl                     	 0.0 	 0.0  	 1.1     	 0.0  	 no  	 no       	 2  	 17
examples/litmus/obs/sb_taint.tpl                            	 0.0 	 0.0  	 1.0     	 0.0  	 no  	 no       	 2  	 18
examples/litmus/obs/sb_taint2.tpl                           	 0.0 	 0.0  	 1.0     	 0.0  	 no  	 no       	 2  	 20
examples/litmus/obs/sb_wait.tpl                             	 0.0 	 0.0  	 1.0     	 0.0  	 yes 	 yes      	 2  	 12
examples/litmus/obs/sb_wait2.tpl                            	 0.0 	 0.0  	 1.1     	 0.0  	 yes 	 yes      	 2  	 14
examples/litmus/obs/sb_wait3.tpl                            	 0.0 	 0.0  	 1.1     	 0.0  	 no  	 no       	 2  	 14
examples/litmus/obs/sb_write_taint.tpl                      	 0.0 	 0.0  	 0.9     	 0.0  	 no  	 no       	 2  	 13
examples/litmus/obs/seqlock_2readers.tpl                    	 0.0 	 0.0  	 1.2     	 0.1  	 no  	 no       	 3  	 42
examples/litmus/obs/seqlock_onethread.tpl                   	 0.0 	 0.0  	 1.0     	 0.0  	 no  	 no       	 2  	 23
examples/litmus/obs/seqlock_onethread1.tpl                  	 0.0 	 0.0  	 1.0     	 0.0  	 no  	 no       	 2  	 24
examples/litmus/obs/seqlock_onethread_bohem_BCAS.tpl        	 0.0 	 0.0  	 1.2     	 0.0  	 no  	 no       	 2  	 26
examples/litmus/obs/seqlock_onethread_bohem_BCAS_opt.tpl    	 0.0 	 0.0  	 1.2     	 0.0  	 no  	 no       	 2  	 25
examples/litmus/obs/seqlock_onethread_bohem_RMW.tpl         	 0.0 	 0.0  	 1.2     	 0.0  	 no  	 no       	 2  	 24
examples/litmus/obs/seqlock_onethread_fence.tpl             	 0.0 	 0.0  	 1.2     	 0.0  	 no  	 no       	 2  	 28
examples/litmus/obs/seqlock_two_writers_two_readers.tpl     	 0.0 	 0.0  	 2.4     	 0.0  	 no  	 no       	 4  	 53
examples/litmus/obs/seqlock_two_writers_two_readers_opt.tpl 	 0.0 	 0.0  	 2.5     	 0.0  	 no  	 no       	 4  	 55
examples/litmus/obs/seqlock_twothreads_bohem_BCAS_opt.tpl   	 0.0 	 0.0  	 1.5     	 0.0  	 no  	 no       	 3  	 37
examples/litmus/obs/singleton2.tpl                          	 0.0 	 0.0  	 1.6     	 0.0  	 yes 	 yes      	 2  	 71
examples/litmus/obs/stale.tpl                               	 0.0 	 0.0  	 1.0     	 0.0  	 yes 	 yes      	 3  	 17


$ ./spinify.d --robustness wegr --memory rlx -m obsStrongFence examples/litmus/obs/*.tpl
Program                                                     	 TPL 	 Spin 	 Compile 	 Pan  	 Res 	 Expected 	 #T 	 #LoC
examples/litmus/obs/2w1r.tpl                                	 0.0 	 0.0  	 0.9     	 0.0  	 no  	 no       	 2  	 14
examples/litmus/obs/arc-det.tpl                             	 0.0 	 0.0  	 2.8     	 0.0  	 yes 	 yes      	 3  	 44
examples/litmus/obs/event_counters.tpl                      	 0.0 	 0.0  	 2.0     	 21.6 	 yes 	 yes      	 4  	 50
examples/litmus/obs/flags_rat.tpl                           	 0.0 	 0.0  	 2.1     	 21.0 	 yes 	 yes      	 4  	 50
examples/litmus/obs/flags_rat_stop.tpl                      	 0.0 	 0.0  	 1.5     	 0.0  	 yes 	 yes      	 4  	 49
examples/litmus/obs/mgc_mp.tpl                              	 0.0 	 0.0  	 1.0     	 0.0  	 no  	 no       	 2  	 14
examples/litmus/obs/mgc_mp_ra.tpl                           	 0.0 	 0.0  	 1.0     	 0.0  	 yes 	 yes      	 2  	 14
examples/litmus/obs/mprs.tpl                                	 0.0 	 0.0  	 0.9     	 0.0  	 yes 	 yes      	 3  	 17
examples/litmus/obs/mprs2.tpl                               	 0.0 	 0.0  	 0.9     	 0.0  	 yes 	 yes      	 3  	 15
examples/litmus/obs/mprs3.tpl                               	 0.0 	 0.0  	 0.9     	 0.0  	 yes 	 yes      	 3  	 15
examples/litmus/obs/na.tpl                                  	 0.0 	 0.0  	 0.9     	 0.0  	 no  	 no       	 2  	 13
examples/litmus/obs/na2.tpl                                 	 0.0 	 0.0  	 1.1     	 0.0  	 no  	 no       	 3  	 18
examples/litmus/obs/peterson-rel.tpl                        	 0.0 	 0.0  	 1.2     	 0.0  	 no  	 no       	 2  	 37
examples/litmus/obs/refcounter_rats.tpl                     	 0.0 	 0.0  	 1.1     	 0.0  	 yes 	 yes      	 2  	 28
examples/litmus/obs/sb.tpl                                  	 0.0 	 0.0  	 0.9     	 0.0  	 yes 	 yes      	 2  	 12
examples/litmus/obs/sb_1extra_thrad.tpl                     	 0.0 	 0.0  	 1.1     	 0.0  	 no  	 no       	 3  	 17
examples/litmus/obs/sb_1p.tpl                               	 0.0 	 0.0  	 0.9     	 0.0  	 no  	 no       	 2  	 13
examples/litmus/obs/sb_2p.tpl                               	 0.0 	 0.0  	 0.9     	 0.0  	 no  	 no       	 2  	 14
examples/litmus/obs/sb_bad_rec.tpl                          	 0.0 	 0.0  	 1.0     	 0.0  	 no  	 no       	 2  	 19
examples/litmus/obs/sb_but_valid.tpl                        	 0.0 	 0.0  	 1.3     	 0.0  	 yes 	 yes      	 2  	 21
examples/litmus/obs/sb_conditional.tpl                      	 0.0 	 0.0  	 1.0     	 0.0  	 no  	 no       	 2  	 18
examples/litmus/obs/sb_conditional2.tpl                     	 0.0 	 0.0  	 1.0     	 0.0  	 no  	 no       	 2  	 18
examples/litmus/obs/sb_if.tpl                               	 0.0 	 0.0  	 1.0     	 0.0  	 no  	 no       	 2  	 17
examples/litmus/obs/sb_no_sync.tpl                          	 0.0 	 0.0  	 1.1     	 0.0  	 no  	 no       	 2  	 18
examples/litmus/obs/sb_recover.tpl                          	 0.0 	 0.0  	 1.0     	 0.0  	 yes 	 yes      	 2  	 16
examples/litmus/obs/sb_recover_overwrite.tpl                	 0.0 	 0.0  	 1.0     	 0.0  	 yes 	 yes      	 2  	 14
examples/litmus/obs/sb_recover_wait.tpl                     	 0.0 	 0.0  	 1.1     	 0.0  	 yes 	 yes      	 2  	 17
examples/litmus/obs/sb_taint.tpl                            	 0.0 	 0.0  	 1.1     	 0.0  	 no  	 no       	 2  	 18
examples/litmus/obs/sb_taint2.tpl                           	 0.0 	 0.0  	 1.1     	 0.0  	 no  	 no       	 2  	 20
examples/litmus/obs/sb_wait.tpl                             	 0.0 	 0.0  	 1.2     	 0.0  	 yes 	 yes      	 2  	 12
examples/litmus/obs/sb_wait2.tpl                            	 0.0 	 0.0  	 1.2     	 0.0  	 yes 	 yes      	 2  	 14
examples/litmus/obs/sb_wait3.tpl                            	 0.0 	 0.0  	 1.2     	 0.0  	 no  	 no       	 2  	 14
examples/litmus/obs/sb_write_taint.tpl                      	 0.0 	 0.0  	 1.0     	 0.0  	 no  	 no       	 2  	 13
examples/litmus/obs/seqlock_2readers.tpl                    	 0.0 	 0.0  	 1.3     	 1.0  	 yes 	 yes      	 3  	 42
examples/litmus/obs/seqlock_onethread.tpl                   	 0.0 	 0.0  	 1.1     	 0.0  	 no  	 no       	 2  	 23
examples/litmus/obs/seqlock_onethread1.tpl                  	 0.0 	 0.0  	 1.1     	 0.0  	 no  	 no       	 2  	 24
examples/litmus/obs/seqlock_onethread_bohem_BCAS.tpl        	 0.0 	 0.0  	 1.3     	 0.0  	 yes 	 yes      	 2  	 26
examples/litmus/obs/seqlock_onethread_bohem_BCAS_opt.tpl    	 0.0 	 0.0  	 1.2     	 0.0  	 yes 	 yes      	 2  	 25
examples/litmus/obs/seqlock_onethread_bohem_RMW.tpl         	 0.0 	 0.0  	 1.2     	 0.0  	 no  	 no       	 2  	 24
examples/litmus/obs/seqlock_onethread_fence.tpl             	 0.0 	 0.0  	 1.1     	 0.0  	 yes 	 yes      	 2  	 28
examples/litmus/obs/seqlock_two_writers_two_readers.tpl     	 0.0 	 0.0  	 2.3     	 4.7  	 yes 	 yes      	 4  	 53
examples/litmus/obs/seqlock_two_writers_two_readers_opt.tpl 	 0.0 	 0.1  	 2.5     	 6.0  	 yes 	 yes      	 4  	 55
examples/litmus/obs/seqlock_twothreads_bohem_BCAS_opt.tpl   	 0.0 	 0.0  	 1.4     	 0.1  	 yes 	 yes      	 3  	 37
examples/litmus/obs/singleton2.tpl                          	 0.0 	 0.0  	 1.7     	 0.0  	 yes 	 yes      	 2  	 71
examples/litmus/obs/stale.tpl                               	 0.0 	 0.0  	 1.0     	 0.0  	 yes 	 yes      	 3  	 17
