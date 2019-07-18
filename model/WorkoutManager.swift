//
//  SessionManager.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 29/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

enum ExerciseType: Int16, CaseIterable{
    case gobletSquat, lunge, benchPress, pushUp, pullDown
    case standingBroadJump, plank, deadHang, farmersCarry, squat, sittingRisingTest
    case ALL
    
    func setType() -> SetType{
        switch self{
        case .gobletSquat, .lunge, .benchPress, .pushUp, .pullDown: return .Reps
        case .plank, .deadHang, .squat: return .Time
        case .standingBroadJump, .farmersCarry: return .Distance
        case .sittingRisingTest: return .Touches
        case .ALL: return .All
        }
    }
}

enum AggregatorType{
    case Sum, Average, Max, Min
}

enum ExerciseMeasure: String, CaseIterable{
    case maxKG, minKG, avKG, totalKG
    case totalReps, totalRepKG, avReps, minReps, maxReps, maxRepKG
    case totalDistance, totalDistanceKG, avDistance, minDistance, maxDistance
    case totalTime, totalTimeKG, avTime, minTime, maxTime
    case totalTouches, totalTouchKG, avTouch, minTouch, maxTouch
    func string() -> String{
        switch self{
        case .maxKG: return "Max KG"
        case .minKG: return "Min KG"
        case .avKG: return "Average KG"
        case .totalKG: return "Total KG"
        case .totalReps: return "Total Reps"
        case .totalRepKG: return "Total KG x Reps"
        case .maxRepKG: return "Max KG x Reps"
        case .avReps: return "Average Reps"
        case .minReps: return "Min Reps"
        case .maxReps: return "Max Reps"
        case .totalDistance: return "Total m"
        case .totalDistanceKG: return "Total KG x m"
        case .avDistance: return "Average m"
        case .minDistance: return "Min m"
        case .maxDistance: return "Max m"
        case .totalTime: return "Total secs"
        case .totalTimeKG: return "Total KG x secs"
        case .avTime: return "Average secs"
        case .minTime: return "Min secs"
        case .maxTime: return "Max secs"
        case .totalTouches: return "Total Touches"
        case .totalTouchKG: return "Total KG x Touches"
        case .avTouch: return "Average Touches"
        case .minTouch: return "Min Touches"
        case .maxTouch: return "Max Touches"
        }
    }
    func aggregator() -> AggregatorType{
        switch self{
        case .totalKG, .totalReps, .totalRepKG, .totalTime, .totalTimeKG, .totalTouches, .totalTouchKG, .totalDistance, .totalDistanceKG: return .Sum
        case .avKG, .avReps, .avTime, .avTouch, .avDistance: return .Average
        case .maxKG, .maxReps, .maxTime, .maxTouch, .maxDistance, .maxRepKG: return .Max
        case .minKG, .minReps, .minTime, .minTouch, .minDistance: return .Min
        }
    }
    
    func weighted() -> Bool{ return self == ExerciseMeasure.avKG }
}

enum SetType: Int16{
    case Reps, Distance, Time, Touches, All
    func string(forValue d: Double) -> String{
        switch self{
        case .Reps: return "\(Int(d)) reps"
        case .Distance: return "\(d)m"
        case .Time: return "\(Int(d))s"
        case .Touches: return "\(Int(d)) touches"
        case .All: return "\(Int(d))"
        }
    }
    
    func validMeasures() -> [ExerciseMeasure]{
        switch self{
        case .Reps: return [.maxRepKG, .maxKG, .minKG, .avKG, .totalReps, .totalRepKG, .avReps, .minReps, .maxReps]
        case .Distance: return [.maxKG, .minKG, .avKG, .totalDistance, .totalDistanceKG, .avDistance, .minDistance, .maxDistance]
        case .Time: return [.maxKG, .minKG, .avKG, .totalTime, .totalTimeKG, .avTime, .minTime, .maxTime]
        case .Touches: return [.maxKG, .minKG, .avKG, .totalTouches, .totalTouchKG, .avTouch, .minTouch, .maxTouch]
        case .All: return ExerciseMeasure.allCases
        }
    }
    
