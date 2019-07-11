//
//  Exercise+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 02/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension Exercise: ExerciseProtocol{
    //Exercise is abstract so subclasses should override these methods
    
    func exerciseFinished() -> Bool {
        return false
    }
    
    func exerciseCompleted() -> Bool {
        return false
    }
    
    func add(exerciseSet set: ExerciseSet) -> Bool {
        return false
    }
    
    func exerciseSet(atOrder order: Int16) -> ExerciseSet? {
        return nil
    }
    
    func numberOfSets() -> Int{
        return 0
    }
    
    func exerciseType() -> ExerciseType?{
        return ExerciseType(rawValue: type)
    }
    
    func summary() -> String{
        if numberOfSets() == 1{
            return "\(exerciseType()?.name() ?? "type not set"): \(exerciseSet(atOrder: 0)?.summary() ?? "no summary")"
        }
        return "Summary of exercise still to be written"
    }

}
