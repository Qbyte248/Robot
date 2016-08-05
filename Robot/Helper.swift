

/**
 * Helper class for various tasks like casting and nil checking 
 */
public class Helper {

	/**
	 * returns  Dictionary which Keys and Values are swapped
	 * 
	 * @param hashMap which will be inverted
	 * @return hashMap with swapped Key and Value
	 */
	/*static func invertDictionary<T: Hashable, U: Hashable>(_ hashMap: Dictionary<T, U>) -> [U : T] {
		var returnMap = Dictionary<U, T>();
		for key in hashMap.keys {
			returnMap[hashMap[key]!] = key;
		}
		return returnMap;
	}*/
	
	/**
	 * throws NullPointerException with message if at least one object is nil
	 * Should be used if you are sure it is a fatal error
	 * 
	 * @param message which will be attached to NullPointerException
	 * @param objects which are checked for nil
	 * @throws NullPointerException if one of the objects is nil
	 */
	public static func errorIfNull(_ message: String , _ objects: Any?...) throws {
		if (!areAllNotNull(objects)) {
			throw NullPointerException(message);
		}
	}
	
	/**
	 * throws IllegalArgumentException with message if at least one object is nil
	 * Should be used if you are sure it is a fatal error
	 * 
	 * @param message which will be attached to IllegalArgumentException
	 * @param objects which are checked for nil
	 * @throws IllegalArgumentException if one of the objects is nil
	 */
	public static func throwIllegalArgumentExceptionIfNull(_ message: String, _ objects: Any?...) throws {
		if (!areAllNotNull(objects)) {
			throw  IllegalArgumentException(message);
		}
	}
	
	/**
	 * checks objects for nil
	 * @param objects which will be checked
	 * @return true if none of the objects is nil
	 */
	public static func areAllNotNull(_ objects: [Any?]) -> Bool {
		for o in objects {
			if (o == nil) {
				return false;
			}
		}
		return true;
	}
	
	/**
	 * prints message if at least one object is nil
	 * 
	 * @param message will be be printed with System.out.println(message) if one of the objects is nil
	 * @param objects which will be checked for nil
	 */
	public static func messageIfNull(_ message: String, _ objects: Any?...) {
		if (!areAllNotNull(objects)) {
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
	public static func castToString(_ object: Object) -> String? {
		guard case .string(let string) = object else {
			return nil
		}
		return string
	}
	
	/**
	 * casts object to String with additional message
	 * 
	 * @param object which gets casted
	 * @param message which is put into the "NullPointerException"
	 * @return casted String; can bee _NULL_ if object cannot be cast.
	 * @throw NullPointerException if object could not be cast to String
	 */
	public static func castToString(_ object: Object, _ message: String) throws -> String {
		guard let string = Helper.castToString(object) else {
			throw NullPointerException(message)
		}
		return string
	}
	
	/**
	 * casts "object" to a Dictionary with String as Keys and Values
	 * @return can be _NULL_ if object could not be cast to Dictionary
	 */
	public static func castToDictionaryOfStrings(_ object: Object) -> Dictionary<String, String>! {
		guard case .dictionary(let dict) = object else {
			return nil
		}
		var result = [String : String]()
		for (key , value) in dict {
			guard case .string(let string) = value else {
				return nil
			}
			result[key] = string
		}
		return result
	}
	
	/**
	 * casts "object" to Dictionary with Keys as Strings and Object as Values 
	 * 
	 * @return can be _NULL_ if object could not be cast to Dictionary
	 */
	public static func castToDictionaryOfObjects(_ object: Object) -> Dictionary<String, Object>? {
		guard case .dictionary(let dict) = object else {
			return nil
		}
		return dict
	}
	
	/**
	 * cast "object" to Array of Objects
	 * @return can be _NULL_ if object could not be cast to Array
	 */
	public static func castToArrayOfObjects(_ object: Object) -> Array<Object>? {
		guard case .array(let array) = object else {
			return nil
		}
		return array
	}
	
	/**
	 * casts "object" to Array of Strings
	 * @return can be _NULL_ if object could not be cast to Array
	 */
	public static func castToArrayOfStrings(_ object: Object) -> Array<String>? {
		guard let array = castToArrayOfObjects(object) else {
			return nil
		}
		var result = [String]()
		result.reserveCapacity(array.count)
		for object in array {
			guard let string = castToString(object) else {
				return nil
			}
			result.append(string)
		}
		return result
	}
	
	/**
	 * casts "object" to Array of Dictionarys of Strings
	 * @return can be _NULL_ if object could not be cast to Array
	 */
	public static func castToArrayOfDictionarysOfStrings(_ object: Object) -> Array<Dictionary<String, String>>? {
		guard let list = Helper.castToArrayOfObjects(object) else {
			return nil
		}
		
		var resultList = Array<Dictionary<String, String>>();
		for object in list {
			guard let hashMap = Helper.castToDictionaryOfStrings(object) else {
				return nil
			}
			resultList.append(hashMap)
		}
		
		return resultList;
	}
	
	
	 // convert from UTF-8 -> internal Java String format
	/**
	 * Converts a UTF-8 String to the internal Java String format
	 * @param string to be converted in UTF-8
	 * @return converted String 
	 */
	public static func convertFromUTF8(_ string: String) -> String! {
        /*try {
        	// !!! can throw
            return  String(string.getBytes("ISO-8859-1"), "ISO-8859-1");
        } catch (java.io.UnsupportedEncodingException e) {
            return nil;
        }*/
		return nil
    }
 
    // convert from internal Java String format -> UTF-8
    
    /**
     * Converts a internal String in UTF-8 format. For text is received from GUI and meant to be sent.
     * @param string to be converted
     * @return converted String in UTF-8
     */
	public static func convertToUTF8(_ string: String) -> String! {
        /*System.out.println("i'm in");
        try {
            return  String(string.getBytes("UTF-16"), "UTF-16");
        } catch (java.io.UnsupportedEncodingException e) {
            return nil;
        }*/
		return nil
    }
}
