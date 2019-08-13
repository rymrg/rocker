// ROBUST
// Simple global barrier where threads wait for each other.
global x, y;
track x: 1;
track y: 1;

fn f1{
	x.store(1);
	wait(y, 1);
}

fn f2{
	y.store(1);
	wait(x, 1);
}
