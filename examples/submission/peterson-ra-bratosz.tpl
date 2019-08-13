// NOTROBUST
// https://www.justsoftwaresolutions.co.uk/threading/petersons_lock_with_C++0x_atomics.html
// class Peterson_Bartosz
// {
// private:
//     // indexed by thread ID, 0 or 1
//     std::atomic<bool> _interested[2];
//     // who's yielding priority?
//     std::atomic<int> _victim;
// public:
//     Peterson_Bartosz()
//     {
//        _victim.store(0, std::memory_order_release);
//        _interested[0].store(false, std::memory_order_release);
//        _interested[1].store(false, std::memory_order_release);
//     }
//     void lock()
//     {
//        int me = threadID; // either 0 or 1
//        int he = 1 ? me; // the other thread
//        _interested[me].exchange(true, std::memory_order_acq_rel);
//        _victim.store(me, std::memory_order_release);
//        while (_interested[he].load(std::memory_order_acquire)
//            && _victim.load(std::memory_order_acquire) == me)
//           continue; // spin
//     }
//     void unlock()
//     {
//         int me = threadID;
//         _interested[me].store(false,std::memory_order_release);
//     }
// }

max_value 3;
global x0,x1,flag,k;

fn t0{
	local r, a, b, t, i;

	i=0;
	// Lock

	r = exchange(x0, 1);
	flag.store(i);
	loop:
	a = x1.load();
	if (a == 0) goto critical;
	b = flag.load();
	if (b == 1-i) goto loop;

	critical:
	// Unlock
	x0.store(0);
}

fn t1{
	local r, a, b, t, i;

	i=1;
	// Lock

	r = exchange(x1, 1);
	flag.store(i);
	loop:
	a = x0.load();
	if (a == 0) goto critical;
	b = flag.load();
	if (b == 1-i) goto loop;

	critical:
	// Unlock
	x1.store(0);
}
