

struct Color: ObjectConvertible, Equatable {
	var red: Double
	var green: Double
	var blue: Double
	var alpha: Double
	
	init(red: Double, green: Double, blue: Double, alpha: Double) {
		self.red = red;
		self.green = green;
		self.blue = blue;
		self.alpha = alpha;
	}
	
	// --- ObjectConvertible
	
	static func convertFromObject(_ object: Object) throws -> Color {
		var color = Color(red: 0,green: 0,blue: 0,alpha: 0)
		try color.convertFromObject(object)
		return color
	}
	
	mutating func convertFromObject(_ object: Object) throws {
		guard let list = Helper.castToArrayOfStrings(object) else {
			throw IllegalArgumentException("list is null")
		}
			
		if (list.count != 4) {
			throw IllegalArgumentException("list has not size == 2");
		}
		
		guard
			let red = Double(list[0]),
			let green = Double(list[1]),
			let blue = Double(list[2]),
			let alpha = Double(list[3]) else {
			throw IllegalArgumentException("could not parse numbers from String");
		}
		self.red = red
		self.green = green
		self.blue = blue
		self.alpha = alpha
	}
	
	func convertToObject() -> Object {
		return .array([
			.string("\(red)"),
			.string("\(green)"),
			.string("\(blue)"),
			.string("\(alpha)")
			])
	}
	
	// MARK: - Equatable
	
	static func ==(c1: Color, c2: Color) -> Bool {
		return c1.red == c2.red
			&& c1.green == c2.green
			&& c1.blue == c2.blue
			&& c1.alpha == c2.alpha
	}
}
