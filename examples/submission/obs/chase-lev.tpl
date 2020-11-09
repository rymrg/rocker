// ROBUSTNESS egr: robust: ra,rlx.
// spin_depth 6

// Dynamic Circular Work-Stealing Deque (Chase-Lev SPAA'05)
// Adopted from 
// https://github.com/PhongNgo/persistence/blob/master/examples/single/dynamic_struture_algorithms/chase_lev/chase-lev-wsq.c
// (no resizing, no "return full" in put)
//

// and https://github.com/jeehoonkang/crossbeam-rfcs/blob/deque-proof/text/2018-01-07-deque-proof.md
// One owner and two thieves

// Using same SC fences required for robustness against RA
// 

global top = 1, bottom = 1;

fn owner{

	local t, t_new, b;

	while (true) {

		oneof ({
			// popBottom
			b = bottom.load();
			b = b - 1;
			bottom.store(b, rel);
			fence(seq_cst);
			t = top.load();
			if (b < t) {
				bottom.store(t, rlx); 
				// return empty
			} else {
				if (b > t) {
					skip;
					// return object
				} else { // b == t
					t_new = CAS(top, t, t + 1, acq, rel);
					bottom.store(t + 1, rlx);
					// return object if t_new = t, and empty otherwise
				}
			}
		}{
			// pushBottom
			b = bottom.load();
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
		t = top.load(rlx);
		fence(seq_cst);
		b = bottom.load(rlx);
		if (b <= t) {
			skip; // return empty
		} else {
			fence(acq);
			BCAS(top, t, t + 1, rlx, rel);
			// return object if t_new = t, and abort otherwise
		}
	}
}

fn thief2{

	local t, t_new, b;

	while (true) {
		fence(seq_cst);
		t = top.load(rlx);
		fence(seq_cst);
		b = bottom.load(rlx);
		if (b <= t) {
			skip; // return empty
		} else {
			fence(acq);
			BCAS(top, t, t + 1, rlx, rel);
			// return object if t_new = t, and abort otherwise
		}
	}
}
