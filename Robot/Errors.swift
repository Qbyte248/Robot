//
//  Errors.swift
//  Swift 3 TestProject
//
//  Created by Maximilian Hünenberger on 16.7.16.
//
//

struct NullPointerException: Error {
	var message: String
	init(_ message: String) {
		self.message = message
	}
}
struct IllegalArgumentException: Error {
	var message: String
	init(_ message: String) {
		self.message = message
	}
}

struct IOException: Error {
	var message: String
	init(_ message: String) {
		self.message = message
	}
}

import Foundation

public enum Object {
	case string(String)
	case array([Object])
	case dictionary([String : Object])
}

extension Array {
	func get(_ index: Int) -> Element {
		return self[index]
	}
	mutating func add(_ element: Element) {
		self.append(element)
	}
}

extension Dictionary {
	func get(_ key: Key) -> Value! {
		return self[key]
	}
	mutating func put(_ key: Key, _ value: Value) {
		self[key] = value
	}
}

extension String {
	func equals(_ string: String) -> Bool {
		return self == string
	}
	func length() -> Int {
		return self.characters.count
	}
	func substring(_ from: Int, _ to: Int) -> String {
		let fromIndex = index(startIndex, offsetBy: from)
		return self.substring(with: fromIndex ..< index(fromIndex, offsetBy: to - from))
	}
	func startsWith(_ string: String, _ offset: Int) -> Bool {
		return self.substring(from: index(startIndex, offsetBy: offset)).hasPrefix(string)
	}
}

enum System {
	enum out {
		static func println(_ any: Any) {
			print(any)
		}
	}
}
