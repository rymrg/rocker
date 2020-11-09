// ROBUSTNESS egr: robust: ra,rlx.
// spin_depth 6

// Dynamic Circular Work-Stealing Deque (Chase-Lev SPAA'05)
// Adopted from 
// https://github.com/PhongNgo/persistence/blob/master/examples/single/dynamic_struture_algorithms/chase_lev/chase-lev-wsq.c
// (no resizing, no "return full" in put)
//
// One owner and two thieves

// Using same SC fences required for robustness against RA
// 

global top = 1, bottom = 1;

fn owner{

	local t, t_new, b;

	while (true) {

		oneof ({
			// popBottom
			b = bottom.load(acq);
			b = b - 1;
			bottom.store(b, rel);
			fence(seq_cst);
			t = top.load(acq);
			if (b < t) {
				bottom.store(t, rel); 
				// return empty
			} else {
				if (b > t) {
					skip;
					// return object
				} else { // b == t
					t_new = CAS(top, t, t + 1, acq, rel);
					bottom.store(t + 1, rel);
					// return object if t_new = t, and empty otherwise
				}
			}
		}{
			// pushBottom
			b = bottom.load(acq);
			fence(seq_cst);
			t = top.load(acq);
			assume(b < 200);
			if (b > t + 20) {
				skip; // return: full
			} else {
				bottom.store(b + 1, rel);
			}
		});
	}
}

fn thief1{

	local t, t_new, b;

	while (true) {
		fence(seq_cst);
		t = top.load(acq);
		fence(seq_cst);
		b = bottom.load(acq);
		if (b <= t) {
			skip; // return empty
		} else {
			BCAS(top, t, t + 1, acq, rel);
			// return object if t_new = t, and abort otherwise
		}
	}
}

fn thief2{

	local t, t_new, b;

	while (true) {
		fence(seq_cst);
		t = top.load(acq);
		fence(seq_cst);
		b = bottom.load(acq);
		if (b <= t) {
			skip; // return empty
		} else {
			BCAS(top, t, t + 1, acq, rel);
			// return object if t_new = t, and abort otherwise
		}
	}
}
