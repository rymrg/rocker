// ROBUSTNESS egr: robust: ra,rlx.
// ROBUSTNESS wegr: robust: ra,rlx.

// Singleton with double-checked locking pattern
// We use acquire instead of consume
// 
// class X {
// public:
//   static X * instance()
//   {
//     X * tmp = instance_.load(boost::memory_order_consume);
//     if (!tmp) {
//       boost::mutex::scoped_lock guard(instantiation_mutex);
//       tmp = instance_.load(boost::memory_order_consume);
//       if (!tmp) {
//         tmp = new X;
//         instance_.store(tmp, boost::memory_order_release);
//       }
//     }
//     return tmp;
//   }
// private:
//   static boost::atomic<X *> instance_;
//   static boost::mutex instantiation_mutex;
// };
// boost::atomic<X *> X::instance_(0);

max_value 10;
global instance, lck, m1,m2,m3;
track lck: 0,1;

fn thread1{
	local t,a;
	t = instance.load(acq);
	if (t == 0){
			lock(lck);
			t = instance.load(acq); 
			if (t == 0){
					// Allocate singleton
					oneof({
							t = 1;
							m1.store(1);
					}{
							t = 2;
							m2.store(2);
					}{
							t = 3;
							m3.store(3);
					});
					instance.store(t, rel);
			}
			unlock(lck);
	}
	assert(t != 0);
	if (t == 1){
			a = m1.load();
	}
	if (t == 2){
			a = m2.load();
	}
	if (t == 3){
			a = m3.load();
	}
	verify(a);
	assert(a == t);
}
fn thread2{
	local t,a;
	t = instance.load(acq); 
	if (t == 0){
			lock(lck);
			t = instance.load(acq);
			if (t == 0){
					// Allocate singleton
					oneof({
							t = 1;
							m1.store(1);
					}{
							t = 2;
							m2.store(2);
					}{
							t = 3;
							m3.store(3);
					});
					instance.store(t, rel);
			}
			unlock(lck);
	}
	assert(t != 0);
	if (t == 1){
			a = m1.load();
	}
	if (t == 2){
			a = m2.load();
	}
	if (t == 3){
			a = m3.load();
	}
	verify(a);
	assert(a == t);
}

fn thread3{
	local t,a;
	t = instance.load(acq);
	if (t == 0){
			lock(lck);
			t = instance.load(acq); 
			if (t == 0){
					// Allocate singleton
					oneof({
							t = 1;
							m1.store(1);
					}{
							t = 2;
							m2.store(2);
					}{
							t = 3;
							m3.store(3);
					});
					instance.store(t, rel);
			}
			unlock(lck);
	}
	assert(t != 0);
	if (t == 1){
			a = m1.load();
	}
	if (t == 2){
			a = m2.load();
	}
	if (t == 3){
			a = m3.load();
	}
	verify(a);
	assert(a == t);
}

fn thread4{
	local t,a;
	t = instance.load(acq); 
	if (t == 0){
			lock(lck);
			t = instance.load(acq); 
			if (t == 0){
					// Allocate singleton
					oneof({
							t = 1;
							m1.store(1);
					}{
							t = 2;
							m2.store(2);
					}{
							t = 3;
							m3.store(3);
					});
					instance.store(t, rel);
			}
			unlock(lck);
	}
	assert(t != 0);
	if (t == 1){
			a = m1.load();
	}
	if (t == 2){
			a = m2.load();
	}
	if (t == 3){
			a = m3.load();
	}
	verify(a);
	assert(a == t);
}
