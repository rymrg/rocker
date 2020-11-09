// ROBUSTNESS egr: robust: ra. not: rlx.
// ROBUSTNESS wegr: robust: ra. not: rlx.
max_value 2;
global x;
na n;

fn proca {
	local r;
	r = n.naload();
	x.store(1);
}

fn procb {
	local r;
	wait(x, 1);
	r = n.naload();
	x.store(2,rel);
}
fn procc {
	wait(x, 2, acq);
	n.nastore(1);

}

