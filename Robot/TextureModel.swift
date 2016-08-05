//
//  TextureModel.swift
//  Swift 3 TestProject
//
//  Created by Maximilian Hünenberger on 3.8.16.
//
//

import Foundation

enum Rotate {
	static func left(vector: inout Vector, around point: Vector2D) {
		vector.x -= point.x
		vector.y -= point.y
		(vector.x, vector.y) = (-vector.y, vector.x)
		vector.x += point.x
		vector.y += point.y
	}
	static func left(vector: inout Vector2D, around point: Vector2D) {
		vector.x -= point.x
		vector.y -= point.y
		(vector.x, vector.y) = (-vector.y, vector.x)
		vector.x += point.x
		vector.y += point.y
	}
	
	static func right(vector: inout Vector, around point: Vector2D) {
		vector.x -= point.x
		vector.y -= point.y
		(vector.x, vector.y) = (vector.y, -vector.x)
		vector.x += point.x
		vector.y += point.y
	}
	static func right(vector: inout Vector2D, around point: Vector2D) {
		vector.x -= point.x
		vector.y -= point.y
		(vector.x, vector.y) = (vector.y, -vector.x)
		vector.x += point.x
		vector.y += point.y
	}
}

protocol TextureModel {
	func getTexture() -> Texture
	mutating func rotateLeft(around pos: Vector2D)
	mutating func rotateRight(around pos: Vector2D)
	
	var center: Vector { get }
}

struct TextureModelSet: TextureModel {
	
	var textureModels = [TextureModel]()
	
	var center: Vector { return Vector(0,0,0) }
	
	init(textureModels: [TextureModel] = []) {
		self.textureModels = textureModels
	}
	
	func getTexture() -> Texture {
		func distance(_ vector: Vector) -> Double {
			return vector.x - vector.y + vector.z / 5
		}
		return Texture(drawables: textureModels.sorted{
			distance($0.center) < distance($1.center)
		}.flatMap{ $0.getTexture().drawables })
	}
	
	mutating func rotateLeft(around pos: Vector2D) {
		for i in textureModels.indices {
			textureModels[i].rotateLeft(around: pos)
		}
	}
	
	mutating func rotateRight(around pos: Vector2D) {
		for i in textureModels.indices {
			textureModels[i].rotateRight(around: pos)
		}
	}
}


struct Cuboid: TextureModel {
	var bottomCenter: Vector
	var dimension: Vector
	
	var center: Vector {
		return Vector(bottomCenter.x, bottomCenter.y, bottomCenter.z + dimension.z / 2)
	}
	
	// front in +y direction
	var color: (front: Color, back: Color, left: Color, right: Color, top: Color)
	
	init(bottomCenter: Vector, dimension: Vector, color: (front: Color, back: Color, left: Color, right: Color, top: Color)) {
		self.bottomCenter = bottomCenter
		self.dimension = dimension
		self.color = color
	}
	
	init(bottomCenter: Vector, dimension: Vector, color: Color) {
		self.bottomCenter = bottomCenter
		self.dimension = dimension
		self.color = (color, color, color, color, color)
	}
	
	func getTexture() -> Texture {
		return Texture.cuboid(bottomCenter: bottomCenter,
		                      dimension: dimension,
		                      frontColor: color.front,
		                      topColor: color.top,
		                      sideColor: color.right)
	}
	
	mutating func rotateLeft(around pos: Vector2D) {
		self.color = (color.right, color.left, color.front, color.back, color.top)
		
		(dimension.x, dimension.y) = (dimension.y, dimension.x)
		
		Rotate.left(vector: &bottomCenter, around: pos)
	}
	mutating func rotateRight(around pos: Vector2D) {
		self.color = (color.left, color.right, color.back, color.front, color.top)
		
		(dimension.x, dimension.y) = (dimension.y, dimension.x)
		
		Rotate.right(vector: &bottomCenter, around: pos)
	}
}

struct Rectangle3D: TextureModel {
	
	enum Orientation {
		case x, y, z
	}
	
	var center: Vector
	/// y points in y direction or up (z)
	var dimension: Vector2D
	var orientation: Orientation
	
	var color: Color
	
	func getCorners() -> [Vector] {
		func allVectors(v1: Vector, v2: Vector) -> [Vector] {
			let minusV1 = -v1
			return [v1.add(v2), v1.subtract(v2), minusV1.subtract(v2), minusV1.add(v2)].map(center.add)
		}
		
		switch orientation {
		case .z:
			return allVectors(v1: Vector(dimension.x / 2, 0, 0), v2: Vector(0, dimension.y / 2, 0))
		case .x:
			return allVectors(v1: Vector(0, dimension.x / 2, 0), v2: Vector(0, 0, dimension.y / 2))
		case .y:
			return allVectors(v1: Vector(dimension.x / 2, 0, 0), v2: Vector(0, 0, dimension.y / 2))
			
		}
	}
	
	func getTexture() -> Texture {
		return Texture(drawables: [
			.color(self.color),
			.polygon(Polygon(points: getCorners().map(Texture.offsetVectorFromCoordinates)))
			])
	}
	
	mutating func rotateLeft(around pos: Vector2D) {
		switch orientation {
		case .x: orientation = .y
		case .y: orientation = .x
		case .z:
			(dimension.x, dimension.y) = (dimension.y, dimension.x)
		}
		
		Rotate.left(vector: &center, around: pos)
	}
	
	mutating func rotateRight(around pos: Vector2D) {
		switch orientation {
		case .x: orientation = .y
		case .y: orientation = .x
		case .z:
			(dimension.x, dimension.y) = (dimension.y, dimension.x)
		}
		
		Rotate.right(vector: &center, around: pos)
	}
}

struct Polygon3D: TextureModel {
	
	/// FIXME: there should be also "-x", "-y" and "-z"
	enum Orientation {
		case x, y, z
	}
	
	var center: Vector
	/// y points in y direction or up (z)
	var points: [Vector2D]
	var orientation: Orientation
	
	var color: Color
	
	func getCorners() -> [Vector] {
		switch orientation {
		case .x:
			return points.map{ point in
				Vector(0, point.x, point.y).add(center)
			}
		case .y:
			return points.map{ point in
				Vector(point.x, 0, point.y).add(center)
			}
		case .z:
			return points.map{ point in
				Vector(point.x, point.y, 0).add(center)
			}
		}
	}
	
	func getTexture() -> Texture {
		return Texture(drawables: [
			.color(self.color),
			.polygon(Polygon(points: getCorners().map(Texture.offsetVectorFromCoordinates)))
			])
	}
	
	mutating func rotateLeft(around pos: Vector2D) {
		switch orientation {
		case .x: orientation = .y
		case .y: orientation = .x
		case .z:
			for i in points.indices {
				Rotate.left(vector: &points[i], around: Vector2D(0,0))
			}
		}
		
		Rotate.left(vector: &center, around: pos)
	}
	
	mutating func rotateRight(around pos: Vector2D) {
		switch orientation {
		case .x: orientation = .y
		case .y: orientation = .x
		case .z:
			for i in points.indices {
				Rotate.right(vector: &points[i], around: Vector2D(0,0))
			}
		}
		
		Rotate.right(vector: &center, around: pos)
	}
}
