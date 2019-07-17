//
//  Week.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 16/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

class Week{
    
    static let numberOfWorkoutsPerWeek: Int = 3
    static let maximumRestInARow: Int = 2
    
    var workouts: [Workout]
    var previousWeek: Week?
    var nextWeek: Week?
    var date: Date
    
    var weekOfYear: Int { return calendar.dateComponents([Calendar.Component.weekOfYear], from: date).weekOfYear!}
    var year: Int { return calendar.dateComponents([Calendar.Component.yearForWeekOfYear], from: date).yearForWeekOfYear!}
    var weekStr: String { return "\(year)-\(String(format: "%02d", weekOfYear))"}
    
    var correctNumberOfWorkouts: Bool { return workouts.count == Week.numberOfWorkoutsPerWeek}
    var correctRestDays: Bool { return daysBetweenWorkouts().max() ?? 0 <= Week.maximumRestInARow}
    var consistent: Bool { return correctNumberOfWorkouts && correctRestDays}
    
    private var calendar: Calendar{ return Calendar.init(identifier: .iso8601) }
    private let streakDecay: Double = 0.5

    
    init(_ workouts: [Workout], date: Date) {
        self.workouts = workouts
        self.date = date
    }
    
    func consistencyStreak() -> Int{
        if consistent{
            if let p = previousWeek{
                return p.consistencyStreak() + 1
            }else{
                return 1
            }
        }else{
//            return 0
            if let p = previousWeek{
                return Int(Double(p.consistencyStreak()) * streakDecay)
            }else{
                return 0
            }
        }
    }
    
    private func daysBetweenWorkouts() -> [Int]{
        if workouts.count == 0{
            return []
        }
        
        let calendar: Calendar = Calendar(identifier: .iso8601)
        var previousWorkout: Workout?
        var result: [Int] = []
        let sWorkouts: [Workout] = workouts.sorted(by: {$0.date! < $1.date!})
        
        //calc gap to first
        var diff: Int = calendar.dateComponents([.day], from: calendar.startOfDay(for: sWorkouts[0].date!.startOfWeek!), to: calendar.startOfDay(for: sWorkouts[0].date!)).day!
        result.append(diff)
        
        for w in sWorkouts{
            if let p = previousWorkout{
                let d: Int = calendar.dateComponents([.day], from: calendar.startOfDay(for: p.date!), to: calendar.startOfDay(for: w.date!)).day!
                //want rest days so subtract 1 from this. eg if train on 12th and 14th .. the diff is 2 but there's only 1 rest day between
                result.append(d-1)
            }
            previousWorkout = w
        }
        //calc end of week
        let endW: Date = calendar.date(byAdding: DateComponents(day:6), to: sWorkouts[0].date!.startOfWeek!)!
        diff = calendar.dateComponents([.day], from: sWorkouts[sWorkouts.count-1].date!, to: endW).day!
        result.append(diff)
        return result
    }
    
}
