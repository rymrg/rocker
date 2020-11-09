// ROBUSTNESS egr: robust: ra,rlx.
// ROBUSTNESS wegr: robust: ra,rlx.
// spin_depth 8
// Ticket spin lock from linux kernel
// http://www.cl.cam.ac.uk/~pes20/weakmemory/ecoop10.pdf
max_value 10;
global x, y, k;

fn t0{
	local ticket, t, i;
	i = 0;
	while (true) {
		ticket = FADD(y, 1, acq, rel);
		wait(x, ticket, acq);

		// CS
		k.store(i, rel);
		t = k.load(acq);
		assert (t == i);

		// Release
		x.store(ticket + 1, rel);
	}
}
	
fn t1{
	local ticket, t, i;
	i = 1;
	while (true) {
		ticket = FADD(y, 1, acq, rel);
		wait(x, ticket, acq);

		// CS
		k.store(i, rel);
		t = k.load(acq);
		assert (t == i);

		// Release
		x.store(ticket + 1, rel);
	}
}

fn t2{
	local ticket, t, i;
	i = 2;
	while (true) {
		ticket = FADD(y, 1, acq, rel);
		wait(x, ticket, acq);

		// CS
		k.store(i, rel);
		t = k.load(acq);
		assert (t == i);

		// Release
		x.store(ticket + 1, rel);
	}
}

fn t3{
	local ticket, t, i;
	i = 3;
	while (true) {
		ticket = FADD(y, 1, acq, rel);
		wait(x, ticket, acq);

		// CS
		k.store(i, rel);
		t = k.load(acq);
		assert (t == i);

		// Release
		x.store(ticket + 1, rel);
	}
}
