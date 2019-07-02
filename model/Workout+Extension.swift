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
    
    func numberOfExerciseSets() -> Int{
        return exerciseSets?.count ?? 0
    }
    
    func exerciseSet(atOrder order: Int16) -> ExerciseSet?{
        for exerciseSet in exerciseSets!{
            if let es = exerciseSet as? ExerciseSet{
                if es.order == order{
                    return es
                }
            }
        }
        return nil
    }
    
    func workoutCompleted() -> Bool{
        for es in orderedExerciseSetArray(){
            if !es.allExercisesCompleted(){
                return false
            }
        }
        return true
    }

    //this means workout is done but that may be because it was finished incomplete.
    func workoutFinished() -> Bool{
        for es in orderedExerciseSetArray(){
            if !es.finished(){
                return false
            }
        }
        return true
    }
    
    //return nil if workout completed
    func currentSet() -> Int16?{
        for es in orderedExerciseSetArray(){
            if !es.finished(){
                return es.order
            }
        }
        return nil
    }
    
    func orderedExerciseSetArray() -> [ExerciseSet]{
        var array: [ExerciseSet] = exerciseSets?.allObjects as? [ExerciseSet] ?? []
        array.sort(by: {$0.order < $1.order})
        return array
    }
    
}
