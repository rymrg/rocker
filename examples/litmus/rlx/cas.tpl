// ROBUSTNESS egr: robust: ra. not: rlx.
// ROBUSTNESS wegr: robust: rlx.
max_value 2;
global x,y;
track x: 0;

fn f1{
	local a;
	a = FADD(x,1, rlx, rlx);
	a = y.load(rlx);
}
fn f2{
	local a;
	y.store(1, rlx);
	a = CAS(x,0,1, rlx,rlx);
}
