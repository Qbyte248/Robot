//
//  Position.swift
//  Swift 3 TestProject
//
//  Created by Maximilian Hünenberger on 27.7.16.
//
//

import Foundation

struct Position: ObjectConvertible, Equatable {
	var x: Int
	var y: Int
	
	// MARK: - ObjectConvertible
	
	static func convertFromObject(_ object: Object) throws -> Position {
		var pos = Position(x: 0, y: 0)
		try pos.convertFromObject(object)
		return pos
	}
	
	mutating func convertFromObject(_ object: Object) throws {
		guard let list = Helper.castToArrayOfStrings(object) else {
			throw IllegalArgumentException("list is null")
		}
		
		if (list.count != 2) {
			throw IllegalArgumentException("list has not size == 2");
		}
		
		guard
			let x = Int(list[0]),
			let y = Int(list[1]) else {
				throw IllegalArgumentException("could not parse numbers from String")
		}
		self.x = x
		self.y = y
	}
	
	func convertToObject() -> Object {
		return .array([
			.string("\(x)"),
			.string("\(y)")
			])
	}
	
	// MARK: - Equatable
	
	static func == (p1: Position, p2: Position) -> Bool {
		return p1.x == p2.x && p1.y == p2.y
	}
}
