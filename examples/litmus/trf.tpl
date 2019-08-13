// ROBUST
// A robust program with a triangular data race.
max_value 2;
global x,y;

fn t1{
	local r;
	x.store(1);
	r = y.load();
}
fn t2{
	y.store(1);
}

