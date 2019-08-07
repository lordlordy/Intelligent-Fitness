//
//  HRVDataPoint.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 07/08/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation



struct HRVDataPoint{
    
    static let hrvOffPercentile: Double = 0.03
    static let hrvEasyPercentile: Double = 0.25
    static let hrvHardPercentile: Double = 0.75
    
    static func thresholdSDs() -> (off: Double, easy: Double, hard: Double){
        let maths: Maths = Maths()
        return (maths.normalCDFInverse(hrvOffPercentile), maths.normalCDFInverse(hrvEasyPercentile), maths.normalCDFInverse(hrvHardPercentile))
    }
    
    
    var date: Date
    var sdnn: Double
    var offValue: Double
    var easyValue: Double
    var hardValue: Double
    
    var goHard: Bool{ return sdnn > hardValue}
    var dayOff: Bool{ return sdnn < offValue}
    var goEasy: Bool{ return sdnn < easyValue}
    
}
