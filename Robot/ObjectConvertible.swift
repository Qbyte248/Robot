
/**
* An Interface which defines the conversion from and to objects which can be parsed by "Parser"
*
* seeAlso: "ObjectConvertibleClass"
*/
public protocol ObjectConvertible {
	/// Creates new Object from self
	///
	/// parameter object: which was parsed by Parser
	static func convertFromObject(_ object: Object) throws -> Self
	
	/// - returns: object which can be parsed by "Parser"
	func convertToObject() -> Object;
}
extension ObjectConvertible {
	
	/// - returns: String which was created by Parser from convertToObject() ; is nil if object could not be parsed by Parser
	public func convertToString() -> String? {
		let object = convertToObject();
		
		if let list = Helper.castToArrayOfObjects(object) {
			return Parser(list).convertToString()
		}
		
		if let map = Helper.castToDictionaryOfObjects(object) {
			return Parser(map).convertToString()
		}
		
		return nil;
	}
	
	/**
	parses (with Parser) string to object and calls convertFromObject(object)
	
	- parameters:
		- string: which gets converted
	- throws:
		IllegalArgumentException if parser could not parse string
	*/
	public static func convertFromString(_ string: String) throws -> Self {
		let parser = try Parser(string)
		return try Self.convertFromObject(parser.object)
	}
}

protocol DefaultInstantiable: class {
	// FIXME: there should be "required" functions which "go up" the supeclass hierarchy
	init(default: Void)
}

protocol ObjectConvertibleClass: class, ObjectConvertible, DefaultInstantiable {
	/// Initializes current properties with "object"
	///
	/// parameter object: which was parsed by Parser
	func convertFromObject(_ object: Object) throws
}

extension ObjectConvertibleClass {
	static func convertFromObject(_ object: Object) throws -> Self {
		let defInstance = Self.init(default: ())
		try defInstance.convertFromObject(object)
		return defInstance
	}
}


