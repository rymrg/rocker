// NOTROBUST
// Dekker's mutex algorithm:
// http://en.wikipedia.org/wiki/Dekker's_algorithm
global flag0, flag1, turn;

fn proca {
	local otherflag, localturn, a;

	while (true) {
		flag0.store(true);
		otherflag = flag1.load();
		while (otherflag == true) {
			localturn = turn.load();
			if (localturn == 0) goto myturn;
			flag0.store(false);
			localturn = turn.load();
			while (localturn != 0) {
				localturn = turn.load();
			}
			flag0.store(true);
			myturn:
			otherflag = flag1.load();
		}

		// critical section

		turn.store(1);
		flag0.store(false);
	}
}

fn procb {
	local otherflag, localturn, b;
	
	while (true) {
		flag1.store(true);
		otherflag = flag0.load();
		while (otherflag == true) {
			localturn = turn.load();
			if (localturn == 1) goto myturn;
			flag1.store(false);
			localturn = turn.load();
			while (localturn != 1) {
				localturn = turn.load();
			}
			flag1.store(true);
			myturn:
			otherflag = flag0.load();
		}

		// critical section

		turn.store(0);
		flag1.store(false);
	}
}

