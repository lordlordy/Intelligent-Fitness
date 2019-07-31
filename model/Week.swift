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
    
    var dateOrderWorkouts: [Workout] { return CoreDataStackSingleton.shared.getWorkouts(inWeekContaining: startOfWeek).sorted(by: {$0.date! < $1.date!})}
    var completeWorkouts: [Workout]{ return dateOrderWorkouts.filter({$0.complete})}
    var incompleteWorkouts: [Workout] { return dateOrderWorkouts.filter({!$0.complete})}
    var previousWeek: Week?
    var nextWeek: Week?
    var startOfWeek: Date
    var endOfWeek: Date { return startOfWeek.endOfWeek}
    var functionalFitnessTest: Workout?{
        let ffts: [Workout] = dateOrderWorkouts.filter({$0.type == WorkoutType.FFT.rawValue})
        if ffts.count > 0{
            return ffts[0]
        }else{
            return nil
        }
    }
    
    var weekOfYear: Int { return startOfWeek.weekOfYear}
    var year: Int { return startOfWeek.year}
    var weekStr: String { return "\(year)-\(String(format: "%02d", weekOfYear))"}
    var daysStr: String { return dateOrderWorkouts.map({$0.dayOfWkStr}).joined(separator: ":")}
    var summary: String {
        var str: [String] = []
        str.append(consistent ? "COMPLETE ~ " : "INCOMPLETE ~ ")
        str.append("Streak:\(consistencyStreak ?? 0)")
        str.append("Workouts: \(dateOrderWorkouts.count)")
        if dateOrderWorkouts.filter({$0.type == WorkoutType.FFT.rawValue}).count > 0{
            str.append("(FFT)")
        }
        str.append("Max Rest:\(maxRestDays(forDays: datesToCalculateRestDays())) days")
        return str.joined(separator: " ")
    }
    
    var correctNumberOfWorkouts: Bool { return completeWorkouts.count == Week.numberOfWorkoutsPerWeek}
    var correctRestDays: Bool { return restDaysConsistent(forDays: datesToCalculateRestDays())}
    var consistent: Bool { return correctNumberOfWorkouts && correctRestDays}
    
    private var consistencyStreak: Int?
    
    private let streakDecay: Double = 0.5

    
    init(date: Date) {
        self.startOfWeek = date.startOfWeek
    }
    
    func weekContains(thisDate d: Date) -> Bool{
        return d.year == year && d.weekOfYear == weekOfYear
    }
    
    func date(forDayOfWeek d: Int) -> Date{
        return Calendar.current.date(byAdding: DateComponents(day: d), to: startOfWeek)!
    }
    
    func workouts(forDayOfWeek d: Int) -> [Workout]{
        let d: Date = date(forDayOfWeek: d)
        return dateOrderWorkouts.filter({Calendar.current.compare(d, to: $0.date!, toGranularity: .day) == ComparisonResult.orderedSame})
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

    
    func connectUpWorkouts(){
        var pWorkout: Workout?
        if let previousWeek = WorkoutManager.shared.getWeek(containingDate: startOfWeek.yesterday){
            if previousWeek.dateOrderWorkouts.count > 0{
                pWorkout = previousWeek.dateOrderWorkouts[previousWeek.dateOrderWorkouts.count-1]
            }
        }
        for w in dateOrderWorkouts{
            if let p = pWorkout{
                p.nextWorkout = w
            }
            w.previousWorkout = pWorkout
            pWorkout = w
        }
    }
    
    func nextConstistentDate(onOrAfter d: Date) -> Date?{
        if !weekContains(thisDate: d) || dateOrderWorkouts.count >= 3{
            // wrong week or already have enough workouts
            return nil
        }
        if dateOrderWorkouts.count == 0{
            // shouldn't have a week if this is the case but can return a valid date
            return d
        }else if dateOrderWorkouts.count == 1{
            let baseDate: Date = max(dateOrderWorkouts[0].date!.tomorrow, d)
            // give two rest days unless that lands us on final day or in to next week then reduce
            // NB if it's last day of week we need to try and move it back a day to give a chance of another workout
            let candidateDate: Date = Calendar.current.date(byAdding: DateComponents(day:2), to: baseDate)!
            if !weekContains(thisDate: candidateDate) || Calendar.current.compare(candidateDate, to: endOfWeek, toGranularity: .day) == ComparisonResult.orderedSame{
                // not in this week or is last day of week
                return baseDate
            }
            return candidateDate
        }else if dateOrderWorkouts.count == 2{
            let currentDates: [Date] = dateOrderWorkouts.map({$0.date!})
            var candidateDate: Date = d
            while Calendar.current.compare(candidateDate, to: endOfWeek, toGranularity: .day) == .orderedAscending{
                if restDaysConsistent(forDays: currentDates + [candidateDate]){
                    return candidateDate
                }
                candidateDate = Calendar.current.date(byAdding: DateComponents(day:1), to: candidateDate)!
            }
            return nil
        }
        return nil
    }
    
    private func restDaysConsistent(forDays days: [Date]) -> Bool{
        return maxRestDays(forDays: days) <= Week.maximumRestInARow
    }
    
    private func maxRestDays(forDays days: [Date]) -> Int{
        if days.count < 2{
            return 0
        }
        let oDays: [Date] = days.sorted(by: {$0 < $1})
        var pDate: Date = oDays[0]
        var gaps: [Int] = []
        
        for i in 1..<oDays.count{
            // -1 since we want number of days without activity - ie not including either of the dates
            gaps.append(Calendar.current.dateComponents([.day], from: pDate, to: oDays[i]).day! - 1)
            pDate = oDays[i]
        }
        print(gaps)
        return gaps.max() ?? 0
    }
    
    private func datesToCalculateRestDays() -> [Date]{
        if dateOrderWorkouts.count == 0{
            return []
        }
        
        let calendar: Calendar = Calendar(identifier: .iso8601)
        var result: [Date] = []
        
        //calc gap to first
        if let p = dateOrderWorkouts[0].previousWorkout{
            result.append(p.date!)
        }
        
        result = result + dateOrderWorkouts.map({$0.date!})

        // add start of following week
        result.append(calendar.date(byAdding: DateComponents(day:1), to: dateOrderWorkouts[0].date!.endOfWeek)!)
        print(result)
        return result
    }
    
}
