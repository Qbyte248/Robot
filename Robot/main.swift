//
//  main.swift
//  Robot

import Foundation

print("Hello, World!")

// Test 2

func moveForward() {
	Level.robot.moveForward()
}
func placeBlockInFront() {
	Level.robot.placeBlockInFront()
}
func placeBlockBelow() {
	Level.robot.placeBlockBelow()
}
func turnLeft() {
	Level.robot.turnLeft()
}
func collectDiamond() {
	Level.robot.collectDiamond()
}
func toggleSwitch() {
	Level.robot.toggleSwitch()
}
var isOnClosedSwitch: Bool {
	return Level.robot.isOnClosedSwitch
}
var isOnDiamond: Bool {
	return Level.robot.isOnDiamond
}
var isBlocked: Bool {
	return Level.robot.isBlocked
}


World.Chapter5.level3()

World.end(fps: 10)
