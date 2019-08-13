// ROBUST
max_value 1;
global x, y;
track x: 0;

fn t1{
	local b;
	BCAS(x, 0, 1);
	x.store(0);
	b = y.load();
}

fn t2{
	local c;
	y.store(1);
	BCAS(x, 0, 1);
}
