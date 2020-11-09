// ROBUSTNESS egr: robust: ra. not: rlx.
// ROBUSTNESS wegr: robust: ra,rlx.

// We assume we have some struct in memory and the flag is a part of the struct.
// Thus we want to read the entire struct to the stack to preserve locality.
// We also let the hardware read most of the struct (sans the flag required
// to synchronize) in arbitrary order.

max_value 30;
global counter, x1,x2, y;
track counter: all;

fn thread1{
	local a,b,c;
	oneof({
			x1.store(1);
			x2.store(1);
	  }{
			x2.store(1);
			x1.store(1);
	});
	y.store(1,rel);
}
fn thread2{
	local a1,a2, c1, c2;
	c1 = y.load(acq);
	oneof({
			a1 = x1.load();
			a2 = x2.load();
	  }{
			a2 = x2.load();
			a1 = x1.load();
			});
	if (c1 == 1){
			verify(a1);
			verify(a2);
	}
}
