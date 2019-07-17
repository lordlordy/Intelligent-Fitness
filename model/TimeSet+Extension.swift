//
//  TimeSet.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 17/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension TimeSet{
    
    @objc var totalTime: Double { return actual }
    @objc var totalTimeKG: Double { return actual * actualKG }
    @objc var avTime: Double { return actual }
    @objc var minTime: Double { return actual }
    @objc var maxTime: Double { return actual }
    
    override func summary() -> String {
        var str: String = ""
        if actual >= 0{
            str += "\(Int(actual))s"
            if actualKG > 0{
                str += " with \(actualKG) kg"
            }
        }else{
            str += "Not started"
        }
        str += " (\(partOfTest() ? "Goal:" : "Plan:") \(Int(plan))s"
        if plannedKG > 0{
            str += " with \(plannedKG)kg"
        }
        str += ")"
        return str
    }
    
}
