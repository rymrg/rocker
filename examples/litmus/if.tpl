// ROBUST
max_value 1;
global x;

fn f1{
	local a;
	if (a != 0){
		a = a + a;
		assert(a != 0);
	} else {
		assert(true);
	}
	if (a == 0){
		skip;
	} else {
		assert(false);
	}
	if (a != 0) {
		assert(false);
	}
}
