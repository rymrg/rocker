// ROBUSTNESS egr: robust: ra. not: rlx.
// ROBUSTNESS wegr: robust: ra,rlx.

// For functional correctness, the loop has to be limited, 
// so the counter doesn't overflow, (e.g, while (cnt < 5)) // fix colors >.
// Then, the assertions in the readers can be uncommented.


// FADD replaced wiht BCAS because changing a value that isn't the expected value results in looping

max_value 6;
global counter, x, y;
track counter: all;

fn writer{
	local c , cnt;

	
	while (cnt < 2) { 
		cnt = cnt + 1;
		c = counter.load(acq);
		BCAS(counter,c,c+1,acq,rel);
		x.store(cnt, rel);
		y.store(cnt, rel);
		counter.store(c+2,rel);
	}
}

fn reader1{
	local c1, c2, x1, y1;
	while (true){
		reread:
		c1 = counter.load(acq);
		if (c1 & 1 == 1) goto reread;
		x1 = x.load(rlx);
		y1 = y.load(rlx);
		BCAS(counter, c1, c1, rlx, rel);
		//if (c1 != c2) goto reread;
		assert (x1 == y1);
	}
}
