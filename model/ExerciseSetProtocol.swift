//
//  ExerciseSetProtocol.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 10/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

@objc protocol ExerciseSetProtocol {
    func setCompleted() -> Bool
    func set(planned: Double)
    func set(actual: Double)
    func getPlanned() -> Double
    func getActual() -> Double
    func summary() -> String
}
