// ROBUST
global l;
na x;

fn f1{
	local a;
	lock(l);
	a = x.naload();
	unlock(l);
}
fn f2{
	local a;
	lock(l);
	a = x.naload();
	unlock(l);
}
