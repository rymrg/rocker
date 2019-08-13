// ROBUST
// spin_depth 8

// RCU test 
// adopted from  
// [ Owicki-Gries Reasoning for Weak Memory Models,
//   Ori Lahav and Viktor Vafeiadis; ICALP 2015 ]
// (explanation copied and adapted as well) 
//
// The following code is based on an implementation of the quiescent-
// state-based user-mode RCU implementation of [Desnoyers et al., IEEE Trans.
// Parallel Distrib. Syst. 23(2), 375–382 (2012)]. We consider a very simple shared
// data structure, that consists of two containers n_0, n_1, and one index variable
// m, with the property that n_m represents the updated container. This structure
// is accessed concurrently by 3 reader threads, that constantly read n_m. The
// writer thread constantly wants to flip the current container n_m (m is either 0
// or 1) and deallocate n_m (which we model by the assignment n_m := 0). Thus it
// flips m, and then synchronizes with all the concurrent readers. Synchronization
// happens by the writer storing a new value (0 or 1) in the writer’s RCU
// synchronization location w, and waiting for each of the readers to acknowledge
// that they are aware of this new value. When a reader acknowledges the writer's
// update to w (by setting its RCU synchronization location r_i to match the value
// of w), it notifies the writer that it is no longer accessing n_m. Only then the
// writer can deallocate n_m. We verify the safety of this mechanism, by proving
// that the readers never access a deallocated value: they always return data != 0.

max_value 1;
global m=0, w=0, r1, r2, r3;
na n_0=1, n_1=0;
track r1: 1;
track r2: 1;
track r3: 1;

fn writer{

	while (true) {

		// "allocate" n_1
		n_1.nastore(1); 
		
		// tell readers to start using n_1
		m.store(1);   
		
		// wait for all readers
		w.store(1);
		wait(r1, 1);
		wait(r2, 1);
		wait(r3, 1);

		// "deallocate" n_0
		n_0.nastore(0);

		// "allocate" n_0
		n_0.nastore(1);

		// tell readers to start using n_0
		m.store(0);

		// wait for all readers
		w.store(0);
		wait(r1, 0);
		wait(r2, 0);
		wait(r3, 0);

		// "deallocate" n_1
		n_1.nastore(0);
	}
}

fn reader1{
	local cell, data, a;
	while (true) {
		oneof({
			// read data
			cell = m.load();
			if (cell == 0) {
				data = n_0.naload();
			} else {
				// cell == 1
				data = n_1.naload();
			}
			assert (data != 0);
		}{
			// rcu_quiescent_state
			a = w.load();
			r1.store(a);
		});
	}
}

fn reader2{
	local cell, data, a;
	while (true) {
		oneof({
			// read data
			cell = m.load();
			if (cell == 0) {
				data = n_0.naload();
			} else {
				// cell == 1
				data = n_1.naload();
			}
			assert (data != 0);
		}{
			// rcu_quiescent_state
			a = w.load();
			r2.store(a);
		});
	}
}

fn reader3{
	local cell, data, a;
	while (true) {
		oneof({
			// read data
			cell = m.load();
			if (cell == 0) {
				data = n_0.naload();
			} else {
				// cell == 1
				data = n_1.naload();
			}
			assert (data != 0);
		}{
			// rcu_quiescent_state
			a = w.load();
			r3.store(a);
		});
	}
}
