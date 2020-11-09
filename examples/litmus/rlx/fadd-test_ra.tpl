// ROBUSTNESS egr: not: ra,rlx.
// ROBUSTNESS wegr: not: ra,rlx.
max_value 5;
global buf, counter, spinlock, z, ready;

fn initalize{
	spinlock.store(3,rel);
	ready.store(1,rel);
}
fn release{
	spinlock.store(5,rel);
}

 fn writer{
 	local cnt;
 	wait(ready, 1, acq);
  	counter.store(cnt+2,rel);
 }

 fn lockerreader{
 	local a, cnt_b,value,cnt_e;
	wait(ready, 1, acq);
 	 head:
 	 a = FADD(spinlock, -1,acq,rel);
 
 	enter:
	skip;
 
 	readhead:
 	cnt_b = counter.load(acq);
 }

fn readerlocker{
	local a, cnt_b,value,cnt_e;
	wait(ready, 1, acq);
	readhead:
	cnt_b = counter.load(acq);

	 head:
	 a = FADD(spinlock, -1, acq,rel);

}
