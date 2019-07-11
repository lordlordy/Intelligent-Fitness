//
//  Reps+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 10/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension Reps{
    
    override func setCompleted() -> Bool {
        return actualReps >= plannedReps
    }
    
    override func set(planned: Double) {
        plannedReps = Int16(planned)
    }

    override func set(actual: Double) {
        actualReps = Int16(actual)
    }
    
    override func getPlanned() -> Double { return Double(plannedReps) }
    override func getActual() -> Double { return Double(actualReps)}

    override func partOfTest() -> Bool {
        return exerciseReps?.isTest ?? false
    }
    
    override func set(exercise: Exercise){
        if let r = exercise as? ExerciseReps{
            self.exerciseReps = r
        }
    }

    
    override func summary() -> String {
        var str: String = ""
        let repStr: String = exerciseReps?.exerciseType()?.repString() ?? "reps"
        if actualReps >= 0{
            str += " \(actualReps)"
            if actualKG > 0{
                str += " x \(actualKG) kg"
            }else{
                str += " \(repStr)"
            }
        }else{
            str += " not started"
        }
                
        str += " (\(partOfTest() ? "Goal:" : "Plan:") \(plannedReps)"
        if plannedKG > 0{
            str += " x \(plannedKG)kg"
        }
        str += ")"
        
        return str
    }
}
