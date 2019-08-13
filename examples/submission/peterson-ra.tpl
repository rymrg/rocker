// ROBUST
//
// Peterson's mutex algorithm:
// http://en.wikipedia.org/wiki/Peterson's_algorithm
//
// Fences added for robustness in RA
max_value 2;
global turn,x1,x2,k;

fn proca {
		local a,b,i,t;
		i = 0;
		while (true){
				x1.store(true);
				fence;
				turn.store(1-i);
				fence;

				loop:
				a = x2.load();
				if (a == false) goto enter;
				b = turn.load();
				if (b == i) goto enter;
				goto loop;

				enter:
				k.store(i);
				t = k.load();
				assert(t == i);

				x1.store(false);
		}

}

fn procb {
		local a,b,i,t;
		i = 1;
		while (true){
				x2.store(true);
				fence;
				turn.store(1-i);
				fence;

				loop:
				a = x1.load();
				if (a == false) goto enter;
				b = turn.load();
				if (b == i) goto enter;
				goto loop;

				enter:
				k.store(i);
				t = k.load();
				assert(t == i);

				x2.store(false);
		}
}
