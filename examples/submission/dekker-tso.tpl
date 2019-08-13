// ROBUST
// Dekker's mutex algorithm:
// http://en.wikipedia.org/wiki/Dekker's_algorithm
global flag0, flag1, turn;

fn proca {
	local otherflag, localturn, t;
    while (true) { 
        // enter critical section
		beginloop:
        flag0.store(true);
    	fence;
        otherflag = flag1.load();
        while (otherflag == true) { 
            localturn = turn.load();
            if (localturn == 0) goto myturn;
            flag0.store(false);
    		fence;
            localturn = turn.load();
            while (localturn != 0) {
				localturn = turn.load();
            }
			goto beginloop;
            myturn:
            otherflag = flag1.load();
        }

        // critical section
		//k.store(1);
		//t = k.load();
		//assert(t == 1);

        // exit critical section
        turn.store(1);
        flag0.store(false);
    }
}

fn procb {
    local otherflag, localturn, t;
    while (true) { 
		// enter critical section
        beginloop:
        flag1.store(true);
    	fence;
		otherflag = flag0.load();
        while (otherflag == true) { 
			localturn = turn.load();
            if (localturn == 1) goto myturn;
            flag1.store(false);
    		fence;
			localturn = turn.load();
            while (localturn != 1) {
				localturn = turn.load();
            }
			goto beginloop;
            myturn:
            otherflag = flag0.load();
        }

        // critical section
		//k.store(2);
		//t = k.load();
		//assert(t == 2);

        // exit critical section
        turn.store(0);
        flag1.store(false);
    }
} 
