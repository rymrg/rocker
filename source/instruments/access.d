module instruments.access;

enum LoadType {
	rlx,
	acq,
}

enum StoreType {
	rlx,
	rel,
}

enum FenceType {
	acq,
	rel,
	acq_rel,
	seq_cst,
	upd,
}
