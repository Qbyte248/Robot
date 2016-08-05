//
//  Texture.swift
//  Swift 3 TestProject
//
//  Created by Maximilian Hünenberger on 27.7.16.
//
//

import Foundation

struct Texture: ObjectConvertible {
	var drawables = [Drawable]()
	
	init(drawables: [Drawable] = []) {
		self.drawables = drawables
	}
	
	mutating func append(_ drawable: Drawable) {
		drawables.append(drawable)
	}
	
	mutating func move(_ dv: Vector2D) {
		for i in drawables.indices {
			drawables[i].move(dv)
		}
	}
	
	func moved(_ dv: Vector2D) -> Texture {
		var texture = self
		texture.move(dv)
		return texture
	}
	
	static func offsetVectorFromCoordinates(_ vector: Vector) -> Vector2D {
		let newY = vector.y / sqrt(2) / 2;
		return Vector2D((vector.x + newY), -(vector.z + newY));
	}
	
	static func from3DPoints(_ points: [Vector]) -> Texture {
		return Texture(drawables: [.polygon(Polygon(points: points.map(Texture.offsetVectorFromCoordinates)))])
	}
	
	static func cuboid(position: Vector = Vector(0,0,0),
	                   dimension: Vector,
	                   frontColor: Color = Color(red: 1, green: 0, blue: 0, alpha: 1),
	                   topColor: Color = Color(red: 0, green: 1, blue: 0, alpha: 1),
	                   sideColor: Color = Color(red: 0, green: 0, blue: 1, alpha: 1)) -> Texture {
		var texture = Texture()
		
		let height = dimension.z
		let width = dimension.x
		
		let realDepth = dimension.y / 2 / sqrt(2);
		
		// Front
		texture.append(.color(frontColor));
		texture.append(.rectangle(Rectangle(0, -height, width, height)));
		
		// Top
		texture.append(.color(topColor));
		var polyTop = Polygon();
		[
			Vector2D(0, -height),
			Vector2D(width, -height),
			Vector2D(width + realDepth, -height - realDepth),
			Vector2D(realDepth, -height - realDepth)
			].forEach {
				polyTop.append($0);
		}
		texture.append(.polygon(polyTop));
		
		// Side
		texture.append(.color(sideColor))
		var polySide = Polygon();
		[
			Vector2D(width, -height),
			Vector2D(width , 0),
			Vector2D(width + realDepth, -realDepth),
			Vector2D(width + realDepth, -height - realDepth)
			].forEach{
				polySide.append($0);
		}
		texture.append(.polygon(polySide))
		
		// make lines
		texture.append(.color(Color(red: 0, green: 0, blue: 0, alpha: 1)))
		
		for line in polyTop.getLines() {
			texture.append(.line(line));
		}
		for line in polySide.getLines() {
			texture.append(.line(line));
		}
		texture.append(.line(Line(0, 0, width, 0)))
		texture.append(.line(Line(0, 0, 0, -height)))
		
		// move texture to correct place
		if position != Vector(0,0,0) {
			texture.move(offsetVectorFromCoordinates(position))
		}
		
		return texture
	}
	
	static func cuboid(bottomCenter: Vector,
	                   dimension: Vector,
	                   frontColor: Color = Color(red: 1, green: 0, blue: 0, alpha: 1),
	                   topColor: Color = Color(red: 0, green: 1, blue: 0, alpha: 1),
	                   sideColor: Color = Color(red: 0, green: 0, blue: 1, alpha: 1)) -> Texture {
		return Texture.cuboid(position: Vector(bottomCenter.x - dimension.x/2,
		                                       bottomCenter.y - dimension.y/2,
		                                       bottomCenter.z),
		                      dimension: dimension,
		                      frontColor: frontColor,
		                      topColor: topColor,
		                      sideColor: sideColor)
	}
	
	// MARK: - ObjectConvertible
	
	static func convertFromObject(_ object: Object) throws -> Texture {
		var texture = Texture()
		try texture.convertFromObject(object)
		return texture
	}
	
	// Helper
	mutating func convertFromObject(_ object: Object) throws {
		guard case .array(let array) = object else {
			throw IllegalArgumentException("object is not an array")
		}
		
		drawables = []
		
		for element in array {
			guard case .dictionary(let objectDict) = element else {
				throw IllegalArgumentException("element is not a dictionary")
			}
			
			for (key, value) in objectDict {
				guard case .array(let objectArray) = value else {
					throw IllegalArgumentException("value of objectDict is not an array")
				}
				
				switch key {
				case DrawableType.colors.rawValue:
					drawables += try objectArray.map {
						return .color(try Color.convertFromObject($0))
					}
				case DrawableType.lines.rawValue:
					drawables += try objectArray.map {
						return .line(try Line.convertFromObject($0))
					}
				case DrawableType.rectangles.rawValue:
					drawables += try objectArray.map {
						return .rectangle(try Rectangle.convertFromObject($0))
					}
				case DrawableType.polygons.rawValue:
					drawables += try objectArray.map {
						return .polygon(try Polygon.convertFromObject($0))
					}
				default:
					throw IllegalArgumentException("Unexpected Key")
				}
			}
		}
	}
	
	private enum DrawableType: String {
		case colors, lines, rectangles, polygons
	}
	
	func convertToObject() -> Object {
		
		var list: [[DrawableType : [Object]]] = []
		// FIXME: there is always a dict with ".colors"
		var dict: [DrawableType : [Object]] = [.colors : []]
		var currentDrawableType = DrawableType.colors
		
		func task<T: ObjectConvertible>(objectConvertible: T, drawableType: DrawableType) {
			if currentDrawableType == drawableType {
				dict[drawableType]!.append(objectConvertible.convertToObject())
			} else {
				list.append(dict)
				dict = [drawableType: [objectConvertible.convertToObject()]]
				currentDrawableType = drawableType
			}
		}
		
		for drawable in drawables {
			switch drawable {
			case .color(let color):
				task(objectConvertible: color, drawableType: .colors)
			case .line(let line):
				task(objectConvertible: line, drawableType: .lines)
			case .rectangle(let rectangle):
				task(objectConvertible: rectangle, drawableType: .rectangles)
			case .polygon(let polygon):
				task(objectConvertible: polygon, drawableType: .polygons)
			}
		}
		
		list.append(dict)
		
		var resultList = [Object]()
		resultList.reserveCapacity(list.count)
		for dict in list {
			var resultDict = [String : Object]()
			for (key, value) in dict {
				resultDict[key.rawValue] = .array(value)
			}
			resultList.append(.dictionary(resultDict))
		}
		
		return .array(resultList)
	}
}
