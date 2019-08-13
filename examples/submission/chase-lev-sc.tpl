// NOTROBUST

// Dynamic Circular Work-Stealing Deque (Chase-Lev SPAA'05)
// Adopted from 
// https://github.com/PhongNgo/persistence/blob/master/examples/single/dynamic_struture_algorithms/chase_lev/chase-lev-wsq.c
// (no resizing, no "return full" in put)
//
// One owner and two thieves
// Fences added to ensure robustness against RA
// 

global top = 1, bottom = 1;

fn owner{

	local t, t_new, b;

	while (true) {

		oneof ({
			// popBottom
			b = bottom.load();
			b = b - 1;
			bottom.store(b);
			t = top.load();
			if (b < t) {
				bottom.store(t); 
				// return empty
			} else {
				if (b > t) {
					skip;
					// return object
				} else { // b == t
					t_new = CAS(top, t, t + 1);
					bottom.store(t + 1);
					// return object if t_new = t, and empty otherwise
				}
			}
		}{
			// pushBottom
			b = bottom.load();
			t = top.load();
			assume(b < 200);
			if (b > t + 20) {
				skip; // return: full
			} else {
				bottom.store(b + 1);
			}
		});
	}
}

fn thief1{

	local t, t_new, b;

	while (true) {
		t = top.load();
		b = bottom.load();
		if (b <= t) {
			skip; // return empty
		} else {
			BCAS(top, t, t + 1);
			// return object if t_new = t, and abort otherwise
		}

	}
}

fn thief2{

	local t, t_new, b;

	while (true) {
		t = top.load();
		b = bottom.load();
		if (b <= t) {
			skip; // return empty
		} else {
			BCAS(top, t, t + 1);
			// return object if t_new = t, and abort otherwise
		}
	}
}
