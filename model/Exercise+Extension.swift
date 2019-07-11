//
//  Exercise+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 02/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension Exercise{
    
    func numberOfSets() -> Int{
        return sets?.count ?? 0
    }
    
    func exerciseSet(atOrder order: Int16) -> ExerciseSet?{
        for set in exerciseSets(){
            if set.order == order{
                return set
            }
        }
        return nil

    }
    
    func exerciseType() -> ExerciseType{
        return ExerciseType(rawValue: type)!
    }
    
    func exerciseDefinition() -> ExerciseDefinition{
        return ExerciseDefinitionManager.shared.exerciseDefinition(for: exerciseType())
    }
    
    func exerciseFinished() -> Bool {
        return endedEarly || exerciseCompleted()
    }

    func exerciseCompleted() -> Bool {
        for r in exerciseSets(){
            if !r.setCompleted(){
                return false
            }
        }
        return true
    }
    
    func summary() -> String{
        if numberOfSets() == 1{
            return "\(exerciseDefinition().name): \(exerciseSet(atOrder: 0)?.summary() ?? "no summary")"
        }
        return "Summary of exercise still to be written"
    }
    
    private func exerciseSets() -> [ExerciseSet]{
        return sets?.allObjects as? [ExerciseSet] ?? []
    }

}
