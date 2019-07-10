//
//  ExerciseDistance+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 10/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension ExerciseDistance{
    
    override func exerciseFinished() -> Bool {
        return endedEarly || exerciseCompleted()
    }
    
    override func exerciseCompleted() -> Bool {
        for r in sets(){
            if !r.setCompleted(){
                return false
            }
        }
        return true
    }
    
    override func add(exerciseSet set: ExerciseSet) -> Bool {
        if let d = set as? Distance{
            addToDistances(d)
            return true
        }
        return false
    }
    
    override func exerciseSet(atOrder order: Int16) -> ExerciseSet?{
        for set in sets(){
            if set.order == order{
                return set
            }
        }
        return nil
    }
    
    override func numberOfSets() -> Int{
        return sets().count
    }
    
    private func sets() -> [Distance]{
        return distances?.allObjects as? [Distance] ?? []
    }
    
    
}
