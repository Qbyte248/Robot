//
//  Robot.swift
//  Swift 3 TestProject
//
//  Created by Maximilian Hünenberger on 27.7.16.
//
//

import Foundation

final class Robot: ObjectConvertibleClass {
	// FIXME: Make it a real superclass if limitations are solved
	var superClass: Item
	var position: Position {
		get { return superClass.position }
		set { superClass.position = newValue }
	}
	var texture: Texture {
		get {
			return directionTextures[self.direction]!
			/*superClass.texture = texture
			return texture*/
		}
		//set { superClass.texture = newValue }
	}
	
	private var directionTextures = [Direction : Texture]()
	
	var direction: Direction
	
	weak var world: World? {
		didSet {
			world?.robots.append(self)
			world?.robotMoved()
		}
	}
	
	// TODO: To be used
	private(set) var diamondCount = 0
	
	init(
		position: Position = Position(x: 0, y: 0),
		direction: Direction = .north, world: World? = nil) {
		self.direction = direction
		superClass = Item(default: ())
		self.position = position
		
		makeTextureModel()
		
		self.world = world
		self.world?.robots.append(self)
		self.world?.robotMoved()
	}
	
	required init(default: Void) {
		direction = .north
		superClass = Item(default: ())
		
		makeTextureModel()
	}
	
	/// sets textures of "directionTextures"
	func makeTextureModel() {
		let leg = Cuboid(bottomCenter: Vector(0.5, 0.5, 0.0),
		                 dimension: Vector(0.2, 0.2, 1),
		                 color: Color(red: 0, green: 0.8, blue: 0.8, alpha: 1))
		let rightLeg: Cuboid = lens(leg){ (leg: inout Cuboid) in leg.bottomCenter.x += 0.15 }
		let leftLeg: Cuboid = lens(leg){ (leg: inout Cuboid) in leg.bottomCenter.x -= 0.15 }
		
		let torso = Cuboid(bottomCenter: Vector(0.5, 0.5, 1),
		                   dimension: Vector(0.5, 0.5, 0.7),
		                   color: Color(red: 0, green: 0.8, blue: 1, alpha: 1))
		let head = Cuboid(bottomCenter: Vector(0.5, 0.5, 1.8),
		                  dimension: Vector(0.2, 0.2, 0.2),
		                  color: Color(red: 1, green: 0.2, blue: 0, alpha: 1))
		
		let arm = Cuboid(bottomCenter: Vector(0.5, 0.5, 0.5),
		                 dimension: Vector(0.2, 0.2, 1.2),
		                 color: Color(red: 0, green: 0.5, blue: 0.5, alpha: 1))
		let rightArm = lens(arm) { (arm: inout Cuboid) in arm.bottomCenter.x += 0.25 + 0.1 }
		let leftArm = lens(arm) { (arm: inout Cuboid) in arm.bottomCenter.x -= 0.25 + 0.1 }
		
		var textureModel = TextureModelSet(textureModels: [leftLeg, rightLeg, leftArm, torso, rightArm, head])
		
		// create associated textures
		
		for direction in [Direction.north, .west, .south, .east] {
			self.directionTextures[direction] = textureModel.getTexture()
			textureModel.rotateLeft(around: Vector2D(0.5, 0.5))
		}
	}
	
	func draw() {
		// TODO: implement???
	}
	
	private var nextPosition: Position {
		var newPosition = position
		switch direction {
		case .north: newPosition.y += 1
		case .south: newPosition.y -= 1
		case .west: newPosition.x -= 1
		case .east: newPosition.x += 1
		}
		return newPosition
	}
	
	enum RobotMoveError: Error {
		case blocked
	}
	
	func turnLeft() {
		self.direction = self.direction.turnedLeft()
		world?.robotMoved()
	}
	func turnRight() {
		self.direction = self.direction.turnedRight()
		world?.robotMoved()
	}
	
	// MARK: - Blocks
	private func placeBlockAt(_ position: Position) {
		placeBlockAt(x: position.x, y: position.y)
	}
	private func placeBlockAt(x: Int, y: Int) {
		world?.placeBlockAt(x: x, y: y)
	}
	func placeBlockInFront() {
		placeBlockAt(self.nextPosition)
	}
	func placeBlockBelow() {
		placeBlockAt(self.position)
	}
	
