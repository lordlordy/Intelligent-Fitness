//
//  Interval+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 10/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension Interval{
    
    override func setCompleted() -> Bool {
        return actualSeconds >= plannedSeconds
    }
    
    override func set(planned: Double) {
        plannedSeconds = Int16(planned)
    }

    override func set(actual: Double) {
        actualSeconds = Int16(actual)
    }
    
    override func getPlanned() -> Double { return Double(plannedSeconds) }
    override func getActual() -> Double { return Double(actualSeconds)}

    override func partOfTest() -> Bool {
        return exerciseInterval?.isTest ?? false
    }
    
    override func set(exercise: Exercise){
        if let i = exercise as? ExerciseInterval{
            self.exerciseInterval = i
        }
    }

    
    override func summary() -> String {
        var str: String = ""
        if actualSeconds >= 0{
            str += " \(actualSeconds)s"
            if actualKG > 0{
                str += " with \(actualKG) kg"
            }
        }else{
            str += " not started"
        }
        
        str += " (\(partOfTest() ? "Goal:" : "Plan:") \(plannedSeconds)s"
        if plannedKG > 0{
            str += " with \(plannedKG)kg"
        }
        str += ")"
        
        return str
    }
}
