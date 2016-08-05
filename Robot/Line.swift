//
//  Line.swift
//  Swift 3 TestProject
//
//  Created by Maximilian Hünenberger on 16.7.16.
//
//

import Foundation

struct Line: ObjectConvertible {
	var start: Vector2D
	var end: Vector2D
	
	init(start: Vector2D, end: Vector2D) {
		self.start = start;
		self.end = end;
	}
	
	init(_ startX: Double, _ startY: Double, _ endX: Double, _ endY: Double) {
		start = Vector2D(startX, startY)
		end = Vector2D(endX, endY)
	}
	
	mutating func move(_ dv: Vector2D) {
		start.addInPlace(dv)
		end.addInPlace(dv)
	}
	func moved(_ dv: Vector2D) -> Line {
		return Line(start: start.add(dv), end: end.add(dv))
	}
	
	// --- ObjectConvertible
	
	static func convertFromObject(_ object: Object) throws -> Line {
		var line = Line(start: Vector2D(0,0), end: Vector2D(0,0))
		try line.convertFromObject(object)
		return line
	}
	
	mutating func convertFromObject(_ object: Object) throws {
		guard let list = Helper.castToArrayOfObjects(object) else {
			throw IllegalArgumentException("list is null")
		}
		
		if (list.count != 2) {
			throw IllegalArgumentException("list has not size == 2");
		}
		
		try self.start.convertFromObject(list.get(0));
		try self.end.convertFromObject(list.get(1));
	}
	
	func convertToObject() -> Object {
		return .array([
			start.convertToObject(),
			end.convertToObject()
		])
	}
	
	// --- Drawable
	/*
	public Line getLine() { return this; }
	public Rectangle getRectangle() { return null; }
	public Polygon getPolygon() { return null; }
	*/
}
