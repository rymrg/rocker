// ROBUST
global x;

fn t1{
	local a;
	x.store(1);
	a = x.load();
//	assert(a == 0);
}