    func moreIsBetter() -> Bool{
        // indicates whether more reps is better. For instance where 'touches' are counted the goal is as few as possible
        switch self{
        case .Touches: return false
        default: return true
        }
    }
}

enum WorkoutType: Int16{
    case FFT, DescendingReps
    
    func string() -> String{
        switch self{
        case .FFT: return "Functional Fitness Test"
        case .DescendingReps: return "Descending Reps"
        }
    }
    func isTest() -> Bool{
        switch self{
        case .FFT: return true
        default: return false
        }
    }
}


class WorkoutManager: Athlete{

    
    static var shared: WorkoutManager = WorkoutManager()
    
    private struct ExerciseDefaults{
        var type: ExerciseType
        var defaultPlan: Double
        var defaultKG: Double
    }
    
    var exerciseTypes: [ExerciseType]{ return ExerciseType.allCases}
    private var weekCache: [Week] = []
    
    var calendar: Calendar{ return Calendar(identifier: .iso8601)}
    
    private let functionalFitnessTest: [ExerciseDefaults] = [
        ExerciseDefaults(type: .standingBroadJump, defaultPlan: 1.0, defaultKG: 0.0),
        ExerciseDefaults(type: .deadHang , defaultPlan: 30.0, defaultKG: 0.0),
        ExerciseDefaults(type: .farmersCarry , defaultPlan: 100.0, defaultKG: 10.0),
        ExerciseDefaults(type: .plank, defaultPlan: 30.0, defaultKG: 0.0),
        ExerciseDefaults(type: .squat, defaultPlan: 30.0, defaultKG: 0.0),
        ExerciseDefaults(type: .sittingRisingTest, defaultPlan: 2.0, defaultKG: 0.0)
    ]
    
    private let exerciseSet1: [ExerciseDefaults] = [
        ExerciseDefaults(type: .gobletSquat, defaultPlan: 5, defaultKG: 5.0),
        ExerciseDefaults(type: .lunge, defaultPlan: 5, defaultKG: 10.0),
        ExerciseDefaults(type: .benchPress, defaultPlan: 5, defaultKG: 5.0),
        ExerciseDefaults(type: .pushUp, defaultPlan: 5, defaultKG: 0.0),
        ExerciseDefaults(type: .pullDown, defaultPlan: 5, defaultKG: 5.0),
    ]
    
    // MARK: - Athlete Protocol
    
    func timeSeries(forExeciseType type: ExerciseType, andMeasure measure: ExerciseMeasure) -> [(date: Date, value: Double)] {
        let workouts: [Workout] = CoreDataStackSingleton.shared.getChronologicalOrderedWorkouts(ofType: nil, isTest: nil).filter({$0.complete})
        var ts: [(date:Date, value: Double)] = []
        for w in workouts{
            if let v = w.getValue(forExerciseType: type, andMeasure: measure){
                ts.append((w.date!, v))
            }
        }
        if type == .ALL{
            ts = ts.filter({$0.value > 0.0})
        }

        return ts
    }
    
    // MARK: - Other
    
    func currentStreakData() -> (current: Int, best: Int){
        let wks: [Week] = getWeeks().sorted(by: {$0.startOfWeek < $1.startOfWeek})
        if wks.count == 0{
            return (0,0)
        }
        let current: Int = wks[wks.count-1].recursivelyCalculateConsistencyStreak()
        let best: Int = wks.reduce(0, {max($0, $1.recursivelyCalculateConsistencyStreak())})
        return (current, best)
    }
    
    func currentWeek() -> Week?{
        let weeks = getWeeks()
        if weeks.count > 0{
            if weeks[weeks.count-1].weekContains(thisDate: Date()){
                return weeks[weeks.count - 1]
            }else{
                let filtered: [Week] = weeks.filter({$0.weekContains(thisDate: Date())})
                if filtered.count > 0{
                    return filtered[0]
                }
            }
        }
        return nil
    }
    
    func getWeeks() -> [Week]{
        return getWeeks(toDate: Date())
    }
    
