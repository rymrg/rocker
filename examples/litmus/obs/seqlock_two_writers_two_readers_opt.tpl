// ROBUSTNESS egr: robust: ra. not: rlx.
// ROBUSTNESS wegr: robust: ra,rlx.

// For functional correctness, the loop has to be limited, 
// so the counter doesn't overflow, (e.g, while (cnt < 5)) // fix colors >.
// Then, the assertions in the readers can be uncommented.


max_value 12;
global counter, x, y;
track counter: all;

fn writer1{
	local c, cnt, t;
	while (cnt < 2) { 
		cnt = cnt + 1;
		start:
		c = counter.load(rlx);
		if (c & 1 == 1) goto start;
		t = CAS(counter,c,c+1,acq,rlx);
		if (t != c) goto start;
		x.store(cnt, rlx);
		y.store(cnt, rlx);
		counter.store(c+2,rel);
	}
}
fn writer2{
	local c, cnt, t;
	while (cnt < 2) { 
		cnt = cnt + 1;
		start:
		c = counter.load(rlx);
		if (c & 1 == 1) goto start;
	  	t = CAS(counter,c,c+1,acq,rlx);
		if (t != c) goto start;
		x.store(cnt, rlx);
		y.store(cnt, rlx);
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

fn reader2{
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

