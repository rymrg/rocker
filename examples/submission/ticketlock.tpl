// ROBUST
// Ticket spin lock from linux kernel
// http://www.cl.cam.ac.uk/~pes20/weakmemory/ecoop10.pdf
max_value 10;
global x, y, k;

fn t0{
	local ticket, t, i;
	i = 0;
	while (true) {
		ticket = FADD(y, 1);
		wait(x, ticket);

		// CS
		k.store(i);
		t = k.load();
		assert (t == i);

		// Release
		x.store(ticket + 1);
	}
}
	
fn t1{
	local ticket, t, i;
	i = 1;
	while (true) {
		ticket = FADD(y, 1);
		wait(x, ticket);

		// CS
		k.store(i);
		t = k.load();
		assert (t == i);

		// Release
		x.store(ticket + 1);
	}
}
