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

    override func summary() -> String {
        var str: String = exerciseReps?.exerciseType()?.name() ?? ""
        if actualReps >= 0{
            str += " \(actualReps) reps"
            if actualKG > 0{
                str += " with \(actualKG) kg"
            }
        }else{
            str += " not started"
        }
        return str
    }
}
