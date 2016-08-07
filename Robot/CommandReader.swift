import Foundation

/**
 * Reads from a socket and passes interpreted Commands to one CommandInterpreter
 */
public class CommandReader {
	/*
	
	/**
	 * @param socket
	 *            from which can be read commands through an InputStream.
	 *            "socket" won't be closed automatically by calling self method
	 * @param commandInterpreter
	 *            is a class which interprets commands
	 * @throws IOException
	 *             since opening an InputStream and reading can fail
	 */
	public static func readFromSocket(_ socket: CFSocket, _ commandInterpreter: CommandInterpreter)
			throws {

		// can throw IOException
				
		/*var inputStream = socket;

		var commandString = "";
				var c: UInt8;

		// can throw IOException
		while ((c = inputStream.read()) != -1) {
			commandString += String(Character(UnicodeScalar(c)));
			
			if (Command.stringEndsWithEndDelimiter(commandString)) {
				// can throw IllegalArgumentException
				//System.out.println(commandString);
				commandInterpreter.interpretCommand(try Command(commandString));
				commandString = "";
				
			}
			
		}*/
	}
	
	*/
}