    func getWeeks(toDate date: Date) -> [Week]{
        
        var startOfWeek: Date
        var previousWeek: Week?

        print("Cache contains: \(weekCache.count) weeks")
        
        // see if can use cache
        if weekCache.count > 0{
            //we have a cache. Just need to see if we need to add more weeks
            if weekCache[weekCache.count-1].endOfWeek >= date{
                // it's upto date
                return weekCache.filter({$0.endOfWeek <= date})
            }else{
                // add missing weeks
                startOfWeek = Calendar.current.date(byAdding: DateComponents(day: 7), to: weekCache[weekCache.count-1].startOfWeek)!
                previousWeek = weekCache[weekCache.count-1]
            }
        }else{
            // no weeks at all. So start from the earilest week
            if let d =  CoreDataStackSingleton.shared.earliestCompletedWorkoutDate()?.startOfWeek{
                startOfWeek = d
            }else{
                return []
            }
        }
        
        // create weeks
        while startOfWeek <= date{
            let wk: Week = Week(date: startOfWeek)
            weekCache.append(wk)
            if let p = previousWeek{
                p.nextWeek = wk
                wk.previousWeek = p
            }
            previousWeek = wk
            startOfWeek = Calendar.current.date(byAdding: DateComponents(day: 7), to: startOfWeek)!
        }
        
        return weekCache
    }
    
    func nextFunctionalFitnessTest() -> Workout{
        let incomplete: [Workout] = CoreDataStackSingleton.shared.incompleteWorkouts().filter({$0.type == WorkoutType.FFT.rawValue})
        if incomplete.count > 0{
            let w: Workout = incomplete[0]
            w.date = max(Date(), w.date ?? Date())
            CoreDataStackSingleton.shared.save()
            return w
        }else{
            // really shouldn't get to this point as the next test should be created when the last one was saved
            print("Shouldn't really get here: WorkoutManager.nextFunctionFitnessTest as the next test should have been created")
            let tests: [Workout] = CoreDataStackSingleton.shared.getFunctionalFitnessTests().sorted(by: {$0.date! > $1.date!})
            if tests.count > 0{
                let _: Bool = createNextFunctionalFitnessTest(after: tests[0])
                // have created next workout so call this method re-cursively
                return nextFunctionalFitnessTest()
            }else{
                // no tests at all
                let newTest: Workout = createFunctionalFitnessTest(forDate: Date())
                //save it before returning
                CoreDataStackSingleton.shared.save()
                return newTest
            }
        }
    }
    
    func createNextFunctionalFitnessTest(after: Workout) -> Bool{
        // aim for tests every 4 weeks
        let oneMonthFromNow: Date = calendar.date(byAdding: DateComponents(day: 28), to: Date())!
        let test: Workout = createFunctionalFitnessTest(forDate: oneMonthFromNow)
        after.nextWorkout = test
        test.previousWorkout = after
        let newPowerUp: Bool = checkforPowerups()
        CoreDataStackSingleton.shared.save()
        return newPowerUp
    }
    
