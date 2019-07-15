//
//  Session+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 29/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension Workout{
    
    var totalKG: Double{ return orderedExerciseArray().reduce(0.0, {$0 + $1.totalActualKG})}
    var totalReps: Double { return orderedExerciseArray().reduce(0.0, {$0 + $1.totalActual(forSetType: .Reps)})}
    var totalTime: Double { return orderedExerciseArray().reduce(0.0, {$0 + $1.totalActual(forSetType: .Time)})}
    var totalDistance: Double { return orderedExerciseArray().reduce(0.0, {$0 + $1.totalActual(forSetType: .Distance)})}
    var totalTouches: Double { return orderedExerciseArray().reduce(0.0, {$0 + $1.totalActual(forSetType: .Touches)})}

    var percentageComplete: Double{
        get{
            if orderedExerciseArray().count > 0{
                // note the minimum. This ensures that a score of great that 100% for a given test element does not contribute more the 100% to overall test result
                return orderedExerciseArray().reduce(0, {$0 + min(1,$1.percentageComplete)}) / Double(orderedExerciseArray().count)
            }else{
                return 1.0
            }
        }
    }
    
    func summary() -> String{
        if complete{
            return createWorkoutSummary()
        }else{
            if isTest{
                return "Next test"
            }else{
                return "Next workout"
            }
        }
    }
    
    
    func numberOfExercises() -> Int{
        return exercises?.count ?? 0
    }
    

    
    func exercises(ofType type: ExerciseType) -> [Exercise]{
        return orderedExerciseArray().filter({$0.type == type.rawValue})
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
    
    private func createWorkoutSummary() -> String{
        var strParts: [String] = []
        let f: NumberFormatter = NumberFormatter()
        f.numberStyle = .percent
        if let s = f.string(from: NSNumber(value: percentageComplete)){
            strParts.append(s)
        }
        if totalKG > 0 { strParts.append("\(Int(totalKG))kg") }
        if totalReps > 0 { strParts.append(SetType.Reps.string(forValue: totalReps)) }
        if totalTime > 0 { strParts.append(SetType.Time.string(forValue: totalTime)) }
        if totalTouches > 0 { strParts.append(SetType.Touches.string(forValue: totalTouches)) }

        return "Completed: " + strParts.joined(separator: " / ")
        
    }
}
