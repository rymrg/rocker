// NOTROBUST
max_value 5;
global x, y;

fn t1{
	x.store(1);
}

fn t2{
	local ebx;
	y.store(1);
	x.store(1);
	loop:
	ebx = x.load();
	if (ebx == 0) goto loop;
}

fn t3{
	local ecx, edy;
	ecx = x.load();
	// ecx == 1
	edy = y.load();
	// edy == 0
	edy = y.load();
	// == edy 2
}
