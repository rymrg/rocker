// ROBUSTNESS egr: robust: ra,rlx.
// ROBUSTNESS wegr: robust: ra,rlx.
max_value 2;
global x, C;
na k;
track x: 0,1;

fn proca {
		local r;
		while (1) {
				lck:
				r = exchange(x,1,rlx,rlx);
				if (r != 0) goto lck;
				fence(acq);
				k.nastore(1);
				r = k.naload();
				x.store(0,rel);
		}
}

fn procb {
		local r;
		while (1) {
				lck:
				r = exchange(x,1,rlx,rlx);
				if (r != 0) goto lck;
				fence(acq);
				k.nastore(2);
				r = k.naload();
				x.store(0,rel);
		}
}