	func removeBlockInFront() {
		let nextPosition = self.nextPosition
		world?.removeBlockAt(x: nextPosition.x, y: nextPosition.y)
	}
	func removeBlockBelow() {
		world?.removeBlockAt(x: self.position.x, y: self.position.y)
	}
	
	func numberOfBlocksInFront() -> Int {
		return world!.blocksAt(self.nextPosition)
	}
	func numberOfBlocksBelow() -> Int {
		return world!.blocksAt(self.position)
	}
	
	// MARK: - Move
	
	var isBlocked: Bool {
		guard let world = world else {
			return false
		}
		
		let nextPosition = self.nextPosition
		guard
			case 0..<world.width = nextPosition.x,
			case 0..<world.depth = nextPosition.y else {
				return true
		}
		
		guard abs(world.blocksAt(nextPosition) - world.blocksAt(position)) <= 1 else {
			return true
		}
		
		return false
	}
	
	/// ignores errors of tryMovingForward
	func moveForward() {
		do {
			try tryMovingForward()
		} catch {}
	}
	
	private func tryMovingForward() throws {
		
		guard let world = world else {
			position = self.nextPosition
			return
		}
		
		guard !self.isBlocked else {
			// FIXME: fatalError ?
			throw RobotMoveError.blocked
		}
		
		self.position = nextPosition
		
		world.robotMoved()
		
		guard let portal1 = world.itemsAt(self.position).first(where: {
			guard case .portal(_) = $0.type else {
				return false
			}
			return true
		}) else {
			return
		}
		
		guard case .portal(let color) = portal1.type else {
			fatalError("type should be portal")
		}
		
		guard let portal2 = world.items.first(where: {
			$0.type == .portal(color: color) && $0 !== portal1
		}) else {
			// FIXME: fatalError ?
			print("there is no second portal")
			return
		}
		
		self.position = portal2.position
		
		world.robotMoved()
	}
	
	// MARK: - Checks
	
	var isOnDiamond: Bool {
		return world!.itemsAt(self.position).contains{
			$0.type == .diamond
		}
	}
	
	var isOnClosedSwitch: Bool {
		return world!.itemsAt(self.position).contains{
			$0.type == .switch(highlighted: false)
		}
	}
	
	var isOnOpenSwitch: Bool {
		return world!.itemsAt(self.position).contains{
			$0.type == .switch(highlighted: true)
		}
	}
	
	// MARK: - Actions
	
	func collectDiamond() {
		guard let world = world else {
			// FIXME: fatalError?
			return
		}
		guard let diamond = world.itemsAt(self.position).first(where: { $0.type == .diamond }) else {
			// FIXME: fatalError ?
			return
		}
		world.removeItem(diamond)
		world.itemsChanged()
		
		self.diamondCount += 1
	}
	
	func toggleSwitch() {
		guard let world = world else {
			// FIXME: fatalError?
			return
		}
		guard let switchItem = world.itemsAt(self.position).first(where: {
			guard case .switch(_) = $0.type else {
				return false
			}
			return true
		}) else {
			// FIXME: fatalError ?
			return
		}
		guard case .switch(let open) = switchItem.type else {
			fatalError("this so")
		}
		
		switchItem.type = .switch(highlighted: !open)
		world.itemsChanged()
	}
	
	// MARK: - ObjectConvertible
	
	func convertFromObject(_ object: Object) throws {
		// !!! can throw
		try superClass.convertFromObject(object);
		
		guard case .dictionary(let map) = object else {
			throw IllegalArgumentException("object is not a dictionary")
		}
		
		// --- Direction
		guard let directionObj = map.get("direction") else {
			throw IllegalArgumentException("there is no direction key")
		}
		self.direction = try Direction.convertFromObject(directionObj);
		
		/*
		// --- Name
		Object nameObj = map.get("name");
		// !!! can throw
		Helper.throwIllegalErgumentExceptionIfNull("nameObj is null", nameObj);
		this.name = Helper.castToString(nameObj);
		// !!! can throw
		Helper.throwIllegalErgumentExceptionIfNull("name is null", this.name);
		*/
	}
	
	func convertToObject() -> Object {
		superClass.texture = self.texture
		let obj = superClass.convertToObject()
		guard case .dictionary(var map) = obj else {
			fatalError("obj should be a dictionary")
		}
		map.put("direction", direction.convertToObject())
		//map.put("name", name)
		return .dictionary(map)
	}
}
