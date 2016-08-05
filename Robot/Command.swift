
import Foundation

/**
 * A class which can send and read Commands over a OutputStream/InputStream
 * 
 * It contains a clientID, commandString and a Dictionary of parameters
 */
public struct Command {
	
	public static let endDelimiter = "%%%%";
	
	/**
	 * @param string which gets checked
	 * @return if string contains one of the delimiters it returns true otherwise false
	 */
	public static func stringContainsDelimiter(_ string: String) -> Bool {
		return Parser.stringContainsDelimiter(string) || string.contains(endDelimiter);
	}
	
	public static func objectContainsDelimiter(_ object: Object) -> Bool {
		switch object {
		case .string(let string):
			return stringContainsDelimiter(string)
		case .array(let array):
			return array.contains(where: objectContainsDelimiter)
		case .dictionary(let dict):
			return dict.keys.contains(where: stringContainsDelimiter) || dict.values.contains(where: objectContainsDelimiter)
		}
	}
	
	public static func stringEndsWithEndDelimiter(_ string: String) -> Bool {
		return string.hasSuffix(endDelimiter);
	}
	
	private var commandString = "";
	private var parameters = [String : Object]();
	
	// --- constructors
	
	/**
	 * Parses a string from server/client
	 * @param parseString which gets parsed to a Command instance
	 */
	public static func fromString(_ parseString: String) throws -> Command {
		
		// check empty String
		if (parseString.equals("")) {
			throw IllegalArgumentException("commandstring is empty");
		}
		
		if (!Command.stringEndsWithEndDelimiter(parseString)) {
			throw IllegalArgumentException("commandstring does not end with end delimiter");
		}
		
		// !!! can throw
		let parser = try Parser(parseString.substring(0, parseString.length() - endDelimiter.length()));
		
		let arguments = parser.toArrayOfObjects()!
		if (arguments.count != 2) {
			throw IllegalArgumentException("too many or too few arguments: " + parseString);
		}

		
		var command = try Command("");
		
		// set commandString
		guard let commandStringObject = Helper.castToString(arguments.get(0)) else {
			throw IllegalArgumentException("commandString is nil");
		}
		command.commandString = commandStringObject

		// set parameters
		guard let map = Helper.castToDictionaryOfObjects(arguments.get(1)) else {
			throw IllegalArgumentException("parametersObject cast failed")
		}
		command.parameters = map

		return command;
	}
	
	public init(
	_ command: String,
	_ parameters: [String : Object]) throws {
		
		if (command == "") {
			throw IllegalArgumentException("command string is empty");
		}
		
		// Exception handling
		if (Command.stringContainsDelimiter(command)) {
			throw  IllegalArgumentException("delimiter in command: " + command); }
		for key in parameters.keys {
			if (Command.stringContainsDelimiter(key)) {
				throw IllegalArgumentException("delimiter in one of the keys in parameters Dictionary. Key: " + key); }
			if (Command.objectContainsDelimiter(parameters.get(key))) {
				throw IllegalArgumentException("delimiter in one of the values in parameters Dictionary. Value: : \(parameters.get(key))");
			}
		}
		
		self.commandString = command;
		self.parameters = parameters;
	}
	public init(
		_ command: String,
		_ parameters: [String : String]) throws {
		
		if (command == "") {
			throw IllegalArgumentException("command string is empty");
		}
		
		// Exception handling
		if (Command.stringContainsDelimiter(command)) {
			throw IllegalArgumentException("delimiter in command: " + command)
		}
		
		self.commandString = command;
		self.parameters = [:]
		for (key, value) in parameters {
			self.addParameter(key, value)
		}
	}
	
	public init(_ command: String) throws {
		try self.init(command, [String : Object]());
	}
	
	// --- setters
	
	public mutating func addParameter(_ key: String, _ value: String) {
		parameters.put(key, .string(value));
	}
	public mutating func addParameter(_ key: String, _ value: Object) {
		parameters.put(key, value);
	}
	
	// --- getters
	
	public func getCommandString() -> String {
		return commandString;
	}
	
	/**
	 * @param key
	 * @return parameter value for key which can be _NULL_
	 */
	public func getParameterValueForKey(_ key: String) -> Object {
		return parameters.get(key)!
	}
	
	/**
	 * 
	 * @return the Dictionary with all parameters
	 */
	func getParameters() -> Dictionary<String, Object> {
		return parameters;
	}
	
	// --- convertToString
	
	public func convertToString() -> String {
		var list = Array<Object>();
		list.add(.string(commandString));
		list.add(.dictionary(parameters));
		let result = Parser(list).convertToString() + Command.endDelimiter;
		return result;
	}
	
	/**
	 * @param outputStream through which the command will be send
	 * @throws IOException if "self.convertToString()" could not be written to outputStream
	 */
	public func sendWithOutputStream(_ outputStream: OutputStream) throws {
		// !!! can throw NullPointerException
		try Helper.errorIfNull("output Stream is nil", outputStream);
		// !!! can throw IOException
		try CommandSender.sendCommandWithOutputStream(self, outputStream);
	}
}
