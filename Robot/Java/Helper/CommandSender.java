package Robot.Java.Helper;

import java.io.IOException;
import java.io.OutputStream;

/**
 * Sends Commands over an OutputStream
 */
class CommandSender {

	/**
	 * sends passed command with the passed output stream 
	 * @param command which gets send
	 * @param outputStream on which the command gets send
	 * @throws IOException if it could not write to output stream
	 */
	static void sendCommandWithOutputStream(Command command, OutputStream outputStream) throws IOException {
		outputStream.write(command.convertToString().getBytes("ISO-8859-1"));
	}
	
}
