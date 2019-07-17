//
//  Date+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 16/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension Date{
    
    var startOfWeek: Date?{
        return Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([Calendar.Component.yearForWeekOfYear, Calendar.Component.weekOfYear], from: self))
    }
    
}
