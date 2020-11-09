// ROBUSTNESS egr: robust: ra,rlx.
max_value 10;
global flag1, turn;

fn proca {
	local otherflag;
    otherflag = flag1.load(acq);
    if (otherflag == 0) goto end;
    // CS
    turn.store(1,rel);
    end:
    skip;
}

fn procb {
        turn.store(0,rel);
        flag1.store(1,rel);
}

