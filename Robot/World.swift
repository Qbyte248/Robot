//
//  World.swift
//  Swift 3 TestProject
//
//  Created by Maximilian Hünenberger on 27.7.16.
//
//

import Foundation

enum Level {
	static var world = World(width: 0, depth: 0)
	static var robot = Robot(default: ())
}

final class World: ObjectConvertibleClass {
	
	var robots = [Robot]()
	var items = [Item]()
	
	var halfBlocks: [[Int]]
	
	let width: Int
	let depth: Int
	
	// Draw properties
	var blockSideLength = 50.0
	var halfBlockTexture = Texture()
	
	var outputStream: OutputStream?
	
	init(width: Int, depth: Int, outputStream: OutputStream? = nil) {
		
		self.width = width
		self.depth = depth
		
		self.outputStream = outputStream
		
		self.halfBlocks = Array(
			repeating: Array(
				repeating: 0,
				count: depth),
			count: width)
		
		// generate halfBlockTexture
		
		let sideColor = Color(red: 1, green: 0.5, blue: 0, alpha: 1)
		let topColor = Color(red: 1, green: 0, blue: 0, alpha: 1)
		halfBlockTexture = Texture.cuboid(dimension: Vector(1, 1, 0.5),
		                                  frontColor: sideColor,
		                                  topColor: topColor,
		                                  sideColor: sideColor)
	}
	
	required init(default: Void) {
		width = 0
		depth = 0
		
		halfBlocks = []
	}
	
	func setBlockArray(_ array: [[Int]], at position: Position) {
		for y in array.indices {
			for x in array[y].indices {
				self.halfBlocks[x + position.x][y + position.y] = array[array.count - 1 - y][x]
			}
		}
	}
	
	func placeBlockAt(x: Int, y: Int) {
		setBlockAt(x: x, y: y, remove: false)
	}
	func removeBlockAt(x: Int, y: Int) {
		setBlockAt(x: x, y: y, remove: true)
	}
	
	func blocksAt(_ position: Position) -> Int {
		return blocksAt(x: position.x, y: position.y)
	}
	func blocksAt(x: Int, y: Int) -> Int {
		return halfBlocks[x][y]
	}
	
	func setBlockAt(x: Int, y: Int, remove: Bool) {
		guard
			case 0..<width = x,
			case 0..<depth = y else {
				// FIXME: this could be an error
				return
		}
		if remove {
			if halfBlocks[x][y] > 0 {
				halfBlocks[x][y] -= 1
			}
		} else {
			halfBlocks[x][y] += 1
		}
		blocksChanged()
	}
	
	func isBlockAt(x: Int, y: Int, z: Int) -> Bool {
		guard
			case 0..<width = x,
			case 0..<depth = y else {
				return true
		}
		return halfBlocks[x][y] > z
	}
	
	func itemsAt(_ position: Position) -> [Item] {
		return items.filter{ $0.position == position }
	}
	
	/// removes item with === check
	func removeItem(_ item: Item) {
		guard let index = items.index(where: { $0 === item }) else {
			fatalError("item is not in world")
		}
		items.remove(at: index)
	}
	
	func robotMoved() {
		repaint()
	}
	
	func blocksChanged() {
		repaint()
	}
	
	func itemsChanged() {
		repaint()
	}
	
	func repaint() {
		guard let outputStream = outputStream else {
			return
		}
		
		var command = try! Command(Protocol.Client.world)
		command.addParameter(Protocol.Key.world, self.convertToObject())
		try! command.sendWithOutputStream(outputStream)
	}
	
	enum IncompleteLevelError: Error {
		case missing(closedSwitches: Int, diamonds: Int)
	}
	
	// TODO: don't throw but send message to Java Server
	
	/// - throws: if level is not complete
	func completeLevel() throws {
		let (closedSwitches, diamonds) = items.reduce((0,0)) { sum, item in
			switch item.type {
			case .diamond: return (sum.0, sum.1 + 1)
			case .switch(false): return (sum.0 + 1, sum.1)
			default: return sum
			}
		}
		guard closedSwitches != 0 && diamonds != 0 else {
			throw IncompleteLevelError.missing(closedSwitches: closedSwitches,
			                                   diamonds: diamonds)
		}
	}
	
	// MARK: - ObjectConvertible
	
	enum Properties: String {
		case robots, items
		
