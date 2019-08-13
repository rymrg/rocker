// ROBUST
max_value 2;
global y;
na x;

fn proca {
	x.nastore(1);
	y.store(1);
}

fn procb {
	local a,b;
	a = y.load();
	while (a == 0){
		a = y.load();
	}
	b = x.naload();
}

