// ROBUST
// Linux Spinlock from the paper (Fig 2):
//
// S. Owens. Reasoning about the implementation of concurrency ab-
// stractions on x86-TSO. In ECOOP, volume 6183 of LNCS, pages
// 478–503. Springer, 2010.
max_value 10;
global x = 0;
na k;

fn t0{
	local t, i, notlocked;
	i = 0;
	notlocked = 0;
	while (true) {
	 	t = FADD(x, 1);
	 	if (t == notlocked) {
	 		// CS
	 		k.nastore(1);

	 		// Release
	 		x.store(notlocked);
	 	} else {
			wait(x, notlocked);
	 	}
	}
}

fn t1{
	local t, i, notlocked;
	i = 1;
	notlocked = 0;
	while (true) {
	 	t = FADD(x, 1);
	 	if (t == notlocked) {
	 		// CS
	 		k.nastore(1);

	 		// Release
	 		x.store(notlocked);
	 	} else {
			wait(x, notlocked);
	 	}
	}
}
