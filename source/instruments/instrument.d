module instruments.instrument;

@safe interface Instrument {
	/**
	  Initialize meta memory

	  Params:
	  strings = An array of global variable names used in the program
	  threads = Amount of threads in the program
	  Returns: Code to initalize meta memory (like VRA, VSC, etc).
	 **/
	string initializeMemoryMetadata();

	/**
	  Write code to update value being read

	  Params:
	  mem = Memory location being accessed
	  Returns: Promela code to update view of reading
	 **/
	string loadStatementBefore(size_t currThread, string mem);

	/**
	  Write code to update value being written

	  Params:
	  mem = Memory location being modified
	  Returns: Promela code to update view of reading
	 **/
	string storeStatementBefore(size_t currThread, string mem);

	/**
	  Write code to update value being updated (RMW)

	  Params:
	  mem = Memory location being modified
	  Returns: Promela code to update view of reading
	 **/
	string rmwStatementBefore(size_t currThread, string mem);

	/**
	  Write code prior to waiting in a wait statement

	  Params:
	  currThread = Current thread
	  mem = Location being waited on
	  vals = Array of values we expect to read
	  Returns: Promela code to update view before waiting
	  **/
	string waitStatementBeforeWaiting(size_t currThread, string mem, string[] vals);

	/**
	  Write code after waiting in a wait statement

	  Params:
	  currThread = Current thread
	  mem = Location being waited on
	  Returns: Promela code to update view after waiting
	  **/
	string waitStatementAfterWaiting(size_t currThread, string mem);

	/**
	  Write code prior to waiting in a BCAS statement

	  Params:
	  currThread = Current thread
	  mem = Location being waited on
	  val = Black until mem has value val
	  Returns: Promela code to update view before BCAS blocking
	  **/
	string bcasStatementBeforeWaiting(size_t currThread, string mem, string val);

	/**
	  Write code prior changing value in a BCAS statement

	  Params:
	  currThread = Current thread
	  mem = Location  of BCAS
	  Returns: Promela code to update view before CAS of BCAS
	  **/
	string bcasStatementBefore(size_t currThread, string mem);

	/**
	  Write code prior to executing CAS statement

	  Params:
	  currThread = Current thread
	  mem = Location of CAS
	  expr = Expression to try and CAS on
	  Returns: Promela code to update view before trying to execute CAS
	  **/
	string casStatementBefore(size_t currThread, string mem, string expr);

	/**
	  Write code prior to CAS resulting in read (i.e. memory has different value)

	  Params:
	  currThread = Current thread
	  mem = Location of CAS
	  expr = Expression we tried to read
	  Returns: Promela code to update view before a failed CAS
	  **/
	string casStatementBeforeRead(size_t currThread, string mem, string expr);

	/**
	  Write code prior to a successful CAS (i.e. memory has expr)

	  Params:
	  currThread = Current thread
	  mem = Location of CAS
	  expr = Expression to try and CAS on
	  Returns: Promela code to update view before a successful CAS
	  **/
	string casStatementBeforeUpdate(size_t currThread, string mem, string expr);

	/**
	  Write code to update value being read (Non atomic)

	  Params:
	  mem = Memory location being accessed
	  Returns: Promela code to update view of reading
	 **/
	string naLoadStatementBefore(size_t currThread, string mem);

	/**
	  Write code before the atomic code for writing the atomic variable

	  Params:
	  mem = Memory location being modified
	  Returns: Promela code to update view of writing
	 **/
	string naStoreStatementBeforeAtomic(size_t currThread, string mem);

	/**
	  Write code to update value being written (Non atomic)
	  This happens in the atomic block of the acctual assignment

	  Params:
	  mem = Memory location being modified
	  Returns: Promela code to update view of writing
	 **/
	string naStoreStatementBefore(size_t currThread, string mem);

	/**
	  Returns a map of locals used by the instrumentation

	  Returns: Value -> Type map of locals used by instrument
	  */
	string[string] getLocals();
}
