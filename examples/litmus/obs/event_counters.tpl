// ROBUSTNESS egr: robust: ra,rlx.
// ROBUSTNESS wegr: robust: ra,rlx.


max_value 10;
global t1,t2,t3,b1,b2,b3;

fn main{
	local a;

	wait(t1, 1, acq);
	wait(t2, 1, acq);
	wait(t3, 1, acq);

	a = b1.load(rlx);
	verify(a);
	a = b2.load(rlx);
	verify(a);
	a = b3.load(rlx);
	verify(a);
}

fn counter1{
	local a,i;
	while (i<3){
		oneof(
			{ a = FADD(b1, 1, rlx, rlx); }
			{ a = FADD(b2, 1, rlx, rlx); }
			{ a = FADD(b3, 1, rlx, rlx); }
		);
		i = i+1;
	}
	t1.store(1, rel);
}
fn counter2{
	local a,i;
	while (i<3){
		oneof(
			{ a = FADD(b1, 1, rlx, rlx); }
			{ a = FADD(b2, 1, rlx, rlx); }
			{ a = FADD(b3, 1, rlx, rlx); }
		);
		i = i+1;
	}
	t2.store(1, rel);
}
fn counter3{
	local a,i;
	while (i<3){
		oneof(
			{ a = FADD(b1, 1, rlx, rlx); }
			{ a = FADD(b2, 1, rlx, rlx); }
			{ a = FADD(b3, 1, rlx, rlx); }
		);
		i = i+1;
	}
	t3.store(1, rel);
}
