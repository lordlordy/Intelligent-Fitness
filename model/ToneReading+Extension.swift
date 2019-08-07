//
//  ToneReading+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 06/08/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension ToneReading{
    
    private var df: DateFormatter{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yy"
        return formatter
    }
    
    private var nf: NumberFormatter{
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }
    
    func summaryString() -> String{
        return "\(df.string(from: date!)): \(nf.string(from: NSNumber(value: score))!)"
    }
    
    
}
