// ROBUSTNESS egr: robust: ra,rlx.
// ROBUSTNESS wegr: robust: ra,rlx.

// https://stackoverflow.com/questions/11588514/a-tested-implementation-of-peterson-lock-algorithm
// lock(int id)
// {
//     atomic_store_explicit(&interested[id], 1, memory_order_relaxed);
//     atomic_exchange_explicit(&turn, 1 - id, memory_order_acq_rel);
// 
//     while (atomic_load_explicit(&interested[1 - id], memory_order_acquire) == 1
//            && atomic_load_explicit(&turn, memory_order_relaxed) == 1 - id);
// }
// 
// unlock(int id)
// {
//     atomic_store_explicit(&interested[id], 0, memory_order_release);
// }

max_value 3;
global x0,x1,flag;
na k;

fn t0{
	local r, a, b, t;

	while (true) {

		// Lock
		x0.store(1, rel);
		r = exchange(flag, 1, acq, rel);
		loop:
		a = x1.load(acq);
		if (a == 0) goto critical;
		b = flag.load(acq);
		if (b == 1) goto loop;

		critical:
		k.nastore(1);
		t = k.naload();
		assert(t == 1);

		// Unlock
		x0.store(0, rel);
	}
}

fn t1{
	local r, a, b, t;

	while (true) {

		// Lock
		x1.store(1, rel);
		r = exchange(flag, 0, acq, rel);
		loop:
		a = x0.load(acq);
		if (a == 0) goto critical;
		b = flag.load(acq);
		if (b == 0) goto loop;

		critical:
		k.nastore(2);
		t = k.naload();
		assert(t == 2);

		// Unlock
		x1.store(0, rel);
	}
}
