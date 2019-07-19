//
//  Date+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 16/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension Date{
    
    var startOfWeek: Date{
        return Calendar.current.date(from: Calendar.current.dateComponents([Calendar.Component.yearForWeekOfYear, Calendar.Component.weekOfYear], from: self))!
    }
    
    var endOfWeek: Date{
        return Calendar.current.date(byAdding: DateComponents(day: 6), to: startOfWeek)!
    }
    
    var weekOfYear: Int { return Calendar.current.dateComponents([Calendar.Component.weekOfYear], from: self).weekOfYear!}
    var year: Int { return Calendar.current.dateComponents([Calendar.Component.yearForWeekOfYear], from: self).yearForWeekOfYear!}
   
}
