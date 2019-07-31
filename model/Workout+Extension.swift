//
//  Session+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 29/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension Workout{

    var weekOfYear: Int { return calendar.dateComponents([Calendar.Component.weekOfYear], from: date!).weekOfYear!}
    var year: Int { return calendar.dateComponents([Calendar.Component.yearForWeekOfYear], from: date!).yearForWeekOfYear!}
    var weekStr: String { return "\(year)-\(String(format: "%02d", weekOfYear))"}
    var dayOfWkStr: String {
        let df: DateFormatter = DateFormatter()
        df.dateFormat = "E-dd"
        return df.string(from: date!)
    }
    
    private var calendar: Calendar{ return Calendar.init(identifier: .iso8601) }
    
    var percentageComplete: Double{
        get{
            if orderedExerciseArray().count > 0{
                // note the minimum. This ensures that a score of greater than 100% for a given test element does not contribute more the 100% to overall test result
                return orderedExerciseArray().reduce(0, {$0 + min(1,$1.percentageComplete)}) / Double(orderedExerciseArray().count)
            }else{
                return 1.0
            }
        }
    }
    
    // returns nil if no exercises of the requested type
    func getValue(forExerciseType type: ExerciseType, andMeasure measure: ExerciseMeasure) -> Double?{
        if type == .ALL{
            return getValue(forMeasure: measure, andExercises: orderedExerciseArray())
        }else if includes(exerciseType: type){
            let exercises: [Exercise] = orderedExerciseArray().filter({$0.exerciseType() == type})
            return getValue(forMeasure: measure, andExercises: exercises)
        }else{
            return nil
        }
    }

    func getValue(forMeasure measure: ExerciseMeasure) -> Double{
        return getValue(forMeasure: measure, andExercises: orderedExerciseArray())
    }
    
    private func getValue(forMeasure measure: ExerciseMeasure, andExercises exercises: [Exercise]) -> Double{
        if exercises.count == 0{
            return 0.0
        }
        switch measure.aggregator() {
        case .Sum:
            return exercises.reduce(0.0, {$0 + $1.getValue(forMeasure: measure)})
        case .Max:
            return exercises.reduce(0.0, {max($0, $1.getValue(forMeasure: measure))})
        case .Min:
            return exercises.reduce(Double.greatestFiniteMagnitude, {min($0, $1.getValue(forMeasure: measure))})
        case .Average:
            return exercises.reduce(0.0, {$0 + $1.getValue(forMeasure: measure)}) / Double(exercises.count)
        }
    }
    
    func summary() -> String{
        if complete{
            return createWorkoutSummary()
        }else{
            if isTest{
                return "Next test"
            }else{
                return "Next workout"
            }
        }
    }
    
    func numberOfExercises() -> Int{
        return exercises?.count ?? 0
    }
    
    func exercises(ofType type: ExerciseType) -> [Exercise]{
        return orderedExerciseArray().filter({$0.type == type.rawValue})
    }
    
    func exercise(atOrder order: Int16) -> Exercise?{
        for exercise in exercises!{
            if let e = exercise as? Exercise{
                if e.order == order{
                    return e
                }
            }
        }
        return nil
    }
    
    func workoutType() -> WorkoutType?{
        return WorkoutType(rawValue: type)
    }
    
    func workoutCompleted() -> Bool{
        for e in orderedExerciseArray(){
            if !e.exerciseCompleted(){
                return false
            }
        }
        return true
    }

    //this means workout is done but that may be because it was finished incomplete.
    func workoutFinished() -> Bool{
        for e in orderedExerciseArray(){
            if !e.exerciseFinished(){
                return false
            }
        }
        return true
    }
    
    //return nil if workout completed
    func currentSet() -> Int16?{
        for e in orderedExerciseArray(){
            if !e.exerciseFinished(){
                return e.order
            }
        }
        return nil
    }
    
    func orderedExerciseArray() -> [Exercise]{
        var array: [Exercise] = exercises?.allObjects as? [Exercise] ?? []
        array.sort(by: {$0.order < $1.order})
        return array
    }
    
    private func includes(exerciseType type: ExerciseType) -> Bool{
        return exercises(ofType: type).count > 0
    }
    
    private func createWorkoutSummary() -> String{
        var strParts: [String] = []
        let f: NumberFormatter = NumberFormatter()
        f.numberStyle = .percent
        if let s = f.string(from: NSNumber(value: percentageComplete)){
            strParts.append(s)
        }
        if getValue(forMeasure: .totalKG) > 0 { strParts.append("\(Int(getValue(forMeasure: .totalKG)))kg") }
        if getValue(forMeasure: .totalReps) > 0 { strParts.append(SetType.Reps.string(forValue: getValue(forMeasure: .totalReps))) }
        if getValue(forMeasure: .totalTime) > 0 { strParts.append(SetType.Time.string(forValue: getValue(forMeasure: .totalTime))) }
        if getValue(forMeasure: .totalDistance) > 0 { strParts.append(SetType.Distance.string(forValue: getValue(forMeasure: .totalDistance))) }
        if getValue(forMeasure: .totalTouches) > 0 { strParts.append(SetType.Touches.string(forValue: getValue(forMeasure: .totalTouches))) }

        return "Completed: " + strParts.joined(separator: " / ")
        
    }
    
    /*
     
     */
    func workoutProgression() -> WorkoutDefinition{
        var exercises: [WorkoutExerciseDefinition] = []
        let defaults: WorkoutDefinition? = WorkoutManager.shared.defaultWorkout(forType: workoutType()!)
        
        for e in orderedExerciseArray(){
            if let d = defaults{
                if let definition = d.definition(forType: e.exerciseType()){
                    exercises.append(e.progression(basedOnDefinition: definition))
                }
            }
        }
        return WorkoutDefinition(type: workoutType()!, exercises: exercises)
    }
    
    func getProgression(forType type: WorkoutType) -> WorkoutDefinition?{
        if self.type == type.rawValue{
            return workoutProgression()
        }else{
            if let p = previousWorkout{
                return p.getProgression(forType: type)
            }
        }
        return nil
    }
    
    fileprivate func getLastWorkout(ofType type: WorkoutType) -> Workout?{
        if let p = previousWorkout{
            if p.type == type.rawValue{
                return p
            }else{
                return p.getLastWorkout(ofType: type)
            }
        }
        return nil
    }
}
