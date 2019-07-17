//
//  RepSet+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 17/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension RepSet{
    
    override var totalKG: Double{ return actual * actualKG }
    @objc var totalReps: Double { return actual }
    @objc var totalRepKG: Double { return actual * actualKG}
    @objc var avReps: Double { return actual }
    @objc var minReps: Double { return actual }
    @objc var maxReps: Double { return actual }
    
    override func summary() -> String {
        var str: String = ""
        if actual >= 0{
            str += "\(Int(actual))"
            if actualKG > 0{
                str += " x \(Int(actualKG)) kg"
            }else{
                str += " reps"
            }
        }else{
            str += "Not started"
        }
        str += " (\(partOfTest() ? "Goal:" : "Plan:") \(Int(plan))"
        if plannedKG > 0{
            str += " x \(plannedKG)kg"
        }else{
            str += " reps"
        }
        str += ")"
        return str
    }
    
}
