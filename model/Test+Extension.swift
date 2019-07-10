//
//  Test+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 04/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension Test{
    
    func testType() -> TestType{
        if let n = name{
            if let tt = TestType(rawValue: n){
                return tt
            }
        }
        return TestType(rawValue: TestType.UNKNOWN)!
    }
    
    func mostRecentResult() -> Double?{
        if let r = CoreDataStackSingleton.shared.getMostRecentTest(ofType: testType()){
            return r.result
        }
        return nil
    }
    
    
    func resultString() -> String{
        if result < 0{
            return ""
        }else{
            var r: String = ""
            if let n = name{ r += n }
            r += ": \(result)"
            if let unit = resultUnit{ r += " \(unit)" }
            if kg > 0{
                r += " with \(kg) kg"
            }
            return r
        }
    }
    
    func description() -> String{
        switch testType(){
        case .DeadHang:
            return "Hang from a bar from both hands. Hands should be shoulder width apart. Goal is to hold for \(String(Int(goalResult))) \(resultUnit ?? "")"
        case .FarmersCarry:
            return "See how far you can carry \(String(kg))kg split between two dumbbells one in each hand. Goal is to carry \(String(Int(goalResult))) \(resultUnit ?? "")"
        case .Plank:
            return "Hold plank position with body parallel to the ground . Goal is to hold for \(String(Int(goalResult))) \(resultUnit ?? "")"
        case .SittingRisingTest:
            return "From a standing position sit down and then get back up without losing your balance and trying not to use your hands or knees. Count how many times you use a hand, knee or place a hand on your knee"
        case .Squat:
            return "Hold squat position with thighs parallel to the ground. Goal is to hold for \(String(Int(goalResult))) \(resultUnit ?? "")"
        case .StandingBroadJump:
            return "Starting with both feet next to each other see how far you can jump landing on two feet and not losing balance. Goal is to jump  \(String(Int(goalResult))) \(resultUnit ?? "")"
        case .Unknown: return ""
        }
    }
    
}
