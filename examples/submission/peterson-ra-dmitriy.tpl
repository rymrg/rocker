// ROBUST
// https://www.justsoftwaresolutions.co.uk/threading/petersons_lock_with_C++0x_atomics.html
// std::atomic<int> flag0(0),flag1(0),turn(0);
// void lock(unsigned index) {
//     if (0 == index)
//     {
//         flag0.store(1, std::memory_order_relaxed);
//         turn.exchange(1, std::memory_order_acq_rel);
// 
//         while (flag1.load(std::memory_order_acquire)
//             && 1 == turn.load(std::memory_order_relaxed))
//             std::this_thread::yield();
//     }
//     else
//     {
//         flag1.store(1, std::memory_order_relaxed);
//         turn.exchange(0, std::memory_order_acq_rel);
// 
//         while (flag0.load(std::memory_order_acquire)
//             && 0 == turn.load(std::memory_order_relaxed))
//             std::this_thread::yield();
//     }
// }

max_value 3;
global x0,x1,flag,k;

fn t0{
	local r, a, b, t;

	while (true) {

		// Lock
		x0.store(1);
		r = exchange(flag, 1);
		loop:
		a = x1.load();
		if (a == 0) goto critical;
		b = flag.load();
		if (b == 1) goto loop;

		critical:
		k.store(1);
		t = k.load();
		assert(t == 1);

		// Unlock
		x0.store(0);
	}
}

fn t1{
	local r, a, b, t;

	while (true) {

		// Lock
		x1.store(1);
		r = exchange(flag, 0);
		loop:
		a = x0.load();
		if (a == 0) goto critical;
		b = flag.load();
		if (b == 0) goto loop;

		critical:
		k.store(2);
		t = k.load();
		assert(t == 2);

		// Unlock
		x1.store(0);
	}
}
