//
//  Date+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 16/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension Date{
    
    var cal: Calendar{
        return Calendar(identifier: .iso8601)
    }
    
    var startOfWeek: Date{
        return cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    }
    
    var endOfWeek: Date{
        return cal.date(byAdding: DateComponents(day: 6), to: startOfWeek)!
    }
    
    var weekOfYear: Int {
        return cal.dateComponents([.weekOfYear], from: self).weekOfYear!
    }
    
    var year: Int {
        return cal.dateComponents([.yearForWeekOfYear], from: self).yearForWeekOfYear!
    }
    
    var dayOfWeek: Int {
        return (cal.dateComponents([.weekday], from: self).weekday! + 5) % 7 + 1
    }
    
    var tomorrow: Date{
        return cal.date(byAdding: DateComponents(day:1), to: self)!
    }

    var yesterday: Date{
        return cal.date(byAdding: DateComponents(day:-1), to: self)!
    }
    
}
