package Robot.Java.Helper;

import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * A class which can send and read Commands over a OutputStream/InputStream
 * 
 * It contains a clientID, commandString and a HashMap of parameters
 */
public class Command {
	
	public static final String endDelimiter = "%%%%";
	
	/**
	 * @param string which gets checked
	 * @return if string contains one of the delimiters it returns true otherwise false
	 */
	public static boolean stringContainsDelimiter(String string) {
		return Parser.stringContainsDelimiter(string) || string.contains(endDelimiter);
	}
	
	public static boolean stringEndsWithEndDelimiter(String string) {
		return string.endsWith(endDelimiter);
	}
	
	private String commandString = "";
	private HashMap<String, String> parameters;
	
	// --- constructors
	
	/**
	 * Parses a string from server/client
	 * @param parseString which gets parsed to a Command instance
	 */
	public static Command fromString(String parseString) throws IllegalArgumentException {
		// null check
		if (parseString == null) {
			throw new NullPointerException("commandString is null");
		}
		
		// check empty String
		if (parseString.equals("")) {
			throw new IllegalArgumentException("commandstring is empty");
		}
		
		if (!Command.stringEndsWithEndDelimiter(parseString)) {
			throw new IllegalArgumentException("commandstring does not end with end delimiter");
		}
		
		// !!! can throw
		Parser parser = new Parser(parseString.substring(0, parseString.length() - endDelimiter.length()));
		
		ArrayList<Object> arguments = parser.toArrayListOfObjects();
		if (arguments.size() != 2) {
			throw new IllegalArgumentException("too many or too few arguments: " + parseString);
		}
		
		Command command = new Command(" ");
		
		// set commandString
		Object commandStringObject = arguments.get(0);
		command.commandString = Helper.castToString(commandStringObject);
		// !!! can throw
		Helper.throwIllegalErgumentExceptionIfNull("commandString is null", command.commandString);

		// set parameters
		Object parametersObject = arguments.get(1);
		HashMap<String, Object> map = Helper.castToHashMapOfObjects(parametersObject);
		// !!! can throw
		Helper.throwIllegalErgumentExceptionIfNull("parametersObject cast failed", map);
		
		command.parameters = new HashMap<>();
		for (String key : map.keySet()) {
			ArrayList<Object> list = Helper.castToArrayListOfObjects(map.get(key));
			HashMap<String, Object> hashMap = Helper.castToHashMapOfObjects(map.get(key));
			String string = Helper.castToString(map.get(key));
			if (list != null) {
				command.parameters.put(key, new Parser(list).convertToString());
			} else if (hashMap != null) {
				command.parameters.put(key, new Parser(hashMap).convertToString());
			} else if (string != null) {
				command.parameters.put(key, string);
			} else {
				throw new IllegalArgumentException("could not cast object in hash map to ArrayLit, HashMap or String; Object: " + map.get(key));
			}
		}
		
		return command;
	}
	
	public Command(
			String command,
			HashMap<String, String> parameters) throws IllegalArgumentException {
		
		Helper.errorIfNull("One ore more arguments are null", command, parameters);
		
		if (command.equals("")) {
			throw new IllegalArgumentException("commandstring is empty");
		}
		
		// Exception handling
		if (Command.stringContainsDelimiter(command)) {
			throw new IllegalArgumentException("delimiter in command: " + command); }
		for (String key : parameters.keySet()) {
			if (Command.stringContainsDelimiter(key)) {
				throw new IllegalArgumentException("delimiter in one of the keys in parameters HashMap. Key: " + key); }
			if (Command.stringContainsDelimiter(parameters.get(key))) {
				throw new IllegalArgumentException("delimiter in one of the values in parameters HashMap. Value: : " + parameters.get(key)); }
		}
		
		this.commandString = command;
		this.parameters = parameters;
	}
	public Command(String command) throws IllegalArgumentException {
		this(command, new HashMap<String, String>());
	}
	
	// --- setters
	
	public void addParameter(String key, String value) throws IllegalArgumentException {
		// @FIXME check for delimiters in string (currently value can be ObjectConvertible.convertToString())
		// probably a method like Parser.canBeParsed(Object o)
		// or directly use HashMap of Objects instead of Strings
		
		/*if (Command.stringContainsDelimiter(key)) {
			throw new IllegalArgumentException("delimiter in key: " + key); }
		if (Command.stringContainsDelimiter(value)) {
			throw new IllegalArgumentException("delimiter in value: " + value); }*/
		parameters.put(key, value);
	}
	
	// --- getters
	
	public String getCommandString() {
		return commandString;
	}
	
	/**
	 * @param key
	 * @return parameter value for key which can be _NULL_
	 */
	public String getParameterValueForKey(String key) {
		return parameters.get(key);
	}
	
	/**
	 * 
	 * @return the HashMap with all parameters
	 */
	public HashMap<String, String> getParameters(){
		return parameters;
	}
	
	// --- convertToString
	
	public String convertToString() {
		ArrayList<Object> list = new ArrayList<>();
		list.add(commandString);
		list.add(parameters);
		String result = new Parser(list).convertToString() + endDelimiter;
		return result;
	}
	
	/**
	 * @param outputStream through which the command will be send
	 * @throws IOException if "this.convertToString()" could not be written to outputStream
	 */
	public void sendWithOutputStream(OutputStream outputStream) throws IOException {
		// !!! can throw NullPointerException
		Helper.errorIfNull("output Stream is null", outputStream);
		// !!! can throw IOException
		CommandSender.sendCommandWithOutputStream(this, outputStream);
	}
}