    func getExercises(forType type: ExerciseType) -> [Exercise]{
        return CoreDataStackSingleton.shared.getExercises(ofType: type)
    }
    
    
    func createTestWorkoutData(){
        var d: Date = calendar.date(byAdding: DateComponents(year: -1), to: Date())!.startOfWeek
        let interval: DateComponents = DateComponents(day: 28)
        var previous: Workout?
        var previousFFT: Workout?
        let progression: [ExerciseType: [Double]] = [.gobletSquat: [5, 6, 7, 7, 8, 9, 10, 12, 14, 14, 15, 16, 17, 20],
                                                     .lunge: [5,7,10, 12, 12, 14, 15, 15, 16, 18, 20, 20, 22, 22],
                                                     .benchPress: [3, 4, 5, 6, 7, 8, 8, 10, 11, 12, 14, 15, 18, 20],
                                                     .pushUp: [5, 5, 6, 6, 7, 8, 9, 10, 10, 10, 11, 12, 15, 16],
                                                     .pullDown: [5, 6, 6, 5, 6, 7, 8, 8, 8, 9, 10, 12, 12, 15]]
        
        let testProgression: [ExerciseType: [Double]] = [.standingBroadJump: [1, 1.1, 1.2, 1.3, 1.4, 1.45, 1.45, 1.5, 1.6, 1.6, 1.65, 1.65, 1.67, 1.7],
                                                     .deadHang: [20.0, 23.0, 28.0, 33.0, 33.0, 35.0, 38.0, 43.0, 45.0, 46.0, 48, 49, 50, 55],
                                                     .farmersCarry: [75.0, 80.0, 90.0, 93.0, 101.0, 102.0, 103.0, 107.0, 112.0, 115.0, 115, 125, 129, 130],
                                                     .plank: [15.0, 25.0, 35.0, 36.0, 37.0, 38.0, 40.0, 41.0, 45.0, 50.0, 53, 55, 57, 60],
                                                     .squat: [21.0, 22.0, 25.0, 27.0, 27.0, 30.0, 40.0, 41.0, 43.0, 45.0, 50, 60, 59, 65],
                                                     .sittingRisingTest: [4, 5, 3, 4, 3, 2, 2, 2, 1, 0, 0, 0, 0, 0]]

        for i in 0..<progression[.gobletSquat]!.count{
            // create tests
            if d <= Date(){
                // only create if on or before today
                let fft: Workout = createFunctionalFitnessTest(forDate: d)
                if let p = previousFFT{
                    p.nextWorkout = fft
                    fft.previousWorkout = p
                }
                for (key, value) in testProgression{
                    if let s = fft.exercises(ofType: key)[0].exerciseSet(atOrder: 0){
                        s.actual = value[i]
                    }
                }
                fft.complete = true
                previousFFT = fft
            }
            
            // create weekly workouts
            for w in 0...3{
                let date: Date = calendar.date(byAdding: DateComponents(day: w * 7), to: d)!
        
                for wkDate in createRandomDaysOfWeek(fromDate: date){
                    if wkDate > Date(){
                        break
                    }
                    let w: Workout = createWorkout(forDate: wkDate, exercises: [
                        ExerciseDefaults(type: .gobletSquat, defaultPlan: 5, defaultKG: 5.0),
                        ExerciseDefaults(type: .lunge, defaultPlan: 5, defaultKG: 10.0),
                        ExerciseDefaults(type: .benchPress, defaultPlan: 5, defaultKG: 5.0),
                        ExerciseDefaults(type: .pushUp, defaultPlan: progression[.pushUp]![i], defaultKG: 0.0),
                        ExerciseDefaults(type: .pullDown, defaultPlan: 5, defaultKG: 5.0),
                        ])
                    if let p = previous{
                        p.nextWorkout = w
                        w.previousWorkout = p
                    }
                    for (key, value) in progression{
                        // randomly move 10% down and 20% up
                        let percentageMove: Double = Double.random(in: 0...0.3) + 0.9
                        for s in w.exercises(ofType: key)[0].exerciseSets(){
                            s.actual = s.plan
                            if ExerciseDefinitionManager.shared.exerciseDefinition(for: key).usesWeight{
                                s.actualKG = value[i] * percentageMove
                            }else{
                                s.actualKG = 0.0
                            }
                        }
                        
                    }
                    w.complete = true
                    previous = w
                    CoreDataStackSingleton.shared.save()
                }
                let _: Bool = checkforPowerups(toDate: date)
            }
            d = calendar.date(byAdding: interval, to: d)!
        }
        
        
    }
    
