// ROBUST
// A model of the work-stealing queue from Cilk 5, as presented in
//
// Matteo Frigo, Charles E. Leiserson, and Keith H. Randall. The implementation
// of the cilk-5 multithreaded language. SIGPLAN Not., 33(5):212–223, May 1998.
global T=10, H=10, lck;

fn owner{
	local i, t, h;
	i = 0;
	while (i < 10) { // 10 rounds
		i = i + 1;
		// push or pop
		oneof({
			// Push
			t = T.load();
			T.store(t+1);
		} {
			// Pop
			t = T.load();
			T.store(t-1);
			fence;
			h = H.load();
			t = T.load();
			if (h > t) {
				t = T.load();
				T.store(t+1);
				lock(lck);
				t = T.load();
				T.store(t-1);
				h = H.load();
				t = T.load();
				if (h > t) {
					t = T.load();
					T.store(t+1);
					unlock(lck);
					goto FAILURE;
				}
				unlock(lck);
			}
		});

		FAILURE:
		SUCCESS:
		skip;
	}
}

fn thief{
	local t, h;
	while (true) { 
		// Steal
		lock(lck);
		h = H.load();
		H.store(h+1);
		fence;
		h = H.load();
		t = T.load();
		if (h>t){
			h = H.load();
			H.store(h-1);
			unlock(lck);
			goto FAILURE;
		}
		unlock(lck);
		goto SUCCESS;

		FAILURE:
		SUCCESS:
		skip;
	}
}
