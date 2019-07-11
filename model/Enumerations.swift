//
//  Enumerations.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 03/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

enum Unit: String{
    case seconds = "Seconds"
    case kg = "kg"
}
//
//enum TestType: String{
//    
//    static let UNKNOWN: String = "Unknown"
//    
//    case StandingBroadJump = "Standing Broad Jump"
//    case Plank = "Plank"
//    case DeadHang = "Dead Hang"
//    case FarmersCarry = "Farmers Carry"
//    case Squat = "Squat"
//    case SittingRisingTest = "Sitting Rising Test"
//    case Unknown = "Unknown"
//    
//    func defaultGoal() -> Double{
//        switch self {
//        case .DeadHang:             return 30
//        case .FarmersCarry:         return 100
//        case .Plank:                return 30
//        case .SittingRisingTest:    return 0
//        case .Squat:                return 30
//        case .StandingBroadJump:    return 100
//        case .Unknown:              return 0
//        }
//    }
//    
//    func isTimed() -> Bool{
//        switch self{
//        case .DeadHang, .Plank, .Squat: return true
//        default: return false
//        }
//    }
//    
//    func hasKG() -> Bool{
//        switch self{
//        case .FarmersCarry: return true
//        default: return false
//        }
//    }
//    
//}
