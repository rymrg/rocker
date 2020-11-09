// ROBUSTNESS egr: robust: ra,rlx.
// ROBUSTNESS wegr: robust: ra,rlx.
// spin_depth 6
//  Linux Spinlock from the paper (Fig 2):
// 
//  S. Owens. Reasoning about the implementation of concurrency ab-
//  stractions on x86-TSO. In ECOOP, volume 6183 of LNCS, pages
//  478–503. Springer, 2010.
//
max_value 10;
global x = 0, k;

fn t0{
	local t, i, notlocked;
	i = 0;
	notlocked = 0;
	while (true) {
	 	t = FADD(x, 1, acq, rel);
	 	if (t == notlocked) {
	 		// CS
	 		k.store(i, rel);
	 		t = k.load(acq);
	 		assert(t == i);

	 		// Release
	 		x.store(notlocked, rel);
	 	} else {
	 		wait(x, notlocked, acq);
	 	}
	}
}

fn t1{
	local t, i, notlocked;
	i = 1;
	notlocked = 0;
	while (true) {
	 	t = FADD(x, 1, acq, rel);
	 	if (t == notlocked) {
	 		// CS
	 		k.store(i, rel);
	 		t = k.load(acq);
	 		assert(t == i);

	 		// Release
	 		x.store(notlocked, rel);
	 	} else {
			wait(x, notlocked, acq);
	 	}
	}
}

fn t2{
	local t, i, notlocked;
	i = 2;
	notlocked = 0;
	while (true) {
	 	t = FADD(x, 1, acq, rel);
	 	if (t == notlocked) {
	 		// CS
	 		k.store(i, rel);
	 		t = k.load(acq);
	 		assert(t == i);

	 		// Release
	 		x.store(notlocked, rel);
	 	} else {
			wait(x, notlocked, acq);
	 	}
	}
}

fn t3{
	local t, i, notlocked;
	i = 3;
	notlocked = 0;
	while (true) {
	 	t = FADD(x, 1, acq, rel);
	 	if (t == notlocked) {
	 		// CS
	 		k.store(i, rel);
	 		t = k.load(acq);
	 		assert(t == i);

	 		// Release
	 		x.store(notlocked, rel);
	 	} else {
			wait(x, notlocked, acq);
	 	}
	}
}
