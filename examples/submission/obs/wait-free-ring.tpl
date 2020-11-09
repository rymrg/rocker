// ROBUSTNESS egr: robust: ra,rlx.
// ROBUSTNESS wegr: robust: ra,rlx.

// template<typename T, size_t Size>
// class ringbuffer {
// public:
//   ringbuffer() : head_(0), tail_(0) {}
// 
//   bool push(const T & value)
//   {
//     size_t head = head_.load(boost::memory_order_relaxed);
//     size_t next_head = next(head);
//     if (next_head == tail_.load(boost::memory_order_acquire))
//       return false;
//     ring_[head] = value;
//     head_.store(next_head, boost::memory_order_release);
//     return true;
//   }
//   bool pop(T & value)
//   {
//     size_t tail = tail_.load(boost::memory_order_relaxed);
//     if (tail == head_.load(boost::memory_order_acquire))
//       return false;
//     value = ring_[tail];
//     tail_.store(next(tail), boost::memory_order_release);
//     return true;
//   }
// private:
//   size_t next(size_t current)
//   {
//     return (current + 1) % Size;
//   }
//   T ring_[Size];
//   boost::atomic<size_t> head_, tail_;
// };

max_value 10;
global head, tail;

fn producer{
	local h, next, t, SIZE;
	SIZE = 6;
	
	//while (1) {
			h = head.load(rlx);
			next = (h+1)% SIZE;
			t = tail.load(acq);
			if (next == t) {
					// full
					skip;
			} else {
					// store value
					head.store(next, rel);
			}
	//}
}


fn consumer{
	local h, t, next, SIZE;
	SIZE = 6;

	while (1) {
			t = tail.load(rlx);
			h = head.load(acq);

			if (t == h){
					// Empty
					skip;
			} else {
					// read value
					next = (t+1) % SIZE;
					tail.store(next, rel);
			}
	}
}
