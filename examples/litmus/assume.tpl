// ROBUST
global x;

fn f1{
	local a;
	x.store(5);
	a = wait(x, 10, 11);
	assume(a == 11);
	assert(a == 11);
	assume(a == 0);
	assert(0);
}
fn f2{
	local a;
	a = wait(x, 11, 5);
	assume(a == 5);
	assert(a == 5);
	x.store(11);
	assume(a == 0);
	assert(0);
}
