// ROBUSTNESS egr: robust: ra,rlx.
// ROBUSTNESS wegr: robust: ra,rlx.
// spin_depth 8
//
// Lamport's fast mutex algorithm 2, as presented in
//
// L. Lamport. A fast mutual exclusion algorithm. ACM Trans. Comput.
// Syst., 5(1), 1987.
// Algorithm 2 
//
// Fences are added to make it robust against RA
// 
// 3 threads
//
// Run with -s100000000
max_value 10;
global b1, b2, b3, x, y, k;
track b1: 0;
track b2: 0;
track b3: 0;
track y: 0;

fn thread1{
	local i, t, a, b, c;
	i = 1;

	while (true) {
		while(true){
			b1.store(1, rel);
			fence(seq_cst);
			x.store(i, rel);
			fence(seq_cst);
			b = y.load(acq);
			if (b != 0) {
				b1.store(0, rel);
				wait(y, 0, acq);
			} else {
				y.store(i, rel);
				fence(seq_cst);
				a = x.load(acq);
				fence(seq_cst);
				if(a != i) {
					b1.store(0, rel);
					wait(b2, 0, acq);
					fence(seq_cst);
					wait(b3, 0, acq);
					b = y.load(acq);
					if (b == i){ goto criticalsection; }
					wait (y, 0);
				} else {
					goto criticalsection;
				}
			}
		}

		criticalsection:
		k.store(i, rel);
		t = k.load(acq);
		assert(t == i);

		// Unlock
		y.store(0, rel);
		b1.store(0, rel);
	}
}

fn thread2{
	local i, t, a, b, c;
	i = 2;

	while (true) {
		while(true){
			b2.store(1, rel);
			fence(seq_cst);
			x.store(i, rel);
			fence(seq_cst);
			b = y.load(acq);
			if (b != 0) {
				b2.store(0, rel);
				wait(y, 0, acq);
			} else {
				y.store(i, rel);
				fence(seq_cst);
				a = x.load(acq);
				fence(seq_cst);
				if(a != i) {
					b2.store(0, rel);
					wait(b1, 0, acq);
					fence(seq_cst);
					wait(b3, 0, acq);
					b = y.load(acq);
					if (b == i){ goto criticalsection; }
					wait (y, 0);
				} else {
					goto criticalsection;
				}
			}
		}

		criticalsection:
		k.store(i, rel);
		t = k.load(acq);
		assert(t == i);

		// Unlock
		y.store(0, rel);
		b2.store(0, rel);
	}
}

fn thread3{
	local i, t, a, b, c;
	i = 3;

	while (true) {
		while(true){
			b3.store(1, rel);
			fence(seq_cst);
			x.store(i, rel);
			fence(seq_cst);
			b = y.load(acq);
			if (b != 0) {
				b3.store(0, rel);
				wait(y, 0, acq);
			} else {
				y.store(i, rel);
				fence(seq_cst);
				a = x.load(acq);
				fence(seq_cst);
				if(a != i) {
					b3.store(0, rel);
					wait(b1, 0, acq);
					fence(seq_cst);
					wait(b2, 0, acq);
					b = y.load(acq);
					if (b == i){ goto criticalsection; }
					wait (y, 0);
				} else {
					goto criticalsection;
				}
			}
		}

		criticalsection:
		k.store(i, rel);
		t = k.load(acq);
		assert(t == i);

		// Unlock
		y.store(0, rel);
		b3.store(0, rel);
	}
}

