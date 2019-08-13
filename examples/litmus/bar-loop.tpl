// NOTROBUST
global x, y;

fn f1{
	local a;
	x.store(1);
	again:
	a = y.load();
	if (a != 1) goto again;
}

fn f2{
	local a;
	y.store(1);
	again:
	a = x.load();
	if (a != 1) goto again;
}
