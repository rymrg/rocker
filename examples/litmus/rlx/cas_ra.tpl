// ROBUSTNESS egr: robust: ra,rlx.
max_value 2;
global x,y;
track x: 0;

fn f1{
	local a;
	a = FADD(x,1, acq, rel);
	a = y.load(acq);
}
fn f2{
	local a;
	y.store(1, rel);
	a = CAS(x,0,1, acq,rel);
}
