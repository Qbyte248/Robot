//
//  Item.swift
//  Swift 3 TestProject
//
//  Created by Maximilian Hünenberger on 27.7.16.
//
//

import Foundation

final class Item: ObjectConvertibleClass {
	
	enum ItemType: Equatable {
		case clear
		case start(direction: Direction)
		case diamond
		case `switch`(highlighted: Bool)
		case portal(color: Color)
		
		// MARK: - Equatable
		
		static func == (t1: ItemType, t2: ItemType) -> Bool {
			switch (t1, t2) {
			case (.clear, .clear), (.diamond, .diamond):
				return true
			case let (.start(dir1), .start(dir2)):
				return dir1 == dir2
			case let (.switch(h1), .switch(h2)):
				return h1 == h2
			case let (.portal(color1), .portal(color2)):
				return color1 == color2
			default:
				return false
			}
		}
	}
	
	var position = Position(x: 0,y: 0)
	var texture = Texture();
	
	var type: ItemType {
		didSet {
			updateTexture()
		}
	}
	
	// MARK: - init
	init(type: ItemType, position: Position) {
		self.type = type
		self.position = position
		updateTexture()
	}
	
	func updateTexture() {
		
		let itemDimension = 0.8
		
		switch type {
		case .clear:
			self.texture = Texture()
		case .diamond:
			let cuboid = Texture.cuboid(bottomCenter: Vector(0.5, 0.5, 2.5),
			                            dimension: Vector(0.5, 0.5, 0.7),
			                            frontColor: Color(red: 0, green: 1, blue: 1, alpha: 1),
			                            topColor: Color(red: 0, green: 1, blue: 1, alpha: 1),
			                            sideColor: Color(red: 0, green: 1, blue: 1, alpha: 1))
			let bottomPlate = Texture.cuboid(bottomCenter: Vector(0.5, 0.5, 0),
			                                 dimension: Vector(1, 1, 0.0),
			                                 frontColor: Color(red: 0, green: 1, blue: 1, alpha: 1),
			                                 topColor: Color(red: 0, green: 1, blue: 1, alpha: 1),
			                                 sideColor: Color(red: 0, green: 1, blue: 1, alpha: 1))
			self.texture = Texture(drawables: bottomPlate.drawables + cuboid.drawables)
		case .switch(let highlighted):
			if highlighted {
				self.texture = Texture.cuboid(bottomCenter: Vector(0.5, 0.5, 0),
				                              dimension: Vector(itemDimension, itemDimension, 0.1),
				                              frontColor: Color(red: 1, green: 1, blue: 1, alpha: 1),
				                              topColor: Color(red: 0.9, green: 0.9, blue: 0.9, alpha: 1),
				                              sideColor: Color(red: 1, green: 1, blue: 1, alpha: 1))
			} else {
				self.texture = Texture.cuboid(bottomCenter: Vector(0.5, 0.5, 0),
				                              dimension: Vector(itemDimension, itemDimension, 0.1),
				                              frontColor: Color(red: 1, green: 1, blue: 1, alpha: 1),
				                              topColor: Color(red: 0.3, green: 0.3, blue: 0.3, alpha: 1),
				                              sideColor: Color(red: 1, green: 1, blue: 1, alpha: 1))
			}
		case .portal(let color):
			let bottomPlate = Texture.cuboid(bottomCenter: Vector(0.5, 0.5, 0),
			                                 dimension: Vector(itemDimension, itemDimension, 0.1),
			                                 frontColor: color,
			                                 topColor: color,
			                                 sideColor: color)
			let middlePlateColor = Color(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.5)
			let middlePlate = Texture.cuboid(bottomCenter: Vector(0.5, 0.5, 0.1),
			                                 dimension: Vector(itemDimension * 0.5,
			                                                    itemDimension * 0.5,
			                                                    0),
			                                 frontColor: middlePlateColor,
			                                 topColor: middlePlateColor,
			                                 sideColor: middlePlateColor)
			self.texture = Texture(drawables: bottomPlate.drawables + middlePlate.drawables)
			
		case .start(let direction):
			let arrow = Polygon3D(center: Vector(0.5, 0.5, 0),
			                      points: [
									// tail
									Vector2D(-0.1, +0.0),
									Vector2D(-0.1, -0.4),
									Vector2D(+0.1, -0.4),
									Vector2D(+0.1, +0.0),
									
									// tip
									Vector2D(+0.4, +0.0),
									Vector2D(+0.0, +0.4),
									Vector2D(-0.4, +0.0)
									],
			                      orientation: .z,
			                      color: Color(red: 1, green: 1, blue: 1, alpha: 1))
			let background = Rectangle3D(center: Vector(0.5, 0.5, 0),
			                             dimension: Vector2D(1, 1),
			                             orientation: .z,
			                             color: Color(red: 0, green: 0, blue: 0, alpha: 1))
			var textureSet = TextureModelSet(textureModels: [background, arrow])
			
			switch direction {
			case .north: break
			case .south:
				textureSet.rotateLeft(around: Vector2D(0.5, 0.5))
				textureSet.rotateLeft(around: Vector2D(0.5, 0.5))
			case .west:
				textureSet.rotateLeft(around: Vector2D(0.5, 0.5))
			case .east:
				textureSet.rotateRight(around: Vector2D(0.5, 0.5))
			}
			self.texture = textureSet.getTexture()
		}
	}
	
	// MARK: - DefaultInitializable
	required init(default: Void) {
		type = .clear
	}
	
	// MARK: - ObjectConvertible
	
	func convertFromObject(_ object: Object) throws {
		guard case .dictionary(let objectDict) = object else {
			throw IllegalArgumentException("object is not a dictionary");
		}
		
		// --- Position
		guard let positionObj = objectDict.get("position") else {
			throw IllegalArgumentException("no \"position\" key")
		}
		self.position = try Position.convertFromObject(positionObj);
		
		// --- Texture
		guard let textureObj = objectDict.get("texture") else {
			throw IllegalArgumentException("no \"texture\" key")
		}
		self.texture = try Texture.convertFromObject(textureObj);
	}
	
	func convertToObject() -> Object {
		return .dictionary([
			"position" : position.convertToObject(),
			"texture" : texture.convertToObject()
			])
	}
}