		case halfBlocks
		
		case width, depth
		
		case blockSideLength
		case halfBlockTexture
	}
	
	func convertToObject() -> Object {
		let robotObjects = Object.array(robots.map{ $0.convertToObject() })
		let itemObjects = Object.array(items.map{ $0.convertToObject() })
		
		let halfBlockObjects = Object.array(halfBlocks.map{ yBlocks in
			.array(yBlocks.map{ height in
				.string(String(height))
				})
			})
		
		return .dictionary([
			Properties.robots.rawValue : robotObjects,
			Properties.items.rawValue : itemObjects,
			
			Properties.halfBlocks.rawValue : halfBlockObjects,
			
			Properties.width.rawValue : .string("\(self.width)"),
			Properties.depth.rawValue : .string("\(self.depth)"),
			
			Properties.blockSideLength.rawValue : .string("\(self.blockSideLength)"),
			
			Properties.halfBlockTexture.rawValue : halfBlockTexture.convertToObject()
			])
	}
	
	/// not finished
	func convertFromObject(_ object: Object) throws {
		fatalError("not finished")
		
		// parse halfBlocks
		/*guard case .array(let blocks) = object else {
			throw IllegalArgumentException("object is not an array")
		}
		self.halfBlocks = try blocks.map{ yBlocksObj in
			guard case .array(let yBlocks) = yBlocksObj else {
				throw IllegalArgumentException("yBlocksObj is not an array")
			}
			return try yBlocks.map{ heightStringObj in
				guard case .string(let heightString) = heightStringObj else {
					throw IllegalArgumentException("heightStringObj is not a string")
				}
				guard let height = Int(heightString) else {
					throw IllegalArgumentException("heightString is not convertible to an Int")
				}
				return height
			}
		}*/
	}
}


// MARK: - World extension

extension World {
	
	enum Stream {
		static var input: InputStream?
		static var output: OutputStream?
	}
	
	/// fps should be max ~ 1000
	static func end(fps: Double = 1.0) {
		// TODO: Send message to server ("Congrats", "LOOSER")
		
		print(Level.world.halfBlocks)
		print("World.end")
		
		print(Stream.output)
		
		let frameTime = 1.0 / fps
		var runCommand = try! Command(Protocol.Client.run)
		runCommand.addParameter(Protocol.Key.frameTime, .string("\(frameTime)"))
		try! runCommand.sendWithOutputStream(Stream.output!)
		
		Stream.input?.close()
		Stream.output!.close()
	}
	
	static func setup() {
		
		InputStream.getStreamsToHost(withName: "localhost",
		                              port: 1234,
		                              inputStream: nil,
		                              outputStream: &Stream.output)
		
		Stream.output!.open()
		
		Level.world = World(width: 10, depth: 10, outputStream: Stream.output!)
		Level.robot = Robot(position: Position(x: 0, y: 0), direction: .north, world: Level.world)
		
		print("here")
	}
	
	// FIXME: remove first world image from Java Server
	
	/// commands
	enum Chapter1 {
		/// just move forward
		static func level1() {
			World.setup()
			
			for x in 0...3 {
				Level.world.halfBlocks[x][5] = 2
			}
			Level.robot.position = Position(x: 0, y: 5)
			Level.robot.direction = .east
			
			// TODO: Remove some items
			Level.world.items = [
				Item(type: .start(direction: .east), position: Level.robot.position),
				Item(type: .start(direction: .west), position: Position(x: 0, y: 1)),
				Item(type: .start(direction: .north), position: Position(x: 3, y: 1)),
				Item(type: .start(direction: .south), position: Position(x: 6, y: 1)),
				Item(type: .diamond, position: Position(x: 3, y: 5))
			]
			
			Level.world.repaint()
		}
		
		/// move forward and collect 3 diamonds
		static func level2() {
			World.setup()
			
			for x in 0...8 {
				Level.world.halfBlocks[x][5] = 2
			}
			Level.world.halfBlocks[1][5] = 1
			Level.world.halfBlocks[4][5] = 1
			Level.world.halfBlocks[6][5] = 3
			
			Level.robot.position = Position(x: 0, y: 5)
			Level.robot.direction = .east
			Level.world.items = [
				Item(type: .start(direction: .east), position: Level.robot.position),
				Item(type: .diamond, position: Position(x: 2, y: 5)),
				Item(type: .diamond, position: Position(x: 6, y: 5)),
				Item(type: .diamond, position: Position(x: 7, y: 5))
			]
			
			Level.world.repaint()
		}
		
