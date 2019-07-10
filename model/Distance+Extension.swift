//
//  Distance+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 10/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension Distance{
    
    override func setCompleted() -> Bool {
        return actualMetres >= plannedMetres
    }
    
    override func set(actual: Double) {
        actualMetres = actual
    }
    
    override func set(planned: Double) {
        plannedMetres = planned
    }
    
    override func getPlanned() -> Double { return plannedMetres }
    override func getActual() -> Double { return actualMetres}
    
    override func summary() -> String {
        var str: String = exerciseDistance?.exerciseType()?.name() ?? ""
        if actualMetres >= 0{
            str += " \(actualMetres) metres"
            if actualKG > 0{
                str += " with \(actualKG) kg"
            }
        }else{
            str += " not started"
        }
        return str
    }
}
