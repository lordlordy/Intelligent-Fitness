//
//  Session+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 29/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension Workout{
    
    func summary() -> String{
        return "This is a session summary"
    }
    
    func numberOfExercises() -> Int{
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
    
    func workoutType() -> WorkoutType?{
        return WorkoutType(rawValue: type)
    }
    
    func workoutCompleted() -> Bool{
        for e in orderedExerciseArray(){
            if !e.exerciseCompleted(){
                return false
            }
        }
        return true
    }

    //this means workout is done but that may be because it was finished incomplete.
    func workoutFinished() -> Bool{
        for e in orderedExerciseArray(){
            if !e.exerciseFinished(){
                return false
            }
        }
        return true
//        return false
    }
    
    //return nil if workout completed
    func currentSet() -> Int16?{
        for e in orderedExerciseArray(){
            if !e.exerciseFinished(){
                return e.order
            }
        }
        return nil
    }
    
    func orderedExerciseArray() -> [Exercise]{
        var array: [Exercise] = exercises?.allObjects as? [Exercise] ?? []
        array.sort(by: {$0.order < $1.order})
        return array
    }
    
}
