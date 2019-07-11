//
//  ExerciseProtocol.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 10/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

@objc protocol ExerciseProtocol {
    func exerciseCompleted() -> Bool
    func exerciseFinished() -> Bool
    // returns whether successfully added. It's possible that the wrong subclass of ExeciseSet is passed - it will not fail it will just not add it
    func add(exerciseSet set: ExerciseSet) -> Bool
    func exerciseSet(atOrder order: Int16) -> ExerciseSet?
    func numberOfSets() -> Int
    func summary() -> String
}
