package Robot.Java.Helper;

import java.io.IOException;
import java.io.InputStream;
import java.net.Socket;

/**
 * Reads from a socket and passes interpreted Commands to one CommandInterpreter
 */
public class CommandReader {

	/**
	 * @param socket
	 *            from which can be read commands through an InputStream.
	 *            "socket" won't be closed automatically by calling this method
	 * @param commandInterpreter
	 *            is a class which interprets commands
	 * @throws IOException
	 *             since opening an InputStream and reading can fail
	 */
	public static void readFromSocket(Socket socket, CommandInterpreter commandInterpreter)
			throws IOException, IllegalArgumentException {

		// can throw IOException
		InputStream inputStream = socket.getInputStream();

		String commandString = "";
		int c;

		// can throw IOException
		while ((c = inputStream.read()) != -1) {
			commandString += (char) c;
			
			if (Command.stringEndsWithEndDelimiter(commandString)) {
				// can throw IllegalArgumentException
				commandInterpreter.interpretCommand(new Command(commandString));
				commandString = "";
				
			}
			
		}
	}
}
