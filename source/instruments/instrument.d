module instruments.instrument;
import instruments.access;
import std.typecons;

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
	  currThread = Current thread
	  mem = Memory location being accessed
	  reg = Register to get the value
	  loadType = Load access level
	  Returns: Promela code to update view of reading
	 **/
	string loadStatementBefore(size_t currThread, string mem, string reg, LoadType loadType);

	/**
	  Write code to update value being written

	  Params:
	  currThread = Current thread
	  mem = Memory location being modified
	  storeType = Store access level
	  Returns: Promela code to update view of reading
	 **/
	string storeStatementBefore(size_t currThread, string mem, StoreType storeType);

	/**
	  Write code to update value being updated (RMW)

	  Params:
	  currThread = Thread making the change
	  mem = Memory location being modified
	  reg = Register to get the value
	  loadType = Read access
	  storeType = Write access
	  Returns: Promela code to update view of reading
	 **/
	string rmwStatementBefore(size_t currThread, string mem, string reg, LoadType loadType, StoreType storeType);

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
	  loadType = Access by which the value was read
	  Returns: Promela code to update view after waiting
	  **/
	string waitStatementAfterWaiting(size_t currThread, string mem, LoadType loadType);

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
	  loadType = How the value is read
	  storeType = How the value is written
	  Returns: Promela code to update view before CAS of BCAS
	  **/
	string bcasStatementBefore(size_t currThread, string mem, LoadType loadType, StoreType storeType);

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
	  loadType = How the value is read
	  Returns: Promela code to update view before a failed CAS
	  **/
	string casStatementBeforeRead(size_t currThread, string mem, string expr, LoadType loadType);

	/**
	  Write code prior to a successful CAS (i.e. memory has expr)

	  Params:
	  currThread = Current thread
	  mem = Location of CAS
	  expr = Expression to try and CAS on
	  loadType = How the value is read
	  storeType = How the value is written
	  Returns: Promela code to update view before a successful CAS
	  **/
	string casStatementBeforeUpdate(size_t currThread, string mem, string expr, LoadType loadType, StoreType storeType);

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

	  Params:
	  currThread = Thread of the locals
	  Returns: Value -> Type map of locals used by instrument
	  */
	string[string] getLocals(size_t currThread);

	/**
	  Returns code for executing a fence

	  Params:
	  currThread = Current thread
	  fenceType = Type of fence

	  Returns: Either [false - fence should be contered to update] or [true, Promela code to execute fence]
	  */
	Tuple!(bool, string) fence(size_t currThread, FenceType fenceType);


	/**
	  Returns code to verify local variable is not dirty

	  Params:
	  currThread = Current thread
	  var = Local variable to verify

	  Returns: Code to verify local variable can be used
	  */
	string verifyLocal(size_t currThread, in string var);

	/**
	  Returns code to clean local variable after local assignment

	  Params:
	  currThread = Current thread
	  var = Local variable to clean

	  Returns: Code to clean local variable 
	  */
	string cleanLocal(size_t currThread, in string var);

	/**
	  Returns code to copy taintness status from variables
	  If any of them is tainted, so are the rest

	  Params:
	  currThread = Current thread
	  var = Local variable to update
	  vars = Local variable to to be used for taint test

	  Returns: Code to clean local variable 
	  */
	string transetiveTaint(size_t currThread, in string var, in string[] vars);

	/**
	  Returns code to verify local variables are not dirty

	  Params:
	  currThread = Current thread
	  vars = Local variables to verify

	  Returns: Code to verify local variables can be used
	  */
	final string verifyLocal(size_t currThread, in string[] vars){
		import std.algorithm.iteration : map;
		import std.string : join;
		return vars.map!(a=>verifyLocal(currThread, a)).join;
	}
}
