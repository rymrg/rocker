// ROBUST
//
// Hermann Kopetz and J. Reisinger. The non-blocking write protocol
// nbw: A solution to a real-time synchronisation problem. In IEEE Real-
// Time Systems Symposium’93, pages 131–137, 1993.
//
// Writer, Reader.
//
// Robust
// Run with -s10000000
max_value 5;
global buf, counter, spinlock=1, k;

fn release{
	unlock(spinlock);
}

fn writer{
	local cnt, rounds;
	rounds = 0;
	while (rounds < 5){
		rounds = rounds + 1;
 		cnt = counter.load();
 		counter.store(cnt+1);
 		buf.store(666);
 		counter.store(cnt+2);
	}
}

 fn lockerreader{
 	local a, cnt_b,value,cnt_e,t,i;
 	i = 2;
	while (true){
		lock(spinlock);
	 
		enter:
		// CS
		k.store(i);
		t = k.load();
		assert (t == i);
		
		// unlock
	 	unlock(spinlock);
	 
		readhead:
		cnt_b = counter.load();
		value = buf.load();
		cnt_e = counter.load();
		if (cnt_b != cnt_e || (cnt_b & 1) == 1) goto readhead;
	}
 }

fn readerlocker{
	local a, cnt_b,value,cnt_e,t,i;
 	i = 3;

	while (true){
		readhead:
		cnt_b = counter.load();
		value = buf.load();
		cnt_e = counter.load();
		if (cnt_b != cnt_e || (cnt_b & 1) == 1) goto readhead;
		
		lock(spinlock);

		enter:
		// CS
		k.store(i);
		t = k.load();
		assert (t == i);
		
		// unlock
		unlock(spinlock);
	}
}
