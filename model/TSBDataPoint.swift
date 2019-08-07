//
//  TSBDataPoint.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 07/08/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

struct TSBDataPoint{
    // TO DO - allow these to be changed. Ultimately allow them to be deduced from test data
    // standard 42 day fitness decay.
    static let ctlFactor: Double = exp(-1/42.0)
    // standard 7 day fatigue decay
    static let atlFactor: Double = exp(-1/7.0)
    
    var date: Date
    var tss: Double
    var atl: Double
    var ctl: Double
    var tsb: Double{ return ctl - atl}
    
    
}