		/// move and turn left
		static func level3() {
			World.setup()
			
			for x in 0...3 {
				Level.world.halfBlocks[x][5] = 2
			}
			for y in 6...8 {
				Level.world.halfBlocks[3][y] = 2
			}
			Level.robot.position = Position(x: 0, y: 5)
			Level.robot.direction = .east
			Level.world.items = [
				Item(type: .start(direction: .east), position: Level.robot.position),
				Item(type: .diamond, position: Position(x: 3, y: 8))
			]
			
			Level.world.repaint()
		}
		
		/// collect 2 diamonds and turn left 2 times
		static func level4() {
			World.setup()
			
			for x in 1...4 {
				Level.world.halfBlocks[x][7] = 2
			}
			for y in 4...6 {
				Level.world.halfBlocks[4][y] = 2
			}
			for x in 2...3 {
				Level.world.halfBlocks[x][4] = 2
			}
			
			Level.robot.position = Position(x: 2, y: 4)
			Level.robot.direction = .east
			Level.world.items = [
				Item(type: .start(direction: .east), position: Level.robot.position),
				Item(type: .diamond, position: Position(x: 4, y: 5)),
				Item(type: .diamond, position: Position(x: 1, y: 7))
			]
			
			Level.world.repaint()
		}
		
		/// collect 1 diamond, toggle 1 switch and turn left 2 times
		static func level5() {
			World.setup()
			
			for y in 2...4 {
				Level.world.halfBlocks[3][y] = 2
			}
			for x in 4...5 {
				Level.world.halfBlocks[x][2] = 2
			}
			for y in 3...4 {
				Level.world.halfBlocks[5][y] = 2
			}
			
			Level.robot.position = Position(x: 3, y: 4)
			Level.robot.direction = .south
			Level.world.items = [
				Item(type: .start(direction: .south), position: Level.robot.position),
				Item(type: .diamond, position: Position(x: 4, y: 2)),
				Item(type: .switch(highlighted: false), position: Position(x: 5, y: 4))
			]
			
			Level.world.repaint()
		}
		
		/// collect 1 diamond, toggle 1 switch and port through portal
		static func level6() {
			World.setup()
			
			for y in 0...3 {
				Level.world.halfBlocks[5][y] = 2
			}
			for x in 2...4 {
				Level.world.halfBlocks[x][3] = 2
			}
			Level.world.halfBlocks[2][7] = 2
			Level.world.halfBlocks[2][6] = 2
			for y in 5...7 {
				Level.world.halfBlocks[1][y] = 2
			}
			
			Level.robot.position = Position(x: 5, y: 0)
			Level.robot.direction = .north
			
			let portalColor = Color(red: 0, green: 0, blue: 1, alpha: 1)
			
			Level.world.items = [
				Item(type: .start(direction: Level.robot.direction), position: Level.robot.position),
				Item(type: .switch(highlighted: false), position: Position(x: 3, y: 3)),
				
				Item(type: .portal(color: portalColor), position: Position(x: 2, y: 3)),
				Item(type: .portal(color: portalColor), position: Position(x: 2, y: 7)),
				
				Item(type: .diamond, position: Position(x: 1, y: 5))
			]
			
			Level.world.repaint()
		}
		
		/// TODO: copy code
		/**
		
		moveForward()
		turnLeft()
		moveForward()
		moveForward()
		collectDiamond()
		moveForward()
		toggleSwitch()
		
		*/
		///
		///
		/// fix the bug
		static func level7() {
			World.setup()
			
			Level.robot.position = Position(x: 0, y: 0)
			Level.robot.direction = .east
			
			Level.world.items = [
				Item(type: .start(direction: Level.robot.direction), position: Level.robot.position),
				Item(type: .diamond, position: Position(x: 2, y: 1)),
				Item(type: .switch(highlighted: false), position: Position(x: 2, y: 2))
			]
			
			Level.world.repaint()
		}
		
