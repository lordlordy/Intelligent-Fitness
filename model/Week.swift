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
    
    var workouts: [Workout] { return CoreDataStackSingleton.shared.getWorkouts(inWeekContaining: startOfWeek)}
    var completeWorkouts: [Workout]{ return workouts.filter({$0.complete})}
    var incompleteWorkouts: [Workout] { return workouts.filter({!$0.complete})}
    var previousWeek: Week?
    var nextWeek: Week?
    var startOfWeek: Date
    var endOfWeek: Date { return startOfWeek.endOfWeek}
    
    var weekOfYear: Int { return startOfWeek.weekOfYear}
    var year: Int { return startOfWeek.year}
    var weekStr: String { return "\(year)-\(String(format: "%02d", weekOfYear))"}
    var daysStr: String { return workouts.map({$0.dayOfWkStr}).joined(separator: ":")}
    
    var correctNumberOfWorkouts: Bool { return completeWorkouts.count == Week.numberOfWorkoutsPerWeek}
    var correctRestDays: Bool { return daysBetweenWorkouts().max() ?? 0 <= Week.maximumRestInARow}
    var consistent: Bool { return correctNumberOfWorkouts && correctRestDays}
    
    private var consistencyStreak: Int?
    
    private let streakDecay: Double = 0.5

    
    init(date: Date) {
        self.startOfWeek = date.startOfWeek
    }
    
    func weekContains(thisDate d: Date) -> Bool{
        return d.year == year && d.weekOfYear == weekOfYear
    }
    
    func recursivelyCalculateConsistencyStreak() -> Int{
        
        //check whether can used cached value
        if let cs = consistencyStreak{
            if !weekContains(thisDate: Date()){
                // use cached value for all weeks except the current week. Recalc that one each time
                return cs
            }
        }

        if consistent{
            if let p = previousWeek{
                consistencyStreak = p.recursivelyCalculateConsistencyStreak() + 1
                return consistencyStreak!
            }else{
                consistencyStreak = 1
                return 1
            }
        }else{
//            return 0
            if let p = previousWeek{
                consistencyStreak = Int(Double(p.recursivelyCalculateConsistencyStreak()) * streakDecay)
                return consistencyStreak!
            }else{
                consistencyStreak = 0
                return 0
            }
        }
    }
    
    private func daysBetweenWorkouts() -> [Int]{
        if completeWorkouts.count == 0{
            return []
        }
        
        let calendar: Calendar = Calendar(identifier: .iso8601)
        var previousWorkout: Workout?
        var result: [Int] = []
        let sWorkouts: [Workout] = completeWorkouts.sorted(by: {$0.date! < $1.date!})
        
        //calc gap to first
        var diff: Int = calendar.dateComponents([.day], from: calendar.startOfDay(for: sWorkouts[0].date!.startOfWeek), to: calendar.startOfDay(for: sWorkouts[0].date!)).day!
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
        let endW: Date = calendar.date(byAdding: DateComponents(day:6), to: sWorkouts[0].date!.startOfWeek)!
        diff = calendar.dateComponents([.day], from: sWorkouts[sWorkouts.count-1].date!, to: endW).day!
        result.append(diff)
        return result
    }
    
}
