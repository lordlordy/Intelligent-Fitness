//
//  DistanceSet.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 17/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension DistanceSet{
    
    @objc var totalDistance: Double { return actual }
    @objc var totalDistanceKG: Double { return actual * actualKG }
    @objc var avDistance: Double { return actual }
    @objc var minDistance: Double { return actual }
    @objc var maxDistance: Double { return actual }
    
    override func summary() -> String {
        var str: String = ""
        if actual >= 0{
            str += "\(actual)m"
            if actualKG > 0{
                str += " with \(actualKG) kg"
            }
        }else{
            str += "Not started"
        }
        str += " (\(partOfTest() ? "Goal:" : "Plan:") "
        str += String(format: "%.2fm", plan)
        if plannedKG > 0{
            str += " with \(plannedKG)kg"
        }
        str += ")"
        return str
    }
    
}