		/// TODO: copy code
		/**
		
		moveForward()
		moveForward()
		moveForward()
		turnLeft()
		toggleSwitch()
		moveForward()
		moveForward()
		moveForward()
		collectDiamond()
		moveForward()
		
		*/
		///
		///
		/// fix the bug
		static func level8() {
			World.setup()
			
			for (x, y) in (0...4).flatMap({ x in (0...4).map{ y in (x, y) } }) {
				Level.world.halfBlocks[x][y] = 1
			}
			
			for y in 1...3 {
				Level.world.halfBlocks[4][y] = 3
			}
			
			Level.robot.position = Position(x: 0, y: 0)
			Level.robot.direction = .east
			
			let portalColor = Color(red: 0, green: 0, blue: 1, alpha: 1)
			
			Level.world.items = [
				Item(type: .start(direction: Level.robot.direction), position: Level.robot.position),
				
				Item(type: .switch(highlighted: false), position: Position(x: 1, y: 2)),
				Item(type: .switch(highlighted: true), position: Position(x: 3, y: 0)),
				
				Item(type: .portal(color: portalColor), position: Position(x: 1, y: 4)),
				Item(type: .portal(color: portalColor), position: Position(x: 4, y: 1)),
				
				Item(type: .diamond, position: Position(x: 4, y: 3))
			]
			
			Level.world.repaint()
		}
		
	}
	
	/// functions - grouping Tasks
	enum Chapter2 {
		
		/// how to turn right?
		static func level1() {
			World.setup()
			
			for y in 4...7 {
				Level.world.halfBlocks[7][y] = 2
			}
		
			for x in 4...6 {
				Level.world.halfBlocks[x][4] = 2
			}
			
			Level.robot.position = Position(x: 7, y: 7)
			Level.robot.direction = .south
			
			Level.world.items = [
				Item(type: .start(direction: Level.robot.direction), position: Level.robot.position),
				
				Item(type: .diamond, position: Position(x: 4, y: 4))
			]
			
			Level.world.repaint()
		}
		
		/// use "func turnRight()" !!!
		static func level2() {
			World.setup()
			
			Level.world.setBlockArray([
				[2 ,2, 2, 2, 0],
				[2 ,2, 0, 0, 0],
				[2 ,0, 2, 2, 2],
				[1 ,0, 2, 0, 2],
				[0 ,2, 2, 0, 1],
				[0 ,0, 2, 0, 0],
				[0 ,0, 1, 0, 0],
				], at: Position(x: 2, y: 2))
			
			Level.robot.position = Position(x: 2 + 1, y: 2 + 2)
			Level.robot.direction = .east
			
			let portalColor = Color(red: 0, green: 0, blue: 1, alpha: 1)
			
			Level.world.items = [
				Item(type: .start(direction: Level.robot.direction), position: Level.robot.position),
				
				Item(type: .switch(highlighted: true), position: Position(x: 2 + 4, y: 2 + 3)),
				Item(type: .switch(highlighted: true), position: Position(x: 2 + 0, y: 2 + 1)),
				Item(type: .switch(highlighted: false), position: Position(x: 2 + 1, y: 2 + 5)),
				
				Item(type: .portal(color: portalColor), position: Position(x: 2 + 3, y: 2 + 2)),
				Item(type: .portal(color: portalColor), position: Position(x: 2 + 3, y: 2 + 6))

			]
			
			Level.world.repaint()
		}
		
		/// use function composition
		static func level3() {
			World.setup()
			
			Level.world.setBlockArray([
				[2, 2, 2, 2, 2],
				[2, 0, 0, 0, 2],
				[2, 0, 0, 0, 2],
				[2, 2, 2, 2, 2],
				], at: Position(x: 2, y: 2))
			
			Level.robot.position = Position(x: 2 + 0, y: 2 + 3)
			Level.robot.direction = .south
			
			Level.world.items = [
				Item(type: .start(direction: Level.robot.direction), position: Level.robot.position),
				
				Item(type: .switch(highlighted: false), position: Position(x: 2 + 0, y: 2 + 1)),
				Item(type: .switch(highlighted: false), position: Position(x: 2 + 2, y: 2 + 0)),
				Item(type: .switch(highlighted: false), position: Position(x: 2 + 4, y: 2 + 2)),
				Item(type: .switch(highlighted: false), position: Position(x: 2 + 2, y: 2 + 3)),

				Item(type: .diamond, position: Position(x: 2 + 0, y: 2 + 2)),
				Item(type: .diamond, position: Position(x: 2 + 1, y: 2 + 0)),
				Item(type: .diamond, position: Position(x: 2 + 4, y: 2 + 1)),
				Item(type: .diamond, position: Position(x: 2 + 3, y: 2 + 3)),

				
			]
			
			Level.world.repaint()
		}
		
