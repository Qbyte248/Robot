//
//  Vector.swift
//  Swift 3 TestProject
//
//  Created by Maximilian Hünenberger on 22.7.16.
//
//

import Foundation

struct Vector: Equatable {
	var x, y, z: Double
	
	init(_ x: Double, _ y: Double, _ z: Double) {
		self.x = x
		self.y = y
		self.z = z
	}
	
	func add(_ v: Vector) -> Vector {
		return Vector(x + v.x, y + v.y, z + v.z)
	}
	
	func subtract(_ v: Vector) -> Vector {
		return Vector(x - v.x, y - v.y, z - v.z)
	}
	
	static prefix func - (v: Vector) -> Vector {
		return Vector(-v.x, -v.y, -v.z)
	}
}
func == (v1: Vector, v2: Vector) -> Bool {
	return v1.x == v2.x && v1.y == v2.y && v1.z == v2.z
}
