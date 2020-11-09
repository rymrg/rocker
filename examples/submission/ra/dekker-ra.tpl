// ROBUSTNESS egr: robust: ra,rlx.
// ROBUSTNESS wegr: robust: ra,rlx.
// Dekker's mutex algorithm:
// http://en.wikipedia.org/wiki/Dekker's_algorithm
global flag0, flag1, turn;

fn proca {
	local otherflag, localturn, t;
    while (true) { 
        // enter critical section
		beginloop:
        flag0.store(true, rel);
    	fence;
        otherflag = flag1.load(acq);
        while (otherflag == true) { 
            localturn = turn.load(acq);
            if (localturn == 0) goto myturn;
            flag0.store(false, rel);
    		fence;
            localturn = turn.load(acq);
            while (localturn != 0) {
				localturn = turn.load(acq);
            }
			goto beginloop;
            myturn:
            otherflag = flag1.load(acq);
        }

        // critical section
		//k.store(1, rel);
		//t = k.load(acq);
		//assert(t == 1);

        // exit critical section
        turn.store(1, rel);
        flag0.store(false, rel);
    }
}

fn procb {
    local otherflag, localturn, t;
    while (true) { 
		// enter critical section
        beginloop:
        flag1.store(true, rel);
    	fence;
		otherflag = flag0.load(acq);
        while (otherflag == true) { 
			localturn = turn.load(acq);
            if (localturn == 1) goto myturn;
            flag1.store(false, rel);
    		fence;
			localturn = turn.load(acq);
            while (localturn != 1) {
				localturn = turn.load(acq);
            }
			goto beginloop;
            myturn:
            otherflag = flag0.load(acq);
        }

        // critical section
		//k.store(2, rel);
		//t = k.load(acq);
		//assert(t == 2);

        // exit critical section
        turn.store(0, rel);
        flag1.store(false, rel);
    }
} 
