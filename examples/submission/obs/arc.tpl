// ROBUSTNESS egr: robust: ra,rlx.
// ROBUSTNESS wegr: robust: ra,rlx.
// spin_depth 8

// Arc from rust
// Weak pointer removed
// https://doc.rust-lang.org/src/alloc/sync.rs.html

//		pub fn new(data: T) -> Arc<T> {
//        let x: Box<_> = box ArcInner {
//            strong: atomic::AtomicUsize::new(1),
//            data,
//        };
//        Self::from_inner(Box::into_raw_non_null(x))
//  	}
//
//		fn clone(&self) -> Arc<T> {
//		  // Increasing the reference counter can always be done with memory_order_relaxed: 
//		  // New references to an object can only be formed from an existing reference,
//		  // and passing an existing reference from one thread to another must already provide any required synchronization. 		
//        let old_size = self.inner().strong.fetch_add(1, Relaxed);
//		  // Don't support too many references. Shouldn't happen in real programs.
//        if old_size > MAX_REFCOUNT {
//            unsafe {
//                abort();
//            }
//        }
//        Self::from_inner(self.ptr)
//    }
//    fn drop(&mut self) {
//        if self.inner().strong.fetch_sub(1, Release) != 1 {
//            return;
//        }
//        atomic::fence(Acquire);
//        unsafe {
//            self.drop_slow();
//        }
//    }

max_value 6;
global strong, data, msg1=1, msg2, msg3;
track strong: all;
track msg1: 0,1;
track msg2: 0,1;
track msg3: 0,1;

fn thread1{
	local t, available;
	// init ARC
	data.store(5);
	strong.store(1);
	available = 1;

	while (true){
			if (available){
					oneof({
							// Call worker2
							t = FADD(strong, 1, rlx, rlx);
							BCAS(msg2,0,1,rlx,rel);
					}{
							// Call worker3
							t = FADD(strong, 1, rlx, rlx);
							BCAS(msg3,0,1,rlx,rel);
					}{
							// Do nothing
							// Use data
							t = data.load();
							assert(t == 5);
							skip;
					}{
							// Drop and terminate
							t = FADD(strong, -1, rlx, rel);
							if (t == 1){
									fence(acq);
									data.store(0);
									t = data.load();
									assert(t == 0);
							}
							msg1.store(0);
							available = 0;
					});
			} else {
					wait(msg1, 1, acq);
					available = 1;
			}
	}
}

fn thread2{
	local t,available;

	while (true){
			if (available){
					oneof({
							// Call worker1
							t = FADD(strong, 1, rlx, rlx);
							BCAS(msg1,0,1,rlx,rel);
					}{
							// Call worker3
							t = FADD(strong, 1, rlx, rlx);
							BCAS(msg3,0,1,rlx,rel);
					}{
							// Do nothing
							// Use data
							t = data.load();
							assert(t == 5);
							skip;
					}{
							// Drop and terminate
							t = FADD(strong, -1, rlx, rel);
							if (t == 1){
									fence(acq);
									data.store(0);
									t = data.load();
									assert(t == 0);
							}
							msg2.store(0);
							available = 0;
					});
			} else {
					wait(msg2, 1, acq);
					available = 1;
			}
	}
}

fn thread3{
	local t,available;

	while (true){
			if (available){
					oneof({
							// Call worker1
							t = FADD(strong, 1, rlx, rlx);
							BCAS(msg1,0,1,rlx,rel);
					}{
							// Call worker2
							t = FADD(strong, 1, rlx, rlx);
							BCAS(msg2,0,1,rlx,rel);
					}{
							// Do nothing
							// Use data
							t = data.load();
							assert(t == 5);
							skip;
					}{
							// Drop and terminate
							t = FADD(strong, -1, rlx, rel);
							if (t == 1){
									fence(acq);
									data.store(0);
									t = data.load();
									assert(t == 0);
							}
							msg3.store(0);
							available = 0;
					});
			} else {
					wait(msg3, 1, acq);
					available = 1;
			}
	}
}
