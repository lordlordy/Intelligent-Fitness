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

    override func summary() -> String {
        var str: String = exerciseInterval?.exerciseType()?.name() ?? ""
        if actualSeconds >= 0{
            str += " \(actualSeconds) seconds"
            if actualKG > 0{
                str += " with \(actualKG) kg"
            }
        }else{
            str += " not started"
        }
        return str
    }
}
