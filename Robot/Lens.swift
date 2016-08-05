//
//  Helper.swift
//  Swift 3 TestProject
//
//  Created by Maximilian Hünenberger on 3.8.16.
//
//

import Foundation

func lens<T>(_ value: T, closure: (inout T) -> ()) -> T {
	var value = value
	closure(&value)
	return value
}
