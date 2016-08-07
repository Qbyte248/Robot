
/**
 * A class which can convert a
 * Element = (String | Dictionary of String, Element | Array of Element)
 * to a String and back to a Element (saved as Object)
 */
 class Parser {
	
	// delimiters
	static let listStart = "[;";
	static let listEnd = ";]";
	
	static let dictStart = "{;";
	static let dictEnd = ";}";
	static let dictKeyValueDelimiter = ";:";
	
	static let listValueDelimiter = ";,";
	
	/** Is Array<Object> or Dictionary<String, Object>*/
	var object: Object;
	
	 init(_ parseString: String) throws {
		object = .string("") // any value
		object = try parse(parseString, 0,  Wrapper<Int>(0));
	}
	/**
	 * Takes a list which can be converted to String s;
	 * s can be parsed back to self list (as Object; parser.object).
	 * 
	 * @note
	 * T should a recursive construct of Array<T> and Dictionary<String, T> or String; If not convertToString will return nil;
	 * every empty String ("") which is in a Array (also recursive in T) gets ignored in convertToString
	 * 
	 * @param list
	 */
	init(_ list: Array<Object>) {
		object = .array(list);
	}
	/**
	 * Takes a hashMap which can be converted to String s;
	 * s can be parsed back to self hashMap (as Object; parser.object).
	 * 
	 * @note
	 * T should a recursive construct of Array<T> and Dictionary<String, T> or String; If not convertToString will return nil;
	 * every empty String ("") which is in a Array (also recursive in T) gets ignored in convertToString
	 * 
	 * @param hashMap
	 */
	 init(_ hashMap: Dictionary<String, Object>) {
		object = .dictionary(hashMap)
	}

	/**
	 * Parses string recursively into an Object
	 * 
	 * @param string which gets parsed
	 * @param startIndex where to parse string
	 * @param newStartIndex is a pure out parameter in order to return a second value
	 * 
	 * @return Array of Objects or Dictionary with Key: String and Value: Object
	 * 
	 * @throws IllegalArgumentException is passed string cannot be parsed completely
	 */
	private func parse(_ string: String , _ startIndex: Int, _ newStartIndex: Wrapper<Int>) throws -> Object {
		var startIndex = startIndex
		var index = Parser.indexOfFirstOccurenceOfDelimiter(string, startIndex);

		if (index == -1) {
			throw IllegalArgumentException("string doesn't have any delimiter from startIndex: \(startIndex)  string: " + string);
		}
		if (index != startIndex) {

			throw  IllegalArgumentException(
					"string has to start with a start delimiter at startIndex: \(startIndex)  string: " + string);
		}

		var delimiter = Parser.delimiterAtIndex(string, index);

		var didRecurse = false;
		
		switch (delimiter) {
		case Parser.listStart:
			// parse list

			var list = Array<Object>();
			startIndex += Parser.listStart.length();

			didRecurse = false;
			
			var isListEnd = false;
			while (!isListEnd) {
				// parse list elements
				
				index = Parser.indexOfFirstOccurenceOfDelimiter(string, startIndex);
				if (index == -1) {
					throw  IllegalArgumentException("expected delimiter" + "  string: " + string);
				}
				delimiter = Parser.delimiterAtIndex(string, index);
				
				switch (delimiter) {
				case Parser.listStart, Parser.dictStart:
					// recursion
					let newListStartIndex = Wrapper<Int>(0);
					list.add(try parse(string, index, newListStartIndex));
					startIndex = newListStartIndex.getValue();
					
					didRecurse = true;
					break;
				case Parser.listEnd:
					isListEnd = true;
					if (!didRecurse) {
						let subString = string.substring(startIndex, index);
						if (!list.isEmpty || !subString.equals("")) {
							list.add(.string(subString));
						}
					} else {

						didRecurse = false;
					}
					startIndex = index + delimiter.length();
					break;
				case Parser.listValueDelimiter:
					if (!didRecurse) {
						let subString = string.substring(startIndex, index);
						list.add(.string(subString));
					} else {
						didRecurse = false;
					}
					startIndex = index + delimiter.length();
					break;
				default:
					throw  IllegalArgumentException("Unexpected delimiter: " + delimiter + "  string: " + string);
				}
			}
			
			// write start index back and return
			newStartIndex.setValue(startIndex);
			return .array(list);
		case Parser.dictStart:
			// parse Dictionary

			var hashMap =  Dictionary<String, Object>();
			startIndex += Parser.dictStart.length();

			var key: String? = nil;
			var isKey = true;
			
			didRecurse = false;
			
			var isDictionaryEnd = false;
			while (!isDictionaryEnd) {
				// parse list elements

				index = Parser.indexOfFirstOccurenceOfDelimiter(string, startIndex);
				if (index == -1) {
					throw  IllegalArgumentException("expected delimiter" + "  string: " + string);
				}
				delimiter = Parser.delimiterAtIndex(string, index);
				
				switch (delimiter) {
				case Parser.listStart, Parser.dictStart:
					if (isKey) {
						throw  IllegalArgumentException("only Strings can be used as keys for Dictionarys" + "  string: " + string);
					} else { // is value
						// recursion
						let newDictionaryStartIndex = Wrapper<Int>(0);
						// FIXME: probably key can be nil
						hashMap.put(key!, try parse(string, index, newDictionaryStartIndex));
						startIndex = newDictionaryStartIndex.getValue();
						
						didRecurse = true;
					}
					break;
				case Parser.dictEnd:
					isDictionaryEnd = true;
					if (key == nil) {
						// empty Dictionary
						startIndex = index + delimiter.length();
						break;
					} else if (isKey) {
						throw  IllegalArgumentException("expected a value but Dictionary ended" + "  string: " + string);
					}
					// fall through
				case Parser.listValueDelimiter:
					// listVALUEDelimiter, VALUE is in self context Key and Value of Dictionary
					
					if (isKey) {
						
						throw  IllegalArgumentException("should terminate key with dictKeyValueDelimiter but found listValueDelimiter" + "  string: " + string);
					}
					if (!didRecurse) {
						let substring = string.substring(startIndex, index);
						// FIXME: Probably key can be nil
						hashMap.put(key!, .string(substring));
					} else {
						didRecurse = false;
					}
					
					isKey = true;
					startIndex = index + delimiter.length();
					break;
				case Parser.dictKeyValueDelimiter:
					if (!isKey) {

						throw  IllegalArgumentException("cannot terminate value with dictKeyValueDelimiter" + "  string: " + string);
					}
					key = string.substring(startIndex, index);
					
					isKey = false;
					startIndex = index + delimiter.length();
					break;
				default:
					throw IllegalArgumentException("Unexpected delimiter: " + delimiter + "  string: " + string);
				}
			}
			
			// write start index back and return
			newStartIndex.setValue(startIndex);
			return .dictionary(hashMap);
		default:
			throw  IllegalArgumentException("Unexpected delimiter" + "  string: " + string);
		}
	}

	/**
	 * @param string which gets checked
	 * @return true if string contains one of the private delimiters of parser
	 */
	static func stringContainsDelimiter(_ string: String) -> Bool {
		return Parser.indexOfFirstOccurenceOfDelimiter(string, 0) != -1;
	}
	
	/**
	 * @param string
	 *            where to look for occurrences
	 * @param start
	 *            offset from first character
	 * @return -1 if no index found otherwise the index if the first character if the occurring delimiter
	 */
	private static func indexOfFirstOccurenceOfDelimiter(_ string: String, _ start: Int) -> Int {
		var index = start
		var stringIndex = string.index(string.startIndex, offsetBy: start)
		while stringIndex < string.endIndex {
			let substring = string.substring(from: stringIndex)
			if (
					substring.hasPrefix(listStart) ||
					substring.hasPrefix(listEnd) ||
					substring.hasPrefix(listValueDelimiter) ||
					substring.hasPrefix(dictStart) ||
					substring.hasPrefix(dictEnd) ||
					substring.hasPrefix(dictKeyValueDelimiter)) {

				return index;
			}
			string.characters.formIndex(after: &stringIndex)
			index += 1
		}
		return -1;
	}

	/**
	 * @param string
	 *            where to search 
	 * @param index
	 *            where to search delimiter
	 * @return can be _NULL_ if no delimiter is at self index; otherwise the occurred delimiter
	 */
	private static func delimiterAtIndex(_ string: String, _ index: Int) -> String {

		let substring = string.substring(from: string.index(string.startIndex, offsetBy: index))
		
		if substring.hasPrefix(listStart) {
			return listStart;
		}
		if substring.hasPrefix(listEnd) {
			return listEnd;
		}
		if substring.hasPrefix(listValueDelimiter) {
			return listValueDelimiter;
		}
		if substring.hasPrefix(dictStart) {
			return dictStart;
		}
		if substring.hasPrefix(dictEnd)  {
			return dictEnd;
		}
//		if (string.startsWith(dictKeyValueDelimiter, index)) {
			return dictKeyValueDelimiter;
//		}
		//ToTest
//		return nil;
	}

	/**
	 * tries to cast the (parsed) object to a DictionaryOfStrings
	 * @return can be _NULL_ if object could not be casted
	 */
	func toDictionaryOfStrings() -> Dictionary<String, String>? {
		return Helper.castToDictionaryOfStrings(self.object)
	}
	
	/**
	 * tries to case the (parsed) object to a DictionaryOfObjects
	 * @return can be _NULL_ if object could not be casted
	 */
	func toDictionaryOfObjects() -> Dictionary<String, Object>? {
		return Helper.castToDictionaryOfObjects(self.object);
	}
	
	/**
	 * tries to case the (parsed) object to a ArrayOfObjects
	 * @return can be _NULL_ if object could not be casted
	 */
	func  toArrayOfObjects() -> Array<Object>? {
		return Helper.castToArrayOfObjects(self.object);
	}
	
	/**
	 * @param object which will be casted to String
	 * @return can be _NULL_ if object could not be casted
	 */
	private func castToString(_ object: Object) -> String? {
		return Helper.castToString(object)
	}
	
	/**
	 * @param object which gets converted to string
	 * @return can return _NULL_ if object could not be converted
	 */
	private func toStringRecursive(_ object: Object) -> String {
		if case .string(let string) = object {
			return string;
		}
		if case .array(let list) = object {
			// map list with toStringRecursive and join with "listMapDelimiter"
			if (list.isEmpty) {
				return Parser.listStart + Parser.listEnd;
			}
			var result = Parser.listStart;
			result += toStringRecursive(list[0]);
			for i in 1..<list.count {
				// recursion
				result += Parser.listValueDelimiter + toStringRecursive(list[i]);
			}
			return result + Parser.listEnd;
		}
		if case .dictionary(let hashMap) = object {
			// map list with toStringRecursive and join with "listMapDelimiter"
			if (hashMap.isEmpty) {
				return Parser.dictStart + Parser.dictEnd;
			}
			var result = Parser.dictStart
			var keyValuePairs = [String]()
			for key in hashMap.keys {
				// recursion
				keyValuePairs.append(key + Parser.dictKeyValueDelimiter + toStringRecursive(hashMap[key]!))
			}
			
			result += keyValuePairs.get(0);
			for i in 1..<keyValuePairs.count {
				result += Parser.listValueDelimiter + keyValuePairs.get(i);
			}
			return result + Parser.dictEnd;
		}
		fatalError("object: \(object.dynamicType) should be convertible to String, Array or Dictionary")
	}
	
	/**
	 * @return string which can be parsed back to original object of Parser
	 * if object could not be converted it returns _NULL_
	 */
	func convertToString() -> String! {
		return toStringRecursive(object);
	}
}
