
/**
 * Defines an interface for a class which can interpret Commands
 */
public protocol CommandInterpreter {
	
	/**
	 * interprets passed command
	 * 
	 * @param command which was read by CommandReader
	 */
	func interpretCommand(_ command: Command);
	
	/**
	 * @note if you have returned true you wont receive commands anymore
	 * @return true if you are finished reading commands; otherwise false
	 */
	func finishedInterpretingCommands() -> Bool;
}
extension CommandInterpreter {
	/**
	 * if self method gets executed from CommandDistributor it has stopped reading commands
	 * and no commands will be sent to interpretCommand method. So self class can perform cleanup actions.
	 */
	public func willFinishInterpretingCommands() {}
}
