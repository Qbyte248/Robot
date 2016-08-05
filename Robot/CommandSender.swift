
import Foundation
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
	static func sendCommandWithOutputStream(_ command: Command, _ outputStream: OutputStream) throws {
		// FIXME: this could not work!!!!
		let string = command.convertToString()
		outputStream.write(string, maxLength: string.utf8.count)
		//outputStream.write(command.convertToString().getBytes("ISO-8859-1"));
	}
	
}
