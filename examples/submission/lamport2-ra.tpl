// ROBUST
//
// Lamport's fast mutex algorithm 2, as presented in
//
// L. Lamport. A fast mutual exclusion algorithm. ACM Trans. Comput.
// Syst., 5(1), 1987.
// Algorithm 2 
//
// Fences are added to make it robust against RA
//
//
max_value 10;
global b1, b2, x, y, k;
track b1: 0;
track b2: 0;
track y: 0;

fn thread1{
	local i, t, a, b, c;
	i = 1;

	while (true) {
		while(true){
			b1.store(1);
			fence;
			x.store(i);
			fence;
			b = y.load();
			if (b != 0) {
				b1.store(0);
				wait(y, 0);
			} else {
				y.store(i);
				fence;
				a = x.load();
				fence;
				if(a != i) {
					b1.store(0);
					wait(b2, 0);
					b = y.load();
					if (b == i) goto criticalsection;
					wait (y, 0);
				} else {
					goto criticalsection;
				}
			}
		}

		criticalsection:
		k.store(i);
		t = k.load();
		assert(t == i);

		// Unlock
		y.store(0);
		b1.store(0);
	}
}

fn thread2{
	local i, t, a, b, c;
	i = 2;

	while (true) {
		while(true){
			b2.store(1);
			fence;
			x.store(i);
			fence;
			b = y.load();
			if (b != 0) {
				b2.store(0);
				wait(y, 0);
			} else {
				y.store(i);
				fence;
				a = x.load();
				fence;
				if(a != i) {
					b2.store(0);
					wait(b1, 0);
					b = y.load();
					if (b == i) goto criticalsection;
					wait (y, 0);
				} else {
					goto criticalsection;
				}
			}
		}

		criticalsection:
		k.store(i);
		t = k.load();
		assert(t == i);

		// Unlock
		y.store(0);
		b2.store(0);
	}
}
