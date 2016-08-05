
struct Polygon: ObjectConvertible {
	var points = [Vector2D]();
	
	init(points: [Vector2D] = []) {
		self.points = points
	}
	
	mutating func append(_ point: Vector2D) {
		points.append(point);
	}
	func moved(_ dv: Vector2D) -> Polygon {
		var poly = self
		poly.move(dv)
		return poly
	}
	mutating func move(_ dv: Vector2D) {
		for i in 0..<points.count {
			points[i].addInPlace(dv);
		}
	}
	mutating func moveToPoint(_ point: Vector2D) {
		if (points.isEmpty) {
			return;
		}
		self.move(point.subtract(points.get(0)));
	}
	
	func getLines() -> [Line] {
		var lines = Array<Line>();
		if (points.isEmpty) {
			return lines;
		}
		if (points.count == 1) {
			let point = points.get(0);
			lines.add(Line(start: point, end: point));
			return lines;
		}
		if (points.count == 2) {
			lines.add(Line(start: points.get(0), end: points.get(1)));
			return lines;
		}
		
		var currentPoint = points.get(0);
		for i in 1..<points.count {
			let newPoint = points.get(i);
			lines.add(Line(start: currentPoint, end: newPoint));
			currentPoint = newPoint
		}
		lines.add(Line(start: points.get(points.count - 1), end: points.get(0)));
		return lines;
	}
	
	// --- ObjectConvertible
	
	static func convertFromObject(_ object: Object) throws -> Polygon {
		var poly = Polygon()
		try poly.convertFromObject(object)
		return poly
	}
	
	mutating func convertFromObject(_ object: Object) throws {
		guard let list = Helper.castToArrayOfObjects(object) else {
			// !!! can throw
			throw IllegalArgumentException("list is null")
		}
		
		self.points = Array<Vector2D>();
		for obj in list {
			var point = Vector2D(0,0);
			try point.convertFromObject(obj);
			self.points.add(point);
		}
	}
	
	func convertToObject() -> Object {
		return .array(points.map{ $0.convertToObject() })
	}
	
}
