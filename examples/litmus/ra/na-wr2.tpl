// ROBUSTNESS wegr: not: ra.
global l;
na x;

fn f1{
	local a;
	x.nastore(5);
}
fn f2{
	local a;
	a = x.naload();
}