    private func createRandomDaysOfWeek(fromDate d: Date) -> [Date]{
        let workoutDaysOfWeek: [[Int]] = [[0,2,4], [1,2,4], [0,1,2], [1,3,5], [1,4,6]]
        let weekly = workoutDaysOfWeek[Int.random(in: 0..<workoutDaysOfWeek.count)]
        var result: [Date] = []
        for dayOfWeek in weekly{
            result.append(calendar.date(byAdding: DateComponents(day: dayOfWeek), to: d.startOfWeek)!)
        }
        return result
    }
    
//    func createTestFFTData(){
//        var d: Date = calendar.date(byAdding: DateComponents(year: -1), to: Date())!
//        let interval: DateComponents = DateComponents(day: 28)
//        var previous: Workout?
//        let progression: [ExerciseType: [Double]] = [.standingBroadJump: [1, 1.1, 1.2, 1.3, 1.4, 1.45, 1.45, 1.5, 1.6, 1.6, 1.65, 1.65, 1.67, 1.7],
//                                                     .deadHang: [20.0, 23.0, 28.0, 33.0, 33.0, 35.0, 38.0, 43.0, 45.0, 46.0, 48, 49, 50, 55],
//                                                     .farmersCarry: [75.0, 80.0, 90.0, 93.0, 101.0, 102.0, 103.0, 107.0, 112.0, 115.0, 115, 125, 129, 130],
//                                                     .plank: [15.0, 25.0, 35.0, 36.0, 37.0, 38.0, 40.0, 41.0, 45.0, 50.0, 53, 55, 57, 60],
//                                                     .squat: [21.0, 22.0, 25.0, 27.0, 27.0, 30.0, 40.0, 41.0, 43.0, 45.0, 50, 60, 59, 65],
//                                                     .sittingRisingTest: [4, 5, 3, 4, 3, 2, 2, 2, 1, 0, 0, 0, 0, 0]]
//
//        for i in 0..<progression[.standingBroadJump]!.count{
//            let fft: Workout = createFunctionalFitnessTest(forDate: d)
//            if let p = previous{
//                p.nextWorkout = fft
//                fft.previousWorkout = p
//            }
//            for (key, value) in progression{
//                if let s = fft.exercises(ofType: key)[0].exerciseSet(atOrder: 0){
//                    s.actual = value[i]
//                }
//            }
//            fft.complete = true
//            previous = fft
//            d = calendar.date(byAdding: interval, to: d)!
//        }
//
//        CoreDataStackSingleton.shared.save()
//
//    }
    
    private func createFunctionalFitnessTest(forDate date: Date) ->  Workout{
        let workout: Workout = CoreDataStackSingleton.shared.newWorkout()
        workout.date = date
        workout.isTest = true
        workout.type = WorkoutType.FFT.rawValue
        var order: Int16 = 0
        for fft in functionalFitnessTest{
            let exercise: Exercise = CoreDataStackSingleton.shared.newExercise()
            let exerciseSet: ExerciseSet = CoreDataStackSingleton.shared.newExerciseSet(forType: fft.type.setType())
            exerciseSet.order = 0
            exerciseSet.plan = fft.defaultPlan
            exerciseSet.plannedKG = fft.defaultKG
            exerciseSet.actualKG = exerciseSet.plannedKG
            exerciseSet.exercise = exercise
            exercise.addToSets(exerciseSet)
            exercise.order = order
            exercise.type = fft.type.rawValue
            exercise.isTest = true
            workout.addToExercises(exercise)
            order += 1
        }
        return workout
    }
    
    func nextWorkout() -> Workout{
        let incomplete: [Workout] = CoreDataStackSingleton.shared.incompleteWorkouts().filter({!$0.isTest})
        if incomplete.count > 0{
            let w: Workout = incomplete[0]
            w.date = max(Date(), w.date ?? Date())
            CoreDataStackSingleton.shared.save()
            return w
        }else{
            // really shouldn't get to this point as the next test should be created when the last one was saved
            print("Shouldn't really get here: nextWorkout as the next workout should have been created ")
            let workouts: [Workout] = CoreDataStackSingleton.shared.getChronologicalOrderedWorkouts(ofType: nil, isTest: nil).sorted(by: {$0.date! > $1.date!})
            if workouts.count > 0{
                let _: Bool = createNextWorkout(after: workouts[0])
                // have created next workout so call this method re-cursively
                return nextWorkout()
            }else{
                
                let newWorkout: Workout = createWorkout(forDate: Date(), exercises: exerciseSet1)
                //save it before returning
                CoreDataStackSingleton.shared.save()
                return newWorkout
            }
        }
    }

