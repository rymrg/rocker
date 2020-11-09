// ROBUSTNESS egr: robust: ra,rlx.
// ROBUSTNESS wegr: robust: ra,rlx.

// Dekker 
// https://www.justsoftwaresolutions.co.uk/threading/implementing_dekkers_algorithm_with_fences.html

// std::atomic<bool> flag0(false),flag1(false);
// std::atomic<int> turn(0);
// 
// void p0()
// {
//     flag0.store(true,std::memory_order_relaxed);
//     std::atomic_thread_fence(std::memory_order_seq_cst);
// 
//     while (flag1.load(std::memory_order_relaxed))
//     {
//         if (turn.load(std::memory_order_relaxed) != 0)
//         {
//             flag0.store(false,std::memory_order_relaxed);
//             while (turn.load(std::memory_order_relaxed) != 0)
//             {
//             }
//             flag0.store(true,std::memory_order_relaxed);
//             std::atomic_thread_fence(std::memory_order_seq_cst);
//         }
//     }
//     std::atomic_thread_fence(std::memory_order_acquire);
//  
//     // critical section
// 
// 
//     turn.store(1,std::memory_order_relaxed);
//     std::atomic_thread_fence(std::memory_order_release);
//     flag0.store(false,std::memory_order_relaxed);
// }
// 
// void p1()
// {
//     flag1.store(true,std::memory_order_relaxed);
//     std::atomic_thread_fence(std::memory_order_seq_cst);
// 
//     while (flag0.load(std::memory_order_relaxed))
//     {
//         if (turn.load(std::memory_order_relaxed) != 1)
//         {
//             flag1.store(false,std::memory_order_relaxed);
//             while (turn.load(std::memory_order_relaxed) != 1)
//             {
//             }
//             flag1.store(true,std::memory_order_relaxed);
//             std::atomic_thread_fence(std::memory_order_seq_cst);
//         }
//     }
//     std::atomic_thread_fence(std::memory_order_acquire);
//  
//     // critical section
// 
// 
//     turn.store(0,std::memory_order_relaxed);
//     std::atomic_thread_fence(std::memory_order_release);
//     flag1.store(false,std::memory_order_relaxed);
// }

max_value 10;
global flag0, flag1, turn;
na k;

fn p0{
	local f,t,i;
	i = 0;

    flag0.store(1,rlx);
	fence(seq_cst);

	f = flag1.load(rlx);
    while (f)
    {
		t = turn.load(rlx);
        if (t != i)
        {
            flag0.store(false,rlx);
			t = turn.load(rlx);
            while (t != i){
					t = turn.load(rlx);
			}
			flag0.store(true,rlx);
			fence(seq_cst);
        }

		f = flag1.load(rlx);
    }
	fence(acq);
 
    // critical section
	k.nastore(i);
	t = k.naload();
	assert(t==i);


	turn.store(1-i,rlx);
	fence(rel);
    flag0.store(false,rlx);
}

fn p1{
	local f,t,i;
	i = 1;

    flag1.store(1,rlx);
	fence(seq_cst);

	f = flag0.load(rlx);
    while (f)
    {
		t = turn.load(rlx);
        if (t != i)
        {
            flag1.store(false,rlx);
			t = turn.load(rlx);
            while (t != i){
					t = turn.load(rlx);
			}
			flag1.store(true,rlx);
			fence(seq_cst);
        }

		f = flag0.load(rlx);
    }
	fence(acq);
 
    // critical section
	k.nastore(i);
	t = k.naload();
	assert(t==i);


	turn.store(1-i,rlx);
	fence(rel);
    flag1.store(false,rlx);
}

