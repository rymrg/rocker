// ROBUSTNESS egr: not: ra.
// ROBUSTNESS wegr: robust: ra.
max_value 2;
global a,b,c,d,e,f;

fn proca {
	local r;
	a.store(1);
	b.store(1);
	r = c.load();
	r = e.load();
}

fn procb {
	local r;
	c.store(1);
	d.store(1);
	r = b.load();
	r = f.load();
}

fn procc {
	local r;
	e.store(1);
	f.store(1);
	r = a.load();
	r = d.load();
}
