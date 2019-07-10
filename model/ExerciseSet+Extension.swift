//
//  ExerciseSet+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 29/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension ExerciseSet: ExerciseSetProtocol{
    // ExerciseSet is abstract in Core Data... these functions will need overriding in subclasses
    func setCompleted() -> Bool{ return false }
    func set(planned: Double) {
        // do nothing here
    }
    func set(actual: Double) {
        // do nothing here
    }
    
    func getPlanned() -> Double { return 0.0 }
    func getActual() -> Double { return 0.0 }
    
    func summary() -> String{
        return "Shouldn't see this as subclass should have overridden"
    }

}
