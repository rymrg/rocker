// ROBUSTNESS egr: not: ra,rlx.
// ROBUSTNESS wegr: not: ra,rlx.
max_value 5;
global buf, counter, spinlock, z, ready;

fn initalize{
	spinlock.store(3);
	ready.store(1);
}
fn release{
	spinlock.store(5);
}

 fn writer{
 	local cnt;
 	wait(ready, 1);
  	counter.store(cnt+2);
 }

 fn lockerreader{
 	local a, cnt_b,value,cnt_e;
	wait(ready, 1);
 	 head:
 	 a = FADD(spinlock, -1);
 
 	enter:
	skip;
 
 	readhead:
 	cnt_b = counter.load();
 }

fn readerlocker{
	local a, cnt_b,value,cnt_e;
	wait(ready, 1);
	readhead:
	cnt_b = counter.load();

	 head:
	 a = FADD(spinlock, -1);

}
