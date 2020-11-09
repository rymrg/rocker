// ROBUSTNESS egr: robust: ra. not: rlx.
// ROBUSTNESS wegr: not: rlx.


// T1: do this several times:
//   lock
//   X=X+1
//   Y=Y+1
//   unlock
// 
// T2: 
// a=X //  optimistically hoping that we already have the updated values of X and Y.
// b=Y
// c = a + b  // stands for long computation using a and b
// 
// lock
// a1=X
// b1=Y
// if (a1 != a) or (b1 != b) then
//   c = a+b // repeat computation since we read different values
// use c
// unlock



max_value 10;
global x, y, l;

fn proca {
	local c,t;
	while (c < 10){
			lock(l);
			t = x.load();
			x.store(t+1);
			t = y.load();
			y.store(t+1);
			unlock(l);
	}
}

fn procb {
	local a,b,a1,b1,c;
	// Try to read value and hope computation is correct
	a = x.load();
	b = y.load();
	c = a + b; // Complex computation...

	lock(l);
	wait(x, a);
	wait(y, b);
	// Hides a if over the entire load + computation...
	verify(c);
	unlock(l);
	// use c
}