		/// use function composition
		static func level4() {
			World.setup()
			
			Level.robot.position = Position(x: 0, y: 0)
			Level.robot.direction = .north
			
			for x in 0...3 {
				for y in 1...4 {
					if (x + y) % 2 == 0 {
						Level.world.items.append(Item(type: .switch(highlighted: false),
						                              position: Position(x: x, y: y)))
					} else {
						Level.world.items.append(Item(type: .diamond,
						                              position: Position(x: x, y: y)))
					}
				}
			}
			
			Level.world.items.append(Item(type: .start(direction: Level.robot.direction),
			                              position: Level.robot.position))
			
			Level.world.repaint()
		}
		
		/// TODO: copy code
		/**
		
		func turnAround() {
		
		}
		
		func solveStair() {
		
		}
		
		*/
		/// use function composition
		static func level5() {
			World.setup()
			
			Level.robot.position = Position(x: 4, y: 4)
			Level.robot.direction = .north
			
			Level.world.items = [
				Item(type: .start(direction: Level.robot.direction), position: Level.robot.position),
				
				Item(type: .diamond, position: Position(x: -1 + 4, y: +0 + 4)),
				Item(type: .diamond, position: Position(x: +1 + 4, y: +0 + 4)),
				Item(type: .diamond, position: Position(x: +0 + 4, y: -1 + 4)),
				Item(type: .diamond, position: Position(x: +0 + 4, y: +1 + 4)),
				
				
			]
			
			Level.world.repaint()
		}
		
		/// use function composition
		static func level6() {
			World.setup()
			
			Level.world.setBlockArray([
				[2, 4, 2],
				[2, 3, 2],
				[2, 2, 2],
				[2, 1, 2],
				[2, 0, 2],
				], at: Position(x: 2, y: 2))
			
			Level.robot.position = Position(x: 0 + 2, y: 2 + 2)
			Level.robot.direction = .north
			
			
			for x in 0...2 {
				Level.world.items.append(Item(type: .diamond,
				                              position: Position(x: x + 2, y: 4 + 2)))
				Level.world.items.append(Item(type: .diamond,
				                              position: Position(x: x + 2, y: 0 + 2)))
			}
			Level.world.items.append(Item(type: .start(direction: Level.robot.direction),
			                              position: Level.robot.position))
			
			Level.world.repaint()
		}
		
		/// use function composition
		static func level7() {
			World.setup()
			
			Level.robot.position = Position(x: 4, y: 4)
			Level.robot.direction = .east
			
			
			for y in 0...4 where y != 2 {
				Level.world.items.append(Item(type: .switch(highlighted: false),
				                              position: Position(x: 4, y: y * 2)))
			}
			
			Level.world.items += [
				
				Item(type: .start(direction: Level.robot.direction), position: Level.robot.position),
				
				Item(type: .switch(highlighted: false), position: Position(x: 2, y: 4)),
				Item(type: .switch(highlighted: false), position: Position(x: 6, y: 4))

			]
			
			Level.world.repaint()
		}
		
	}
	
	/// for each seed do something
	/// für jeden Samen mache: mache Loch, setzte Samen, gehe 15 cm nach vorne
	/**
	
	for eachSeed in 1...4 {
		makeHole()
		placeSeed()
		move5cmForward()
	}
	
	*/
	/// TODO: copy code
	/**
	
	for i in 1...number {
		// code
	}
	
	*/
	/// (for) loops - repeating yourself
	enum Chapter3 {
		
