// ROBUSTNESS egr: robust: ra. not: rlx.
// ROBUSTNESS wegr: robust: ra,rlx.


max_value 30;
global counter, x, y;
track counter: all;

fn thread1{
	local c, cnt, t, c1,c2,x1,y1;
	while (cnt < 4) { 
			oneof({
				// Write
				cnt = cnt + 1;
				start:
				c = counter.load(rlx);
				if (c & 1 == 1) goto start;
				t = CAS(counter,c,c+1,rlx,rlx);
				if (t != c) goto start;
				fence(acq);
				x.store(cnt, rlx);
				y.store(cnt, rlx);
				counter.store(c+2,rel);
			}{
				// Read
				reread:
				c1 = counter.load(rlx);
				if (c1 & 1 == 1) goto reread;
				fence(acq);
				x1 = x.load(rlx);
				y1 = y.load(rlx);
				BCAS(counter, c1, c1, rlx, rel);
				//if (c1 != c2) goto reread;
				assert (x1 == y1);
			}
			);
	}
}
fn thread2{
	local c, cnt, t, c1,c2,x1,y1;
	while (cnt < 4) { 
			oneof({
				// Write
				cnt = cnt + 1;
				start:
				c = counter.load(rlx);
				if (c & 1 == 1) goto start;
				t = CAS(counter,c,c+1,rlx,rlx);
				if (t != c) goto start;
				fence(acq);
				x.store(cnt, rlx);
				y.store(cnt, rlx);
				counter.store(c+2,rel);
			}{
				// Read
				reread:
				c1 = counter.load(rlx);
				if (c1 & 1 == 1) goto reread;
				fence(acq);
				x1 = x.load(rlx);
				y1 = y.load(rlx);
				BCAS(counter, c1, c1, rlx, rel);
				//if (c1 != c2) goto reread;
				assert (x1 == y1);
			}
			);
	}
}
fn thread3{
	local c, cnt, t, c1,c2,x1,y1;
	while (cnt < 4) { 
			oneof({
				// Write
				cnt = cnt + 1;
				start:
				c = counter.load(rlx);
				if (c & 1 == 1) goto start;
				t = CAS(counter,c,c+1,rlx,rlx);
				if (t != c) goto start;
				fence(acq);
				x.store(cnt, rlx);
				y.store(cnt, rlx);
				counter.store(c+2,rel);
			}{
				// Read
				reread:
				c1 = counter.load(rlx);
				if (c1 & 1 == 1) goto reread;
				fence(acq);
				x1 = x.load(rlx);
				y1 = y.load(rlx);
				BCAS(counter, c1, c1, rlx, rel);
				//if (c1 != c2) goto reread;
				assert (x1 == y1);
			}
			);
	}
}
