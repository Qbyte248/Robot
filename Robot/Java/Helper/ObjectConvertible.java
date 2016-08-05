package Robot.Java.Helper;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * An Interface which defines the conversion from and to objects which can be parsed by "Parser"
 */
public interface ObjectConvertible {
	/**
	 * Initializes current properties with "object"
	 * @param object which was parsed by Parser
	 */
	public void convertFromObject(Object object) throws IllegalArgumentException;
	/**
	 * @return object which can be parsed by "Parser"
	 */
	public Object convertToObject();
	
	/**
	 * @return String which was created by Parser from convertToObject() ; can be _NULL_ if object could not be parsed by Parser
	 */
	default public String convertToString() {
		Object object = convertToObject();
		ArrayList<Object> list = Helper.castToArrayListOfObjects(object);
		if (list != null) {
			try {
				return new Parser(list).convertToString();
			} catch(IllegalArgumentException e) {
				return null;
			}
		}
		
		HashMap<String, Object> map = Helper.castToHashMapOfObjects(object);
		if (map != null) {
			try {
				return new Parser(map).convertToString();
			} catch(IllegalArgumentException e) {
				return null;
			}
		}
		
		return null;
		
	}
	
	/**
	 * parses (with Parser) string to object and calls convertFromObject(object)
	 * 
	 * @param string which gets converted
	 * @throws IllegalArgumentException if parser could not parse string
	 */
	default public void convertFromString(String string) throws IllegalArgumentException {
		// !!! can throw
		Parser parser = new Parser(string);
		
		convertFromObject(parser.object);
	}
}
