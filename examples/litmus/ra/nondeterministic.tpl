// ROBUSTNESS egr: robust: ra.
max_value 6;
global x;

fn a{
	oneof({
		x.store(1);
		x.store(3);
	}
	{
		x.store(2);
		x.store(4);
	});
}
