//
//  TouchSet+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 17/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation


extension TouchSet{
    
    @objc var totalTouches: Double { return actual }
    @objc var totalTouchKG: Double { return actual * actualKG }
    @objc var avTouch: Double { return actual }
    @objc var minTouch: Double { return actual }
    @objc var maxTouch: Double { return actual }
    
    override var percentageComplete: Double{
        if actual <= plan{
            return 1
        }else{
            // ND plan-actual is -ve. So this is asymptotic to 0 with max of 1 when plan == actual
            return exp(0.25 * Double(plan - actual))
        }
    }
    
    override func setCompleted() -> Bool {
        return actual <= plan && actualKG >= plannedKG
    }
    
    override func summary() -> String {
        var str: String = ""
        if actual >= 0{
            str += "\(Int(actual)) touches"
        }else{
            str += "Not started"
        }
        str += " (\(partOfTest() ? "Goal:" : "Plan:") \(Int(plan)) touches)"
        return str
    }
    
}