		/// use for loops
		static func level1() {
			World.setup()
			
			let portalColors = [
				Color(red: 0, green: 0, blue: 1, alpha: 1),
				Color(red: 0, green: 1, blue: 0, alpha: 1),
				Color(red: 1, green: 0, blue: 1, alpha: 1),
				Color(red: 1, green: 1, blue: 0, alpha: 1)
			]
			
			Level.robot.position = Position(x: 1, y: 1)
			Level.robot.direction = .north
			
			
			for x in 0...4 {
				if portalColors.indices.contains(x) {
					let color = portalColors[x]
					Level.world.items.append(Item(type: .portal(color: color),
					                              position: Position(x: 1 + x, y: 1 + 3)))
					Level.world.items.append(Item(type: .portal(color: color),
					                              position: Position(x: 1 + x + 1, y: 1 + 0)))
				}
				
				Level.world.items.append(Item(type: .diamond,
				                              position: Position(x: 1 + x, y: 1 + 2)))
				if x % 2 == 0 {
					for y in 0...1 {
						Level.world.halfBlocks[1 + x][1 + y] = 1
					}
					for y in 2...3 {
						Level.world.halfBlocks[1 + x][1 + y] = 2
					}
				}
			}
			
			Level.world.items.append(Item(type: .start(direction: Level.robot.direction),
			                              position: Level.robot.position))
			
			Level.world.repaint()
		}
		
		/// find the pattern
		static func level2() {
			World.setup()
			
			
			Level.world.setBlockArray([
				[2, 2, 2, 2, 2],
				[2, 0, 0, 0, 2],
				[2, 0, 0, 0, 2],
				[2, 0, 0, 0, 2],
				[2, 2, 2, 2, 2],
				], at: Position(x: 1, y: 1))
			
			Level.robot.position = Position(x: 1, y: 1)
			Level.robot.direction = .north
			
			Level.world.items = [
				Item(type: .start(direction: Level.robot.direction), position: Level.robot.position),
				
				Item(type: .diamond, position: Position(x: 0 + 1, y: 1 + 1)),
				Item(type: .diamond, position: Position(x: 1 + 1, y: 4 + 1)),
				Item(type: .diamond, position: Position(x: 4 + 1, y: 3 + 1)),
				Item(type: .diamond, position: Position(x: 3 + 1, y: 0 + 1))

			]
			
			Level.world.repaint()
		}
		
		/// find the pattern
		static func level3() {
			World.setup()
			
			Level.robot.position = Position(x: 2, y: 2)
			Level.robot.direction = .south
			
			Level.world.items = [
				Item(type: .start(direction: Level.robot.direction), position: Level.robot.position),
				
				Item(type: .diamond, position: Position(x: -2 + 2, y: +0 + 2)),
				Item(type: .diamond, position: Position(x: +2 + 2, y: +0 + 2)),
				Item(type: .diamond, position: Position(x: +0 + 2, y: -2 + 2)),
				Item(type: .diamond, position: Position(x: +0 + 2, y: +2 + 2))
				
			]
			
			Level.world.repaint()
		}
		
		/// find the pattern
		static func level4() {
			World.setup()
			
			for x in 0...2 {
				Level.world.halfBlocks[x * 2][0] = 1
				for y in 1...7 {
					Level.world.halfBlocks[x * 2][y] = 2
				}
				Level.world.items.append(Item(type: .switch(highlighted: false),
				                              position: Position(x: x * 2, y: 7)))
			}
			
			Level.robot.position = Position(x: 6, y: 0)
			Level.robot.direction = .west
			
			Level.world.items.append(Item(type: .start(direction: Level.robot.direction),
			                              position: Level.robot.position))
			
			Level.world.repaint()
		}
		
		/// find the pattern
		static func level5() {
			World.setup()
			
			for y in 0...2 {
				for x in 0...1 {
					Level.world.items.append(Item(type: .switch(highlighted: false),
					                              position: Position(x: x, y: y)))
				}
			}
			for y in 0...4 {
				for x in 3...4 {
					Level.world.items.append(Item(type: .diamond,
					                              position: Position(x: x, y: y)))
				}
			}
			
			Level.robot.position = Position(x: 2, y: 0)
			Level.robot.direction = .north
			
			Level.world.items.append(Item(type: .start(direction: Level.robot.direction),
			                              position: Level.robot.position))
			
			Level.world.repaint()
		}
	}
	
	/**
	
	if isLightGreen {
		moveForward()
	}
	
	if isLightGreen {
		moveForward()
	} else {
		wait()
	}
	
	*/
	/// new commands: isOnClosedSwitch
	///
	/// conditional code (if) - Attention RANDOM
	enum Chapter4 {
		
