// ROBUSTNESS egr: robust: ra,rlx.
// ROBUSTNESS wegr: robust: ra,rlx.
// spin_depth 7

// RCU test with online/offline
//
// This is an extension of RCU test where threads may go offline and return online.
// Each thread acts both as writer and reader.
// Adopted from :
//
// [ Taming Release-Acquire Consistency;
//   Ori Lahav, Nick Giannarakis, Viktor Vafeiadis; POPL 2016 ]
//
// [ M. Desnoyers, P. E. McKenney, A. S. Stern, M. R. Dagenais, and J. Walpole. 
//   User-level implementations of read-copy update. 
//	IEEE Trans. Parallel Distrib. Syst., 23(2):375–382, 2012. ]
//
// run with -s100000000

max_value 100;
global m=0, n_0=1, n_1=0, gc=1, r1=0, r2=0, r3=0, lck;

fn t1{
	local cell, data, a, cnt, num, is_online;

	num = 3;
	cnt = 0;
	is_online = false;

	while (true) {

		oneof({
			// read data
			if (is_online == true) {
				cell = m.load(acq);
				if (cell == 0) {
					data = n_0.load(acq);
				} else {
					// cell == 1
					data = n_1.load(acq);
				}
				assert (data != 0);
			}
		}{
			// rcu_quiescent_state
			if (is_online == true) {
				a = gc.load(acq);
				r1.store(a, rel);
				fence(seq_cst);
			}
		}{
			// go offline
			if (is_online == true) {
				r1.store(0, rel);
				fence(seq_cst);
				is_online = false;
			}
		}{
			// go online
			if (is_online == false) {
				a = gc.load(acq);
				r1.store(a, rel);
				fence(seq_cst);
				is_online = true;
			}
		}{
			// act as a writer and synchronize_rcu
			if (cnt <= num) { // to avoid overflow in gc, this can only happen limited amount of times
				cnt = cnt + 1;
				
				// if online, go offline
				if (is_online == true) {
					r1.store(0, rel);
				}

				// take a lock (only one writer at a time)
				lock(lck);

				cell = m.load(acq);

				// "allocate" new cell
				if (cell == 0) {
					n_1.store(1, rel); 
				} else {
					// cell == 1
					n_0.store(1, rel); 
				}
						
				// tell readers to start using new cell
				m.store(!cell, rel);   
					
				// wait for all readers
				a = gc.load(acq);
				a = a + 1;
				gc.store(a, rel);
				fence(seq_cst);
				wait(r1,a,0, acq);
				wait(r2,a,0, acq);
				wait(r3,a,0, acq);

				// "deallocate" old_cell
				if (cell == 0) {
					n_0.store(0, rel); 
				} else {
					// cell == 1
					n_1.store(0, rel); 
				}
				
				// unlock
				unlock(lck);

				// return online, if was online
				if (is_online == true) {
					a = gc.load(acq);
					r1.store(a, rel);
					fence(seq_cst);
				}

			}
		});
	}
}

fn t2{
	local cell, data, a, cnt, num, is_online;

	num = 3;
	cnt = 0;
	is_online = false;

	while (true) {

		oneof({
			// read data
			if (is_online == true) {
				cell = m.load(acq);
				if (cell == 0) {
					data = n_0.load(acq);
				} else {
					// cell == 1
					data = n_1.load(acq);
				}
				assert (data != 0);
			}
		}{
			// rcu_quiescent_state
			if (is_online == true) {
				a = gc.load(acq);
				r2.store(a, rel);
				fence(seq_cst);
			}
		}{
			// go offline
			if (is_online == true) {
				r2.store(0, rel);
				fence(seq_cst);
				is_online = false;
			}
		}{
			// go online
			if (is_online == false) {
				a = gc.load(acq);
				r2.store(a, rel);
				fence(seq_cst);
				is_online = true;
			}
		}{
			// act as a writer and synchronize_rcu
			if (cnt <= num) { // to avoid overflow in gc, this can only happen limited amount of times
				cnt = cnt + 1;
				
				// if online, go offline
				if (is_online == true) {
					r2.store(0, rel);
				}

				// take a lock (only one writer at a time)
				lock(lck);

				cell = m.load(acq);

				// "allocate" new cell
				if (cell == 0) {
					n_1.store(1, rel); 
				} else {
					// cell == 1
					n_0.store(1, rel); 
				}
						
				// tell readers to start using new cell
				m.store(!cell, rel);   
					
				// wait for all readers
				a = gc.load(acq);
				a = a + 1;
				gc.store(a, rel);
				fence(seq_cst);
				wait(r1,a,0, acq);
				wait(r2,a,0, acq);
				wait(r3,a,0, acq);

				// "deallocate" old_cell
				if (cell == 0) {
					n_0.store(0, rel); 
				} else {
					// cell == 1
					n_1.store(0, rel); 
				}
				
				// unlock
				unlock(lck);

				// return online, if was online
				if (is_online == true) {
					a = gc.load(acq);
					r2.store(a, rel);
					fence(seq_cst);
				}

			}
		});
	}
}

fn t3{
	local cell, data, a, cnt, num, is_online;

	num = 3;
	cnt = 0;
	is_online = false;

	while (true) {

		oneof({
			// read data
			if (is_online == true) {
				cell = m.load(acq);
				if (cell == 0) {
					data = n_0.load(acq);
				} else {
					// cell == 1
					data = n_1.load(acq);
				}
				assert (data != 0);
			}
		}{
			// rcu_quiescent_state
			if (is_online == true) {
				a = gc.load(acq);
				r3.store(a, rel);
				fence(seq_cst);
			}
		}{
			// go offline
			if (is_online == true) {
				r3.store(0, rel);
				fence(seq_cst);
				is_online = false;
			}
		}{
			// go online
			if (is_online == false) {
				a = gc.load(acq);
				r3.store(a, rel);
				fence(seq_cst);
				is_online = true;
			}
		}{
			// act as a writer and synchronize_rcu
			if (cnt <= num) { // to avoid overflow in gc, this can only happen limited amount of times
				cnt = cnt + 1;
				
				// if online, go offline
				if (is_online == true) {
					r3.store(0, rel);
				}

				// take a lock (only one writer at a time)
				lock(lck);

				cell = m.load(acq);

				// "allocate" new cell
				if (cell == 0) {
					n_1.store(1, rel); 
				} else {
					// cell == 1
					n_0.store(1, rel); 
				}
						
				// tell readers to start using new cell
				m.store(!cell, rel);   
					
				// wait for all readers
				a = gc.load(acq);
				a = a + 1;
				gc.store(a, rel);
				fence(seq_cst);
				wait(r1,a,0, acq);
				wait(r2,a,0, acq);
				wait(r3,a,0, acq);

				// "deallocate" old_cell
				if (cell == 0) {
					n_0.store(0, rel); 
				} else {
					// cell == 1
					n_1.store(0, rel); 
				}
				
				// unlock
				unlock(lck);

				// return online, if was online
				if (is_online == true) {
					a = gc.load(acq);
					r3.store(a, rel);
					fence(seq_cst);
				}

			}
		});
	}
}
