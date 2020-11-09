// ROBUSTNESS egr: robust: ra,rlx.
// ROBUSTNESS wegr: robust: ra,rlx.

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

max_value 10;
global strong, data, msg1, msg2;
track strong: all;

fn thread1{
	local t;
	// init ARC
	data.store(5);
	strong.store(1);

	// Call worker1
	t = FADD(strong, 1, rlx, rlx);
	msg1.store(1, rel);

	// Use data
	t = data.load();
	assert(t == 5);


	// Drop and terminate
	t = FADD(strong, -1, rlx, rel);
	assume(t == 1); // if the value we read isn't 1, someone else still has the data
	fence(acq);

	data.store(0);
	t = data.load();

	assert(t == 0);
}

fn thread2{
	local t;
	// Wait for signal
	wait(msg1, 1, acq);

	// Call worker2
	t = FADD(strong, 1, rlx, rlx);
	msg2.store(1, rel);

	// Use data
	t = data.load();
	assert(t == 5);


	// Drop and terminate
	t = FADD(strong, -1, rlx, rel);
	assume(t == 1); // if the value we read isn't 1, someone else still has the data
	fence(acq);

	data.store(0);
	t = data.load();

	assert(t == 0);
}

fn thread3{
	local t;
	// Wait for signal
	wait(msg2, 1, acq);

	// Use data
	t = data.load();
	assert(t == 5);


	// Drop and terminate
	t = FADD(strong, -1, rlx, rel);
	assume(t == 1); // if the value we read isn't 1, someone else still has the data
	fence(acq);

	data.store(0);
	t = data.load();

	assert(t == 0);
}
