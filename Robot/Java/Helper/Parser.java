package Robot.Java.Helper;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * A class which can convert a
 * Element = (String | HashMap of String, Element | ArrayList of Element)
 * to a String and back to a Element (saved as Object)
 */
public class Parser {

	// delimiters
	final static String listStart = "[;";
	final static String listEnd = ";]";
	
	final static String dictStart = "{;";
	final static String dictEnd = ";}";
	final static String dictKeyValueDelimiter = ";:";
	
	final static String listValueDelimiter = ";,";
	
	/** Is ArrayList<Object> or HashMap<String, Object>*/
	public Object object;
	
	public Parser(String parseString) throws IllegalArgumentException {
		if (parseString == null) {
			throw new IllegalArgumentException("parseString is null");
		}
		object = parse(parseString, 0, new Wrapper<Integer>(null));
	}
	/**
	 * Takes a list which can be converted to String s;
	 * s can be parsed back to this list (as Object; parser.object).
	 * 
	 * @note
	 * T should a recursive construct of ArrayList<T> and HashMap<String, T> or String; If not convertToString will return null;
	 * every empty String ("") which is in a ArrayList (also recursive in T) gets ignored in convertToString
	 * 
	 * @param list
	 */
	public <T> Parser(ArrayList<T> list) {
		object = list;
	}
	/**
	 * Takes a hashMap which can be converted to String s;
	 * s can be parsed back to this hashMap (as Object; parser.object).
	 * 
	 * @note
	 * T should a recursive construct of ArrayList<T> and HashMap<String, T> or String; If not convertToString will return null;
	 * every empty String ("") which is in a ArrayList (also recursive in T) gets ignored in convertToString
	 * 
	 * @param hashMap
	 */
	public <T> Parser(HashMap<String, T> hashMap) {
		object = hashMap;
	}

	/**
	 * Parses string recursively into an Object
	 * 
	 * @param string which gets parsed
	 * @param startIndex where to parse string
	 * @param newStartIndex is a pure out parameter in order to return a second value
	 * 
	 * @return ArrayList of Objects or HashMap with Key: String and Value: Object
	 * 
	 * @throws IllegalArgumentException is passed string cannot be parsed completely
	 */
	private Object parse(String string, int startIndex, Wrapper<Integer> newStartIndex) throws IllegalArgumentException {
		
		int index = indexOfFirstOccurenceOfDelimiter(string, startIndex);

		if (index == -1) {
			throw new IllegalArgumentException("string doesn't have any delimiter from startIndex: " + startIndex + "  string: " + string);
		}
		if (index != startIndex) {

			throw new IllegalArgumentException(
					"string has to start with a start delimiter at startIndex: " + startIndex + "  string: " + string);
		}

		String delimiter = delimiterAtIndex(string, index);

		boolean didRecurse = false;
		
		switch (delimiter) {
		case listStart:
			// parse list

			ArrayList<Object> list = new ArrayList<Object>();
			startIndex += listStart.length();

			didRecurse = false;
			
			boolean isListEnd = false;
			while (!isListEnd) {
				// parse list elements
				
				index = indexOfFirstOccurenceOfDelimiter(string, startIndex);
				if (index == -1) {
					throw new IllegalArgumentException("expected delimiter" + "  string: " + string);
				}
				delimiter = delimiterAtIndex(string, index);
				
				switch (delimiter) {
				case listStart:
				case dictStart:
					// recursion
					Wrapper<Integer> newListStartIndex = new Wrapper<Integer>(null);
					list.add(parse(string, index, newListStartIndex));
					startIndex = newListStartIndex.getValue().intValue();
					
					didRecurse = true;
					break;
				case listEnd:
					isListEnd = true;
					if (!didRecurse) {
						String subString = string.substring(startIndex, index);
						if (!list.isEmpty() || !subString.equals("")) {
							list.add(subString);
						}
					} else {

						didRecurse = false;
					}
					startIndex = index + delimiter.length();
					break;
				case listValueDelimiter:
					if (!didRecurse) {
						String subString = string.substring(startIndex, index);
						list.add(subString);
					} else {
						didRecurse = false;
					}
					startIndex = index + delimiter.length();
					break;
				default:
					throw new IllegalArgumentException("Unexpected delimiter: " + delimiter + "  string: " + string);
				}
			}
			
			// write start index back and return
			newStartIndex.setValue(new Integer(startIndex));
			return list;
		case dictStart:
			// parse HashMap

			HashMap<String, Object> hashMap = new HashMap<String, Object>();
			startIndex += dictStart.length();

			String key = null;
			boolean isKey = true;
			
			didRecurse = false;
			
			boolean isHashMapEnd = false;
			while (!isHashMapEnd) {
				// parse list elements

				index = indexOfFirstOccurenceOfDelimiter(string, startIndex);
				if (index == -1) {
					throw new IllegalArgumentException("expected delimiter" + "  string: " + string);
				}
				delimiter = delimiterAtIndex(string, index);
				
				switch (delimiter) {
				case listStart:
				case dictStart:
					if (isKey) {
						throw new IllegalArgumentException("only Strings can be used as keys for HashMaps" + "  string: " + string);
					} else { // is value
						// recursion
						Wrapper<Integer> newHashMapStartIndex = new Wrapper<Integer>(null);
						hashMap.put(key, parse(string, index, newHashMapStartIndex));
						startIndex = newHashMapStartIndex.getValue().intValue();
						
						didRecurse = true;
					}
					break;
				case dictEnd:
					isHashMapEnd = true;
					if (key == null) {
						// empty Dictionary
						startIndex = index + delimiter.length();
						break;
					} else if (isKey) {
						throw new IllegalArgumentException("expected a value but HashMap ended" + "  string: " + string);
					}
					// fall through
				case listValueDelimiter:
					// listVALUEDelimiter, VALUE is in this context Key and Value of HashMap
					
					if (isKey) {
						
						throw new IllegalArgumentException("should terminate key with dictKeyValueDelimiter but found listValueDelimiter" + "  string: " + string);
					}
					if (!didRecurse) {
						String substring = string.substring(startIndex, index);
						hashMap.put(key, substring);
					} else {
						didRecurse = false;
					}
					
					isKey = true;
					startIndex = index + delimiter.length();
					break;
				case dictKeyValueDelimiter:
					if (!isKey) {

						throw new IllegalArgumentException("cannot terminate value with dictKeyValueDelimiter" + "  string: " + string);
					}
					key = string.substring(startIndex, index);
					
					isKey = false;
					startIndex = index + delimiter.length();
					break;
				default:

					throw new IllegalArgumentException("Unexpected delimiter: " + delimiter + "  string: " + string);
				}
			}
			
			// write start index back and return
			newStartIndex.setValue(new Integer(startIndex));
			return hashMap;
		default:
			throw new IllegalArgumentException("Unexpected delimiter" + "  string: " + string);
		}
	}

