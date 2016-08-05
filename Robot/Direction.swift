//
//  Direction.swift
//  Swift 3 TestProject
//
//  Created by Maximilian Hünenberger on 27.7.16.
//
//

import Foundation

enum Direction: String, ObjectConvertible {
	case north, south, west, east
	
	func turnedLeft() -> Direction {
		switch self {
		case .north: return .west
		case .south: return .east
		case .west: return .south
		case .east: return .north
		}
	}
	func turnedRight() -> Direction {
		switch self {
		case .north: return .east
		case .south: return .west
		case .west: return .north
		case .east: return .south
		}
	}
	
	// MARK: - ObjectConvertible
	
	static func convertFromObject(_ object: Object) throws -> Direction {
		guard
			case .string(let str) = object,
			let direction = Direction(rawValue: str) else {
			throw IllegalArgumentException("object (\(object)) is not a string or string could not be converted to Direction")
		}
		return direction
	}
	
	func convertToObject() -> Object {
		return .string(self.rawValue)
	}
}
