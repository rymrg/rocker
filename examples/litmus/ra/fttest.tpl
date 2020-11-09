// ROBUSTNESS egr: robust: ra.
max_value 10;
global flag1, turn;

fn proca {
	local otherflag;
    otherflag = flag1.load();
    if (otherflag == 0) goto end;
    // CS
    turn.store(1);
    end:
    skip;
}

fn procb {
        turn.store(0);
        flag1.store(1);
}