	/**
	 * @param string which gets checked
	 * @return true if string contains one of the private delimiters of parser
	 */
	public static boolean stringContainsDelimiter(String string) {
		return Parser.indexOfFirstOccurenceOfDelimiter(string, 0) != -1;
	}
	
	/**
	 * @param string
	 *            where to look for occurrences
	 * @param start
	 *            offset from first character
	 * @return -1 if no index found otherwise the index if the first character if the occurring delimiter
	 */
	private static int indexOfFirstOccurenceOfDelimiter(String string, int start) {

		for (int i = start; i < string.length(); i++) {
			if (
					string.startsWith(listStart, i) ||
					string.startsWith(listEnd, i) ||
					string.startsWith(listValueDelimiter, i) ||
					string.startsWith(dictStart, i) ||
					string.startsWith(dictEnd, i) ||
					string.startsWith(dictKeyValueDelimiter, i)) {

				return i;
			}
		}
		return -1;
	}

	/**
	 * @param string
	 *            where to search 
	 * @param index
	 *            where to search delimiter
	 * @return can be _NULL_ if no delimiter is at this index; otherwise the occurred delimiter
	 */
	private static String delimiterAtIndex(String string, int index) {

		if (string.startsWith(listStart, index)) {
			return listStart;
		}
		if (string.startsWith(listEnd, index)) {
			return listEnd;
		}
		if (string.startsWith(listValueDelimiter, index)) {
			return listValueDelimiter;
		}
		if (string.startsWith(dictStart, index)) {
			return dictStart;
		}
		if (string.startsWith(dictEnd, index)) {
			return dictEnd;
		}
//		if (string.startsWith(dictKeyValueDelimiter, index)) {
			return dictKeyValueDelimiter;
//		}
		//ToTest
//		return null;
	}

	/**
	 * tries to cast the (parsed) object to a HashMapOfStrings
	 * @return can be _NULL_ if object could not be casted
	 */
	public HashMap<String, String> toHashMapOfStrings() {
		return Helper.castToHashMapOfStrings(this.object);
	}
	
	/**
	 * tries to case the (parsed) object to a HashMapOfObjects
	 * @return can be _NULL_ if object could not be casted
	 */
	public HashMap<String, Object> toHashMapOfObjects() {
		return Helper.castToHashMapOfObjects(this.object);
	}
	
	/**
	 * tries to case the (parsed) object to a ArrayListOfObjects
	 * @return can be _NULL_ if object could not be casted
	 */
	public ArrayList<Object> toArrayListOfObjects() {
		return Helper.castToArrayListOfObjects(this.object);
	}
	
	/**
	 * @param object which will be casted to String
	 * @return can be _NULL_ if object could not be casted
	 */
	private String castToString(Object object) {
		if (object instanceof String) {
			return (String) object;
		}
		return null;
	}
	
	/**
	 * @param object which gets converted to string
	 * @return can return _NULL_ if object could not be converted
	 */
	private String toStringRecursive(Object object) {
		String string = castToString(object);
		if (string != null) {
			return string;
		}
		ArrayList<Object> list = Helper.castToArrayListOfObjects(object);
		if (list != null) {
			// map list with toStringRecursive and join with "listMapDelimiter"
			String result = listStart;
			if (list.isEmpty()) {
				return result + listEnd;
			}
			result += toStringRecursive(list.get(0));
			for (int i = 1; i < list.size(); i++) {
				// recursion
				result += listValueDelimiter + toStringRecursive(list.get(i));
			}
			return result + listEnd;
		}
		HashMap<String, Object> hashMap = Helper.castToHashMapOfObjects(object);
		if (hashMap != null) {
			// map list with toStringRecursive and join with "listMapDelimiter"
			String result = dictStart;
			if (hashMap.isEmpty()) {
				return result + dictEnd;
			}
			
			ArrayList<String> keyValuePairs = new ArrayList<String>();
			for (String key : hashMap.keySet()) {
				// recursion
				keyValuePairs.add(key + dictKeyValueDelimiter + toStringRecursive(hashMap.get(key)));
			}
			
			result += keyValuePairs.get(0);
			for (int i = 1; i < keyValuePairs.size(); i++) {
				result += listValueDelimiter + keyValuePairs.get(i);
			}
			return result + dictEnd;
		}
		
		return null;
	}
	
	/**
	 * @return string which can be parsed back to original object of Parser
	 * if object could not be converted it returns _NULL_
	 */
	public String convertToString() {
		return toStringRecursive(object);
	}
}
