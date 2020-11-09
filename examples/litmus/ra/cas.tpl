// ROBUSTNESS egr: robust: ra.
max_value 2;
global x,y;
track x: 0;

fn f1{
	local a;
	a = FADD(x,1);
	a = y.load();
}
fn f2{
	local a;
	y.store(1);
	a = CAS(x,0,1);
}
