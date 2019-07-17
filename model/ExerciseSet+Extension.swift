//
//  ExerciseSet+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 29/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension ExerciseSet{
  
    var totalActualKG: Double {
        get{
            if exercise?.exerciseDefinition.setType == SetType.Reps{
                return actual * actualKG
            }
            return actualKG
        }
    }
    
    var totalPlanKG: Double{
        get{
            if exercise?.exerciseDefinition.setType == SetType.Reps{
                return plan * plannedKG
            }
            return plannedKG
        }
    }
    
    var percentageComplete: Double{
        get{
            if exercise?.exerciseDefinition.setType.moreIsBetter() ?? true{
                if plan > 0{
                    // This is to deal with non weight exercises
                    return (actual * max(1.0, actualKG)) / ( plan * max(1.0, plannedKG))
                }else{
                    return 0
                }
            }else{
                // so aiming for fewer reps than plan
                let diff: Double = plan - actual
                let absDiff: Double = abs(diff)
                if diff >= 0{
                    return (diff + plan) / plan
                }else{
                    return plan / (absDiff + plan)
                }
            }
        }
    }
    
    
    func setCompleted() -> Bool {
        return actual >= plan
    }
    
    func summary() -> String {
        if let type = exercise?.exerciseDefinition.setType{
            switch type{
            case .Distance: return distanceDescription()
            case .Reps: return repsDescription()
            case .Time: return timeDescription()
            case .Touches: return touchesDescription()
            case .All: return "This is the summary for ALL exercises"
            }
        }else{
            return "No type set"
        }
        
    }
    
    func partOfTest() -> Bool{
        return exercise?.isTest ?? false
    }
    
    private func distanceDescription() -> String{
        var str: String = ""
        if actual >= 0{
            str += "\(actual)m"
            if actualKG > 0{
                str += " with \(actualKG) kg"
            }
        }else{
            str += "Not started"
        }
        str += " (\(partOfTest() ? "Goal:" : "Plan:") \(plan)"
        if plannedKG > 0{
            str += " with \(plannedKG)kg"
        }
        str += ")"
        
        return str
    }
    
    private func repsDescription() -> String{
        var str: String = ""
        if actual >= 0{
            str += "\(Int(actual))"
            if actualKG > 0{
                str += " x \(actualKG) kg"
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
    
    private func timeDescription() -> String{
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
    
    private func touchesDescription() -> String{
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
