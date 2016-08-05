
struct Size: ObjectConvertible {
	var width: Double
	var height: Double
	
	init(_ width: Double, _ height: Double) {
		self.width = width;
		self.height = height;
	}
	
	// --- ObjectConvertible
	
	static func convertFromObject(_ object: Object) throws -> Size {
		var size = Size(0,0)
		try size.convertFromObject(object)
		return size
	}
	
	mutating func convertFromObject(_ object: Object) throws {
		var v = Vector2D(0,0);
		try v.convertFromObject(object);
		width = v.x;
		height = v.y;
	}
	
	func convertToObject() -> Object {
		return Vector2D(width, height).convertToObject();
	}
}

struct Rectangle: ObjectConvertible {
	var origin: Vector2D
	var size: Size
	
	init(_ x: Double, _ y: Double, _ width: Double, _ height: Double) {
		origin = Vector2D(x, y);
		size = Size(width, height);
	}
	
	init(origin: Vector2D, size: Size) {
		self.origin = origin
		self.size = size
	}
	
	mutating func move(_ dv: Vector2D) {
		origin.addInPlace(dv)
	}
	func moved(_ dv: Vector2D) -> Rectangle {
		return Rectangle(origin: origin.add(dv), size: size)
	}
	
	// MARK: ObjectConvertible
	
	static func convertFromObject(_ object: Object) throws -> Rectangle {
		var rect = Rectangle(0,0,0,0)
		try rect.convertFromObject(object)
		return rect
	}
	
	mutating func convertFromObject(_ object: Object) throws {
		guard let list = Helper.castToArrayOfObjects(object) else {
			// !!! can throw
			throw IllegalArgumentException("list is null");
		}
		
		if (list.count != 2) {
			throw IllegalArgumentException("list has not size == 2");
		}
		
		try self.origin.convertFromObject(list.get(0));
		try self.size.convertFromObject(list.get(1));
	}
	
	func convertToObject() -> Object {
		return .array([
			origin.convertToObject(),
			size.convertToObject()
			])
	}
	
	
}
