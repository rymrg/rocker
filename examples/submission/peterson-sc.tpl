// NOTROBUST
//
// Peterson's mutex algorithm:
// http://en.wikipedia.org/wiki/Peterson's_algorithm
//

max_value 2;
global turn,x1,x2;

fn proca {
		local a,b;

		x1.store(true);
		turn.store(1);

		loop:
		a = x2.load();
		if (a == false) goto enter;
		b = turn.load();
		if (b == 0) goto enter;
		goto loop;

		enter:

		x1.store(false);
}

fn procb {
		local a,b;

		x2.store(true);
		turn.store(0);

		loop:
		a = x1.load();
		if (a == false) goto enter;
		b = turn.load();
		if (b == 1) goto enter;
		goto loop;

		enter:

		x2.store(false);
}
