//
//  Drawable.swift
//  Swift 3 TestProject
//
//  Created by Maximilian Hünenberger on 27.7.16.
//
//

import Foundation

enum Drawable: ObjectConvertible {
	case color(Color)
	case line(Line)
	case rectangle(Rectangle)
	case polygon(Polygon)
	
	// MARK: ObjectConvertible
	
	static func convertFromObject(_ object: Object) throws -> Drawable {
		fatalError("this is logically impossible to create an object")
	}
	
	func convertToObject() -> Object {
		switch self {
		case .color(let color):
			return color.convertToObject()
		case .line(let line):
			return line.convertToObject()
		case .rectangle(let rect):
			return rect.convertToObject()
		case .polygon(let poly):
			return poly.convertToObject()
		}
	}
	
	mutating func move(_ dv: Vector2D) {
		switch self {
		case .color(_): break
		case .line(let line):
			self = .line(line.moved(dv))
		case .rectangle(let rect):
			self = .rectangle(rect.moved(dv))
		case .polygon(let poly):
			self = .polygon(poly.moved(dv))
		}
	}
}
