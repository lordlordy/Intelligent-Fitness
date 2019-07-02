//
//  ExerciseSet+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 29/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension ExerciseSet{
    
    func numberOfSets() -> Int{
        return exercises?.count ?? 0
    }
    
    func exercise(atOrder order: Int16) -> Exercise?{
        for exercise in exercises!{
            if let e = exercise as? Exercise{
                if e.order == order{
                    return e
                }
            }
        }
        return nil
    }
    
    func allExercisesCompleted() -> Bool{
        for e in orderedExerciseArray(){
            if !e.exerciseComplete(){
                return false
            }
        }
        return true
    }
    
    func finished() -> Bool{
        return endedSetEarly || allExercisesCompleted()
    }
    
    func orderedExerciseArray() -> [Exercise]{
        var array: [Exercise] = exercises?.allObjects as? [Exercise] ?? []
        array.sort(by: {$0.order < $1.order})
        return array
    }
}
