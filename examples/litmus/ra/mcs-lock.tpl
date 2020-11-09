// ROBUSTNESS egr: robust: ra.
// MCS lock, as presented in
//
// Maurice Herlihy and Nir Shavit. The art of multiprocessor programming.
// Morgan Kaufmann, 2008. Page 155.
//
// IS robust.
//
//   public void lock() {
// q1: QNode qnode = myNode.get();
// q2: QNode pred = tail.getAndSet(qnode);
// q3: if (pred != null) {
// q4:   qnode.locked = true;
// q5:   pred.next = qnode;
// q6:   while (qnode.locked) {}
//     }
//   }
//
//   public void unlock() {
// u1: QNode qnode = myNode.get();
// u2: if (qnode.next == null) {
// u3:   if (tail.compareAndSet(qnode, null))
// u4:     return;
// u5:   while (qnode.next == null) {}
//     }
// u6: qnode.next.locked = false;
// u7: qnode.next = null;
// }
//
// Memory layout:
// tail pointer              : 0
// myNode pointer of thread 1: 1
// myNode pointer of thread 2: 2
max_value 20;
global tptr, q1, q1lock, q1next, q2, q2lock, q2next, lck;
fn thread1{
	local tail, qnode, pred, locked, tmp;
	q1.store(1);
	lock(lck);
	tail = tptr.load();
	tptr.store(1);
	unlock(lck);
	if (tail == 0) goto unlck;
	q1lock.store(true);
	if (tail == 1) goto tptrNext1;
	if (tail == 2) goto tptrNext2;
	tptrNext1:
	q1next.store(1);
	goto tptrNextDone;
	tptrNext2:
	q2next.store(1);
	goto tptrNextDone;

	tptrNextDone:
	wait(q1lock, 0);

	unlck:
	tmp = q1next.load();
	if (tmp != 0) goto cleanlock;
	lock(lck);
	// skip check if qnode == null
	tmp = q1next.load();
	while (tmp == 0) { 
		tmp = q1next.load();
	}

	cleanlock:
	q1lock.store(false);
	q1next.store(0);

	end:
	skip;
}

fn thread2{
 	local tail, qnode, pred, locked, tmp;
 	q2.store(2);
 	lock(lck);
 	tail = tptr.load();
 	tptr.store(2);
 	unlock(lck);
 	if (tail == 0) goto unlck;
 	q2lock.store(true);
 	if (tail == 1) goto tptrNext1;
 	if (tail == 2) goto tptrNext2;
 	tptrNext1:
 	q1next.store(2);
 	goto tptrNextDone;
 	tptrNext2:
 	q2next.store(2);
 	goto tptrNextDone;
 
 	tptrNextDone:
 	wait(q2lock, 0);
 
 	unlck:
	tmp = q2next.load();
 	if (tmp != 0) goto cleanlock;
 	lock(lck);
 	// skip check if qnode == null
	tmp = q2next.load();
	while (tmp == 0) { 
		tmp = q2next.load();
	}
 
 	cleanlock:
 	q2lock.store(false);
 	q2next.store(0);
 
 	end:
 	skip;
 }

