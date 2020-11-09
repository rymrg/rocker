// ROBUSTNESS wegr: not: ra.

// https://stackoverflow.com/questions/11588514/a-tested-implementation-of-peterson-lock-algorithm
// Assumes x86-TSO
// lock(int id)
// {
//     interested[id] = 1;
//     turn = 1 - id;
//     __asm__ __volatile__("mfence");
// 
//     do {
//         __asm__ __volatile__("":::"memory");
//     } while (turn == 1 - id
//            && interested[1 - id] == 1);
// }
// 
// unlock(int id)
// {
//    interested[id] = 0;
// }

max_value 3;
global x0,x1,flag,k;

fn t0{
	local r, a, b, t;

	while (true) {

		// lock
		x0.store(1, rel);
		flag.store(1, rel);
		fence(seq_cst);
		loop:
		fence(seq_cst);
		b = flag.load(acq);
		if (b == 0) goto critical;
		a = x1.load(acq);
		if (a == 0) goto loop;

		critical:
		k.store(1);
		t = k.load();
		assert(t == 1);

		// unlock
		x0.store(0, rel);
	}
}

fn t1{
	local r, a, b, t;

	while (true) {
		// lock
		x1.store(1, rel);
		flag.store(0, rel);
		fence(seq_cst);
		loop:
		fence(seq_cst);
		b = flag.load(acq);
		if (b == 1) goto critical;
		a = x0.load(acq);
		if (a == 0) goto loop;

		critical:
		k.store(1);
		t = k.load();
		assert(t == 1);

		// unlock
		x1.store(0, rel);
	}
}
