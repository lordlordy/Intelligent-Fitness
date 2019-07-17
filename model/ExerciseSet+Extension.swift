//
//  ExerciseSet+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 29/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension ExerciseSet{
  
    @objc var totalKG: Double {return actualKG}
    @objc var maxKG: Double { return actualKG }
    @objc var minKG: Double { return actualKG}
    @objc var avKG: Double { return actualKG }
    
    @objc var percentageComplete: Double{
        if plan > 0{
            if plannedKG == 0.0{
                return actual / plan
            }else{
                // does not reward doing more weight than planned
                return (actual * min(actualKG, plannedKG)) / ( plan * plannedKG)
            }
        }else{
            return 1
        }
    }
    
    @objc func setCompleted() -> Bool {
        return actual >= plan && actualKG >= plannedKG
    }
    
    @objc func summary() -> String { return "This is the summary for ALL exercises" }
    
    func partOfTest() -> Bool{
        return exercise?.isTest ?? false
    }
    
    func getValue(forMeasure measure: ExerciseMeasure) -> Double{
        let v = value(forKey: measure.rawValue) as? Double ?? 0.0
        return v
    }
    
    public override func value(forUndefinedKey key: String) -> Any? {
        return 0.0
    }

    
}
