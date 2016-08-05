package Robot.Java.Helper;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * Helper class for various tasks like casting and null checking 
 */
public class Helper {

	/**
	 * returns new HashMap which Keys and Values are swapped
	 * 
	 * @param hashMap which will be inverted
	 * @return hashMap with swapped Key and Value
	 */
	public static <T, U> HashMap<U, T> invertHashMap(HashMap<T, U> hashMap) {
		HashMap<U, T> returnMap = new HashMap<U, T>();
		for (T key : hashMap.keySet()) {
			returnMap.put(hashMap.get(key), key);
		}
		return returnMap;
	}
	
	/**
	 * throws NullPointerException with message if at least one object is null
	 * Should be used if you are sure it is a fatal error
	 * 
	 * @param message which will be attached to NullPointerException
	 * @param objects which are checked for null
	 * @throws NullPointerException if one of the objects is null
	 */
	public static void errorIfNull(String message, Object... objects) throws NullPointerException {
		int i = areAllNotNull(objects);
		if (i != -1) {
			throw new NullPointerException(message + "  index: " + i);
		}
	}
	
	/**
	 * throws IllegalArgumentException with message if at least one object is null
	 * Should be used if you are sure it is a fatal error
	 * 
	 * @param message which will be attached to IllegalArgumentException
	 * @param objects which are checked for null
	 * @throws IllegalArgumentException if one of the objects is null
	 */
	public static void throwIllegalErgumentExceptionIfNull(String message, Object... objects) throws IllegalArgumentException {
		int i = areAllNotNull(objects);
		if (i != -1) {
			throw new IllegalArgumentException(message + "  index: " + i);
		}
	}
	
	/**
	 * checks objects for null
	 * @param objects which will be checked
	 * @return true if none of the objects is null
	 */
	public static int areAllNotNull(Object...objects) {
		int i = 0;
		for (Object o : objects) {
			if (o == null) {
				return i;
			}
			i++;
		}
		return -1;
	}
	
	/**
	 * prints message if at least one object is null
	 * 
	 * @param message will be be printed with System.out.println(message) if one of the objects is null
	 * @param objects which will be checked for null
	 */
	public static void messageIfNull(String message, Object... objects) {
		if (areAllNotNull(objects) != -1) {
			System.out.println(message);
		}
	}
	
	// --- casting
	
	/**
	 * casts object to String
	 * 
	 * @param object which will be cast to String
	 * @return casted Object as String; can be _NULL_ if object cannot be cast.
	 */
	public static String castToString(Object object) {
		if (object instanceof String) {
			return (String) object;
		}
		return null;
	}
	
	/**
	 * casts object to String with additional message
	 * 
	 * @param object which gets casted
	 * @param message which is put into the "NullPointerException"
	 * @return casted String; can bee _NULL_ if object cannot be cast.
	 * @throw NullPointerException if object could not be cast to String
	 */
	public static String castToString(Object object, String message) throws NullPointerException {
		String string = Helper.castToString(object);
		if (string == null) { throw new NullPointerException(message); }
		return string;
	}
	
	/**
	 * casts "object" to a HashMap with String as Keys and Values
	 * @return can be _NULL_ if object could not be cast to HashMap
	 */
	public static HashMap<String, String> castToHashMapOfStrings(Object object) {
		if (!(object instanceof HashMap<?, ?>)) {
			return null;
		}

		HashMap<String, String> resultMap = null;
		try {
			resultMap = (HashMap<String, String>) object;
		} catch (ClassCastException e) {}

		return resultMap;
	}
	
	/**
	 * casts "object" to HashMap with Keys as Strings and Object as Values 
	 * 
	 * @return can be _NULL_ if object could not be cast to HashMap
	 */
	public static HashMap<String, Object> castToHashMapOfObjects(Object object) {
		if (!(object instanceof HashMap<?, ?>)) {
			return null;
		}

		HashMap<String, Object> resultMap = null;
		try {
			resultMap = (HashMap<String, Object>) object;
		} catch (ClassCastException e) {}

		return resultMap;
	}
	
	/**
	 * cast "object" to ArrayList of Objects
	 * @return can be _NULL_ if object could not be cast to ArrayList
	 */
	public static ArrayList<Object> castToArrayListOfObjects(Object object) {
		if (!(object instanceof ArrayList<?>)) {
			return null;
		}

		ArrayList<Object> resultList = null;
		try {
			resultList = (ArrayList<Object>) object;
		} catch (ClassCastException e) {}

		return resultList;
	}
	
	/**
	 * casts "object" to ArrayList of Strings
	 * @return can be _NULL_ if object could not be cast to ArrayList
	 */
	public static ArrayList<String> castToArrayListOfStrings(Object object) {
		if (!(object instanceof ArrayList<?>)) {
			return null;
		}

		ArrayList<String> resultList = null;
		try {
			resultList = (ArrayList<String>) object;
		} catch (ClassCastException e) {}

		return resultList;
	}
	
	/**
	 * casts "object" to ArrayList of HashMaps of Strings
	 * @return can be _NULL_ if object could not be cast to ArrayList
	 */
	public static ArrayList<HashMap<String, String>> castToArrayListOfHashMapsOfStrings(Object object) {
		ArrayList<Object> list = Helper.castToArrayListOfObjects(object);
		if (list == null) {
			return null;
		}
		
		ArrayList<HashMap<String, String>> resultList = new ArrayList<HashMap<String, String>>();
		for (Object o : list) {
			HashMap<String, String> hashMap = Helper.castToHashMapOfStrings(o);
			if (hashMap == null) {
				return null;
			}
			resultList.add(hashMap);
		}
		
		return resultList;
	}
	
	
	 // convert from UTF-8 -> internal Java String format
	/**
	 * Converts a UTF-8 String to the internal Java String format
	 * @param string to be converted in UTF-8
	 * @return converted String 
	 */
    public static String convertFromUTF8(String string) {
        try {
        	// !!! can throw
            return new String(string.getBytes("ISO-8859-1"), "ISO-8859-1");
        } catch (java.io.UnsupportedEncodingException e) {
            return null;
        }
    }
 
    // convert from internal Java String format -> UTF-8
    
    /**
     * Converts a internal String in UTF-8 format. For text is received from GUI and meant to be sent.
     * @param string to be converted
     * @return converted String in UTF-8
     */
    public static String convertToUTF8(String string) {
        System.out.println("i'm in");
        try {
            return new String(string.getBytes("UTF-16"), "UTF-16");
        } catch (java.io.UnsupportedEncodingException e) {
            return null;
        }
    }
}
