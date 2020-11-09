// ROBUSTNESS egr: robust: ra,rlx.
// ROBUSTNESS wegr: robust: ra,rlx.

// Ref counted deletion
// Chasing away RAts
// Doesn't handle the allocation and only marks for deletion. Not actual deletion.

max_value 6;
global counter1,counter2,clean1,clean2;

fn t1{
	local a;

	a = FADD(counter1, 1, rlx, rlx);
	a = FADD(counter2, 1, rlx, rlx);

	// Do work

	// Release resource
	a = FADD(counter1, -1, rlx, rlx);
	if (a == 0){
			clean1.store(1);
	}
	a = FADD(counter2, -1, rlx, rlx);
	if (a == 0){
			clean2.store(1);
	}
	
}
fn t2{
	local a;

	a = FADD(counter1, 1, rlx, rlx);
	a = FADD(counter2, 1, rlx, rlx);

	// Do work

	// Release resource
	a = FADD(counter1, -1, rlx, rlx);
	if (a == 0){
			clean1.store(1);
	}
	a = FADD(counter2, -1, rlx, rlx);
	if (a == 0){
			clean2.store(1);
	}
	
}
