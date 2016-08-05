package Robot.Java.Helper;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * Distributes Commands from an InputStream to CommandInterpreters
 * which can be added for logging with "this.addCommandInterpreter(...)"
 */
public class CommandDistributor extends Thread {

	private InputStream inputStream;
	private ArrayList<CommandInterpreter> commandInterpreters = new ArrayList<CommandInterpreter>();
	
	private boolean shouldStop = false;

	/**
	 * @param inputStream from which commands get interpreted
	 */
	public CommandDistributor(InputStream inputStream) {
		this.inputStream = inputStream;
		// start thread
		this.start();
	}
	
	/**
	 * notifies all command interpreters that they won't receive commands anymore
	 * and removes them from the list of command interpreters
	 */
	public synchronized void removeAllCommandInterpreters() {
		for (CommandInterpreter commandInterpreter : commandInterpreters) {
			commandInterpreter.willFinishInterpretingCommands();
		}
		commandInterpreters.clear();
	}
	
	/**
	 * calls removeAllCommandInterpretes and stops reading from inputStream
	 */
	public synchronized void stopThread() {
		removeAllCommandInterpreters();
		shouldStop = true;
	}
	
	/**
	 * adds commandInterpeter to list of command interpreters
	 * @param commandInterpreter which gets added
	 */
	public synchronized void addCommandInterpreter(CommandInterpreter commandInterpreter) {
		commandInterpreters.add(commandInterpreter);
	}

	@Override
	public void run() {
		try {

			String commandString = "";
			int c;

			// !!! can throw IOException
			while ((c = inputStream.read()) != -1) {
				
				if (shouldStop) {
					// stop thread
					return;
				}
				
				commandString += (char) c;

				// sort out commandInterpreters which don't read commands
				for (int i = 0; i < commandInterpreters.size(); i++) {
					if (commandInterpreters.get(i).finishedInterpretingCommands()) {
						commandInterpreters.remove(i);
						i--;
					}
				}
				
				if (Command.stringEndsWithEndDelimiter(commandString)) {
					
					Command command;
					try {
						// !!! can throw IllegalArgumentException
						command = Command.fromString(commandString);
					} catch (IllegalArgumentException e) {
						e.printStackTrace();
						// continue reading from input Stream and reset command String
						commandString = "";
						continue;
					}
					
					// FIXME
					/*if (!command.getCommandString().equals(Protocol.Heartbeat.heartbeat)) {
						System.out.println("Created command: " + command.convertToString());
					}*/
					
					// pass command to all commandInterpreters
					for (int i = 0; i < commandInterpreters.size(); i++) {
						commandInterpreters.get(i).interpretCommand(command);
					}
					
					// reset commandString
					commandString = "";
				}

			}
		} catch (IOException e) {
			for (CommandInterpreter commandInterpreter : commandInterpreters){
				commandInterpreter.willFinishInterpretingCommands();
			}
		}
		
		commandInterpreters.clear();
	}

}