    func createNextWorkout(after: Workout) -> Bool{
        // set for tomorrow
        let tomorrow: Date = calendar.date(byAdding: DateComponents(day: 1), to: Date())!
        let workout: Workout = createWorkout(forDate: tomorrow, exercises: exerciseSet1)
        after.nextWorkout = workout
        workout.previousWorkout = after
        let newPowerUp: Bool = checkforPowerups()
        CoreDataStackSingleton.shared.save()
        return newPowerUp
    }
    
    private func checkforPowerups() -> Bool{
        return checkforPowerups(toDate: Date())
    }
    
    private func checkforPowerups(toDate date: Date) -> Bool{
        print("Checking whether to update power ups to \(date)")
        let orderWeeks: [Week] = getWeeks(toDate: date).sorted(by: {$0.startOfWeek < $1.startOfWeek})
        let maxStreak: Int16 = Int16(orderWeeks.reduce(0, {max($0, $1.recursivelyCalculateConsistencyStreak())}))
        let maxRepKGEdNum: Int16 = Int16(EddingtonCalculator().eddingtonHistory(timeSeries: timeSeries(forExeciseType: .ALL, andMeasure: .maxRepKG)).eddingtonNumber)
        let orderedPowerUps: [PowerUp] = CoreDataStackSingleton.shared.getPowerUps().sorted(by: {$0.date! < $1.date!})
        
        var newStreak: Int16?
        var newEdNum: Int16?
        var date: Date?
        
        if orderedPowerUps.count == 0{
            if maxStreak + maxRepKGEdNum > 0{
                newStreak = maxStreak
                newEdNum = maxRepKGEdNum
                if orderWeeks.count > 0{
                    date = orderWeeks[orderWeeks.count - 1].startOfWeek
                }else{
                    date = Date()
                }
            }
        }else{
            let cPUp = orderedPowerUps[orderedPowerUps.count - 1]
            if maxStreak > cPUp.defense || maxRepKGEdNum > cPUp.attack{
                newStreak = max(maxStreak, cPUp.defense)
                newEdNum = max(maxRepKGEdNum, cPUp.attack)
                if orderWeeks.count > 0{
                    date = orderWeeks[orderWeeks.count - 1].startOfWeek
                }else{
                    date = Date()
                }
            }
        }
        
        if let defense = newStreak{
            if let attack = newEdNum{
                if let d = date{
                    let newPowerUp: PowerUp = CoreDataStackSingleton.shared.newPowerUp()
                    newPowerUp.attack = attack
                    newPowerUp.defense = defense
                    newPowerUp.date = d
                    print(newPowerUp.description)
                    CoreDataStackSingleton.shared.save()
                    saveLatestPowerUpToCloud()
                    return true

                }
            }
        }
        
        return false
    }

    private func saveLatestPowerUpToCloud(){
        print("~~!!~~ TO BE IMPLEMENTED - saving powerups to the cloud")
    }

    private func createWorkout(forDate date: Date, exercises: [ExerciseDefaults]) -> Workout{
        let workout: Workout = CoreDataStackSingleton.shared.newWorkout()
        workout.date = date
        workout.type = WorkoutType.DescendingReps.rawValue
        workout.explanation = "This is an explanation"
        // for now lets create one of each type
        var order: Int16 = 0
        for e in exercises{
            let exercise: Exercise = CoreDataStackSingleton.shared.newExercise()
            exercise.order = order
            exercise.type = e.type.rawValue
            workout.addToExercises(exercise)
            let maxReps: Int16 = Int16(e.defaultPlan)
            var setOrder: Int16 = 0
            for r in (1...maxReps).reversed(){
                let exerciseSet: ExerciseSet = CoreDataStackSingleton.shared.newExerciseSet(forType: e.type.setType())
                exerciseSet.order = setOrder
                exerciseSet.plannedKG = e.defaultKG
                exerciseSet.plan = Double(r)
                // set actual to the plan as unless the changes this it's assumed they do the plan
                exerciseSet.actualKG = exerciseSet.plannedKG
                exercise.addToSets(exerciseSet)
                setOrder += 1
            }
            order += 1
        }
        
        return workout
    }

    private init(){
    }
    
}
