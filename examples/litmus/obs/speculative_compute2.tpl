// ROBUSTNESS egr: not: ra.
// ROBUSTNESS wegr: robust: ra. not: rlx.


max_value 4;
global x, y1, y2, z;

fn proca {
	oneof({
			y1.store(1);
			y2.store(1);
			x.store(1);
	}{
			y2.store(1);
			y1.store(1);
			x.store(2);
	}
	);
}

fn procb {
	local a,b,a1,b1,c;
	a = y1.load();
	b = y2.load();
	c = x.load();

	if (c == 1){
			z.store(1);
	} else { if (c == 2) {
			z.store(b);
	} }
}

