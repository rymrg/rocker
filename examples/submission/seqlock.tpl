// ROBUST

// For functional correctness, the loop has to be limited, 
// so the counter doesn't overflow, (e.g, while (cnt < 5)).
// Then, the assertions in the readers can be uncommented.

max_value 11;
global counter, x, y;

fn writer{
	local c , cnt;

	
	while (cnt < 5) { 
		cnt = cnt + 1;
		c = counter.load();
		counter.store(c+1);
		//x.store(cnt);
		//y.store(cnt);
		x.store(1);
		y.store(1);
		counter.store(c+2);
	}
}

fn reader1{
	local c1, c2, x1, y1;
	while (true){
		reread:
		c1 = counter.load();
		if (c1 & 1 == 1) goto reread;
		x1 = x.load();
		y1 = y.load();
		c2 = counter.load();
		if (c1 != c2) goto reread;
		//assert (x1 == y1);
	}
}
fn reader2{
	local c1, c2, x1, y1;
	while (true){
		reread:
		c1 = counter.load();
		if (c1 & 1 == 1) goto reread;
		x1 = x.load();
		y1 = y.load();
		c2 = counter.load();
		if (c1 != c2) goto reread;
		//assert (x1 == y1);
	}
}
fn reader3{
	local c1, c2, x1, y1;
	while (true){
		reread:
		c1 = counter.load();
		if (c1 & 1 == 1) goto reread;
		x1 = x.load();
		y1 = y.load();
		c2 = counter.load();
		if (c1 != c2) goto reread;
		//assert (x1 == y1);
	}
}
