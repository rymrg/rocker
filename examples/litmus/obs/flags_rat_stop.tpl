// ROBUSTNESS egr: robust: ra,rlx.
// ROBUSTNESS wegr: robust: ra,rlx.


max_value 10;
global t1,t2,t3,dirty;

fn main{
	local a;

	t1.store(0, rlx);
	t2.store(0, rlx);
	t3.store(0, rlx);

	wait(t1, 1, acq);
	wait(t2, 1, acq);
	wait(t3, 1, acq);

	a = dirty.load(rlx);
	verify(a);
}

fn worker1{
	local a,i;
	a=t1.load(rlx);
	while (a){
		oneof(
			{ i = 0; }
			{ dirty.store(1, rlx); }
		);
		a=t1.load(rlx);
	}
	t1.store(1, rel);
}
fn worker2{
	local a,i;
	a=t2.load(rlx);
	while (a){
		oneof(
			{ i = 0; }
			{ dirty.store(1, rlx); }
		);
		a=t2.load(rlx);
	}
	t2.store(1, rel);
}
fn worker3{
	local a,i;
	a=t3.load(rlx);
	while (a){
		oneof(
			{ i = 0; }
			{ dirty.store(1, rlx); }
		);
		a=t3.load(rlx);
	}
	t3.store(1, rel);
}
