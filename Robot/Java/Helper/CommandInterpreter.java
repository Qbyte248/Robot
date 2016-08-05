package Robot.Java.Helper;

/**
 * Defines an interface for a class which can interpret Commands
 */
public interface CommandInterpreter {
	
	/**
	 * interprets passed command
	 * 
	 * @param command which was read by CommandReader
	 */
	public void interpretCommand(Command command);
	
	/**
	 * @note if you have returned true you wont receive commands anymore
	 * @return true if you are finished reading commands; otherwise false
	 */
	public boolean finishedInterpretingCommands();
	
	/**
	 * if this method gets executed from CommandDistributor it has stopped reading commands
	 * and no commands will be sent to interpretCommand method. So this class can perform cleanup actions.
	 */
	default public void willFinishInterpretingCommands() {}
}
