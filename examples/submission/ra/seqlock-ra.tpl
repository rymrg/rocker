// ROBUSTNESS egr: robust: ra,rlx.
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
				c = counter.load(acq);
				if (c & 1 == 1) goto start;
				t = CAS(counter,c,c+1,acq,rel);
				if (t != c) goto start;
				x.store(cnt, rel);
				y.store(cnt, rel);
				counter.store(c+2,rel);
			}{
				// Read
				reread:
				c1 = counter.load(acq);
				if (c1 & 1 == 1) goto reread;
				x1 = x.load(acq);
				y1 = y.load(acq);
				c2 = counter.load(acq);
				if (c1 != c2) goto reread;
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
				c = counter.load(acq);
				if (c & 1 == 1) goto start;
				t = CAS(counter,c,c+1,acq,rel);
				if (t != c) goto start;
				x.store(cnt, rel);
				y.store(cnt, rel);
				counter.store(c+2,rel);
			}{
				// Read
				reread:
				c1 = counter.load(acq);
				if (c1 & 1 == 1) goto reread;
				x1 = x.load(acq);
				y1 = y.load(acq);
				c2 = counter.load(acq);
				if (c1 != c2) goto reread;
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
				c = counter.load(acq);
				if (c & 1 == 1) goto start;
				t = CAS(counter,c,c+1,acq,rel);
				if (t != c) goto start;
				x.store(cnt, rel);
				y.store(cnt, rel);
				counter.store(c+2,rel);
			}{
				// Read
				reread:
				c1 = counter.load(acq);
				if (c1 & 1 == 1) goto reread;
				x1 = x.load(acq);
				y1 = y.load(acq);
				c2 = counter.load(acq);
				if (c1 != c2) goto reread;
				assert (x1 == y1);
			}
			);
	}
}