		/// random switches
		static func level1() {
			World.setup()
			
			for x in 4...6 {
				let open = arc4random() % 2 == 0
				Level.world.items.append(Item(type: .switch(highlighted: open),
					                              position: Position(x: x, y: 5)))
			}
			
			Level.robot.position = Position(x: 2, y: 5)
			Level.robot.direction = .east
			
			Level.world.items.append(Item(type: .start(direction: Level.robot.direction),
			                              position: Level.robot.position))
			
			Level.world.repaint()
		}
		
		/// random items
		static func level2() {
			World.setup()
			
			for x in 2...9 {
				if arc4random() % 2 == 0 {
					Level.world.items.append(Item(type: .switch(highlighted: false),
					                              position: Position(x: x, y: 5)))
				} else {
					Level.world.items.append(Item(type: .diamond,
					                              position: Position(x: x, y: 5)))
				}
			}
			
			Level.robot.position = Position(x: 1, y: 5)
			Level.robot.direction = .east
			
			Level.world.items.append(Item(type: .start(direction: Level.robot.direction),
			                              position: Level.robot.position))
			
			Level.world.repaint()
		}
		
		/// items in corner
		static func level3() {
			World.setup()
			
			Level.world.setBlockArray([
				[0, 4, 4, 3],
				[0, 4, 0, 3],
				[0, 5, 0, 2],
				[0, 6, 0, 2],
				[0, 0, 1, 1],
				], at: Position(x: 1, y: 1))
			
			Level.robot.position = Position(x: 1, y: 1)
			Level.robot.direction = .east
			
			Level.world.items = [
				Item(type: .start(direction: Level.robot.direction), position: Level.robot.position),
				
				Item(type: .diamond, position: Position(x: 3 + 1, y: 0 + 1)),
				Item(type: .diamond, position: Position(x: 3 + 1, y: 4 + 1)),
				Item(type: .diamond, position: Position(x: 1 + 1, y: 4 + 1)),
				Item(type: .diamond, position: Position(x: 1 + 1, y: 1 + 1))
				
			]
			
			Level.world.repaint()
		}
		
		/// items in corner
		static func level4() {
			World.setup()
			
			Level.world.setBlockArray([
				[2, 2, 2],
				[2, 2, 2],
				[2, 2, 2]
				], at: Position(x: 1, y: 1))
			
			for x in 1...3 {
				for y in 1...3 where x != 0 && y != 0 {
					if arc4random() % 2 == 0 {
						Level.world.items.append(Item(type: .diamond,
						                              position: Position(x: x, y: y)))
					} else {
						Level.world.items.append(Item(type: .switch(highlighted: false),
						                              position: Position(x: x, y: y)))
					}
				}
			}
			
			Level.robot.position = Position(x: 1 + 1, y: 1 + 1)
			Level.robot.direction = .east
			
			Level.world.items += [
				Item(type: .start(direction: Level.robot.direction), position: Level.robot.position)
				
			]
			
			Level.world.repaint()
		}
	}
	
	///
	/// logical operators
	enum Chapter5 {
		
		static func level1() {
			World.setup()
			
			Level.world.setBlockArray([
				[2],
				[2],
				[2],
				[2],
				[2]
				], at: Position(x: 1, y: 1))
			
			for y in 2...5 {
				Level.world.items.append(Item(type: .diamond,
				                              position: Position(x: 1, y: y)))
			}
			
			let y = Int(arc4random() % 4)
			Level.world.items.append(Item(type: .diamond,
			                              position: Position(x: 2, y: y + 2)))
			Level.world.halfBlocks[2][y + 2] = 2
			
			Level.robot.position = Position(x: 1, y: 1)
			Level.robot.direction = .north
			
			Level.world.items += [
				Item(type: .start(direction: Level.robot.direction), position: Level.robot.position)
				
			]
			
			Level.world.repaint()
		}
		
		/// spiral
		static func level2() {
			World.setup()
			
			Level.world.setBlockArray([
				[2, 0, 0, 0, 0],
				[2, 0, 2, 2, 2],
				[2, 0, 2, 0, 2],
				[2, 0, 0, 0, 2],
				[2, 2, 2, 2, 2],
				], at: Position(x: 0, y: 0))
			
			Level.robot.position = Position(x: 0, y: 4)
			Level.robot.direction = .south
			
			Level.world.items += [
				Item(type: .start(direction: Level.robot.direction), position: Level.robot.position),
				
				Item(type: .diamond, position: Position(x: 2, y: 2))
			]
			
			Level.world.repaint()
		}
	}
	
}
