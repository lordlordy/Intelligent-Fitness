//
//  SessionManager.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 29/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth


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
        case .Distance:
            return String(format: "%.2fm", d)
//            return "\(d)m"
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
    case FFT, DescendingReps, ConstantReps
    
    func string() -> String{
        switch self{
        case .FFT: return "Functional Fitness Test"
        case .DescendingReps: return "Descending Reps"
        case .ConstantReps: return "Constant Reps"
        }
    }
    func isTest() -> Bool{
        switch self{
        case .FFT: return true
        default: return false
        }
    }
    
    func explanation() -> String {
        switch  self {
        case .FFT:
            return "Series of tests to monitor your progress"
        case .ConstantReps:
            return "Series of exercises with constant reps for each one"
        case .DescendingReps:
            return "Series of exercises where you do a descending series of reps for each one."
        }
    }
}


struct WorkoutExerciseDefinition{
    var type: ExerciseType
    var plan: Double
    var kg: Double
    var planProgression: Double
    var kgProgression: Double
}

struct WorkoutDefinition{
    var type: WorkoutType
    var exercises: [WorkoutExerciseDefinition]
    
    func definition(forType type: ExerciseType) -> WorkoutExerciseDefinition?{
        for e in exercises{
            if e.type == type{
                return e
            }
        }
        return nil
    }
}

struct PreparednessDataPoint{
    var hrv: HRVDataPoint
    var tsb: TSBDataPoint
    var sadnessTone: ToneReading?
}

class WorkoutManager: Athlete{
    
    static var shared: WorkoutManager = WorkoutManager()
    var firebaseRef: DatabaseReference?
    
    var exerciseTypes: [ExerciseType]{ return ExerciseType.allCases}
    private var weekCache: [Week] = []
    private var preparednessCache: (date: Date, preparedness: PreparednessDataPoint)?
    
    var calendar: Calendar{ return Calendar(identifier: .iso8601)}
    
    private let defaultDefinitions: [WorkoutType: WorkoutDefinition] = [
        WorkoutType.FFT: WorkoutDefinition(type: .FFT, exercises:  [
            WorkoutExerciseDefinition(type: .standingBroadJump, plan: 1.0, kg: 0.0, planProgression: 0.1, kgProgression: 0.0),
            WorkoutExerciseDefinition(type: .deadHang , plan: 30.0, kg: 0.0, planProgression: 5.0, kgProgression: 0.0),
            WorkoutExerciseDefinition(type: .farmersCarry , plan: 100.0, kg: 10.0, planProgression: 0.0, kgProgression: 1.0),
            WorkoutExerciseDefinition(type: .plank, plan: 30.0, kg: 0.0, planProgression: 5.0, kgProgression: 0.0),
            WorkoutExerciseDefinition(type: .squat, plan: 30.0, kg: 0.0, planProgression: 5.0, kgProgression: 0.0),
            WorkoutExerciseDefinition(type: .sittingRisingTest, plan: 2.0, kg: 0.0, planProgression: -1, kgProgression: 0.0)
        ]),
        WorkoutType.DescendingReps: WorkoutDefinition(type: .DescendingReps, exercises: [
            WorkoutExerciseDefinition(type: .benchPress, plan: 5, kg: 2.0, planProgression: 0.0, kgProgression: 2.0),
            WorkoutExerciseDefinition(type: .gobletSquat, plan: 5, kg: 2.0, planProgression: 0.0, kgProgression: 2.0),
            WorkoutExerciseDefinition(type: .bentOverRow, plan: 5, kg: 2.0, planProgression: 0.0, kgProgression: 2.0),
            WorkoutExerciseDefinition(type: .lunge, plan: 5, kg: 2.0, planProgression: 0.0, kgProgression: 2.0),
            WorkoutExerciseDefinition(type: .pullDown, plan: 5, kg: 2.0, planProgression: 0.0, kgProgression: 2.0),
            ]),
        WorkoutType.ConstantReps: WorkoutDefinition(type: .ConstantReps, exercises: [
            WorkoutExerciseDefinition(type: .pressUp, plan: 5, kg: 0.0, planProgression: 1.0, kgProgression: 0.0),
            WorkoutExerciseDefinition(type: .gobletSquat, plan: 5, kg: 2.0, planProgression: 0.0, kgProgression: 2.0),
            WorkoutExerciseDefinition(type: .sitUp, plan: 5, kg: 0.0, planProgression: 1.0, kgProgression: 0.0),
            WorkoutExerciseDefinition(type: .stepUp, plan: 5, kg: 0.0, planProgression: 0.0, kgProgression: 2.0),
            WorkoutExerciseDefinition(type: .pullDown, plan: 5, kg: 2.0, planProgression: 0.0, kgProgression: 2.0),
            ])
        ]
    
    func defaultWorkout(forType type: WorkoutType) -> WorkoutDefinition?{
        return defaultDefinitions[type]
    }
    
    func latestPreparedness(completion: @escaping (PreparednessDataPoint) -> Void){
        if let p = preparednessCache{
            // there is a cache item check it's current enough
            let hours = Calendar.current.dateComponents([.hour], from: p.date, to: Date()).hour ?? 0
            if hours < 6{
                // not more than 6 hours old
                completion(p.preparedness)
                return
            }
        }
        // no cache or cache is too old. Get latest readings
        // all these readings require completions. We can't end till all done
        // to acheive this need to embed teh competions within each other
        HealthKitAccess.shared.getTSBBasedOnRPE(dateRange: nil) { (tsb) in
            // note no date range - we want it to calculate from as early as possible to give most accurate latest information
            // now have tsb lets get latest hrv
            let range: (from: Date, to: Date) = (from: Calendar.current.date(byAdding: DateComponents(day: -7), to: Date())!, to: Date())
            HealthKitAccess.shared.getHRVData(dateRange: range, completion: { (hrv) in
                // look at past 7 days - if older than that then not much use to us
                // finally get latest sadness tone
                PersonalityInsightManager.shared.saveTones(completion: { (documentTones) in
                    // have all we need lets construct the preparedness
                    var hrvDP: HRVDataPoint = HRVDataPoint(date: Date(), sdnn: 0.0, offValue: 0.0, easyValue: 0.0, hardValue: 0.0)
                    if hrv.count > 0{
                        hrvDP = hrv.sorted(by: {$0.date > $1.date})[0]
                    }
                    var tsbDP: TSBDataPoint = TSBDataPoint(date: Date(), tss: 0.0, atl: 0.0, ctl: 0.0)
                    if tsb.count > 0{
                        tsbDP = tsb.sorted(by: {$0.date > $1.date})[0]
                    }
                    var emotion: DocumentTone? = nil
                    for dt in documentTones{
                        if dt.categoryName() == "Emotion Tone"{
                            emotion = dt
                        }
                    }
                    var sadness: ToneReading? = nil
                    if let e = emotion{
                        sadness = e.getTone(forName: "Sadness").currentReading
                        if sadness == nil{
                            print("No readings found for tone: 'Sadness'")
                        }
                    }else{
                        print("Didn't fine docment tone for 'Emotion Tone'")
                    }
                    
                    let pDP: PreparednessDataPoint = PreparednessDataPoint(hrv: hrvDP, tsb: tsbDP, sadnessTone: sadness)
                    self.preparednessCache = (date: Date(), preparedness: pDP)
                    completion(pDP)
                })
            })
        }
        
    }

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
    
    func getExercises(forType type: ExerciseType) -> [Exercise]{
        return CoreDataStackSingleton.shared.getExercises(ofType: type)
    }
    
    func currentStreakData() -> (current: Int, best: Int){
        let wks: [Week] = getWeeks().sorted(by: {$0.startOfWeek < $1.startOfWeek})
        if wks.count == 0{
            return (0,0)
        }
        let current: Int = wks[wks.count-1].recursivelyCalculateConsistencyStreak()
        let best: Int = wks.reduce(0, {max($0, $1.recursivelyCalculateConsistencyStreak())})
        return (current, best)
    }
    
    // MARK:- Weeks
    
    func getWeek(containingDate d: Date) -> Week?{
        let weeks: [Week] = getWeeks().filter({$0.year == d.year && $0.weekOfYear == d.weekOfYear})
        if weeks.count > 0{
            return weeks[0]
        }else{
            return nil
        }
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

        
        // see if can use cache
        if weekCache.count > 0{
            //we have a cache. Just need to see if we need to add more weeks
            if weekCache[weekCache.count-1].endOfWeek >= date{
                // it's upto date
                return weekCache.filter({$0.startOfWeek <= date})
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


    // MARK:- Functional Fitness Test

    func nextFunctionalFitnessTest() -> Workout{
        let incomplete: [Workout] = CoreDataStackSingleton.shared.incompleteWorkouts().filter({$0.type == WorkoutType.FFT.rawValue})
        if incomplete.count > 0{
            return incomplete[0]
        }else{
            // really shouldn't get to this point as the next test should be created when the last one was saved
            print("Shouldn't really get here (except in creation of test data): WorkoutManager.nextFunctionFitnessTest as the next test should have been created")
            let tests: [Workout] = CoreDataStackSingleton.shared.getFunctionalFitnessTests().sorted(by: {$0.date! > $1.date!})
            if tests.count > 0{
                let _: Bool = createNextFunctionalFitnessTest(after: tests[0])
                // have created next workout so call this method re-cursively
                return nextFunctionalFitnessTest()
            }else{
                // no tests at all
                let newTest: Workout = createWorkout(forDate: Date(), session: defaultWorkout(forType: .FFT)!)
                //save it before returning
                CoreDataStackSingleton.shared.save()
                return newTest
            }
        }
    }
    
    func createNextFunctionalFitnessTest(after: Workout) -> Bool{
        // aim for tests every 4 weeks
        let fourWeeksOn: Date = calendar.date(byAdding: DateComponents(day: 28), to: after.date!)!
        let test: Workout = createWorkout(forDate: fourWeeksOn, session: after.getProgression(forType: .FFT)!)
        after.nextWorkout = test
        test.previousWorkout = after
        let newPowerUp: Bool = checkforPowerups()
        CoreDataStackSingleton.shared.save()
        return newPowerUp
    }
    

    
    // MARK:- Workouts
    
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
                return createNextWorkout(after: workouts[0])
            }else{
                
                let newWorkout: Workout = createWorkout(forDate: Date(), session: defaultWorkout(forType: .DescendingReps)!)
                //save it before returning
                CoreDataStackSingleton.shared.save()
                return newWorkout
            }
        }
    }
    
    // this figures out when the next workout should be in this week. If enough workouts have been done in this week it will recursively call itself for the following week
    func nextWorkoutDate(onOrAfter d: Date) -> Date{
        if let week = getWeek(containingDate: d){
            if let d = week.nextConstistentDate(onOrAfter: d){
                return d
            }else{
                // recursively call successive weeks
                return nextWorkoutDate(onOrAfter: week.endOfWeek.tomorrow)
            }
        }else{
            // no week. So no workouts yet for the week containing this date
            // so return this date as a valid one for the date
            return d
        }
    }
    
    func createNextWorkout(after: Workout) -> Workout{
        let nextDate: Date = nextWorkoutDate(onOrAfter: after.date!.tomorrow)
        let type: WorkoutType = after.type == WorkoutType.DescendingReps.rawValue ? WorkoutType.ConstantReps : WorkoutType.DescendingReps
        
        // make sure provided workout has been connected to previous
        if let w = getWeek(containingDate: after.date!){
            w.connectUpWorkouts()
        }
        
        var workout: Workout?
        
        if let progression = after.getProgression(forType: type){
            workout = createWorkout(forDate: nextDate, session: progression)
        }else{
            workout = createWorkout(forDate: nextDate, session: defaultWorkout(forType: type)!)
        }
        
        CoreDataStackSingleton.shared.save()
        if let w = getWeek(containingDate: nextDate){
            w.connectUpWorkouts()
            CoreDataStackSingleton.shared.save()
        }
        return workout!
    }
    
    
    private func createWorkout(forDate date: Date, session: WorkoutDefinition) -> Workout{
        let workout: Workout = CoreDataStackSingleton.shared.newWorkout()
        workout.date = date
        workout.type = session.type.rawValue
        
        switch session.type{
        case .FFT:
            return populateFunctionalFitnessTes(inWorkout: workout, withExercises: session.exercises)
        case .DescendingReps:
            return populateDescendingReps(inWorkout: workout, withExercises: session.exercises)
        case .ConstantReps:
            return populateConstantReps(inWorkout: workout, withExercises: session.exercises)
        }
        
    }
    
    private func populateDescendingReps(inWorkout workout: Workout, withExercises exercises: [WorkoutExerciseDefinition]) -> Workout{

        // for now lets create one of each type
        var order: Int16 = 0
        for e in exercises{
            let exercise: Exercise = CoreDataStackSingleton.shared.newExercise()
            let definition: ExerciseDefinition = ExerciseDefinitionManager.shared.exerciseDefinition(for: e.type)
            exercise.order = order
            exercise.type = e.type.rawValue
            workout.addToExercises(exercise)
            let maxReps: Int16 = Int16(e.plan)
            var setOrder: Int16 = 0
            for r in (1...maxReps).reversed(){
                let exerciseSet: ExerciseSet = CoreDataStackSingleton.shared.newExerciseSet(forType: definition.setType)
                exerciseSet.order = setOrder
                exerciseSet.plannedKG = e.kg
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

    
    private func populateConstantReps(inWorkout workout: Workout, withExercises exercises: [WorkoutExerciseDefinition]) -> Workout{
        
        // for now lets create one of each type
        var order: Int16 = 0
        for e in exercises{
            let exercise: Exercise = CoreDataStackSingleton.shared.newExercise()
            let definition: ExerciseDefinition = ExerciseDefinitionManager.shared.exerciseDefinition(for: e.type)
            exercise.order = order
            exercise.type = e.type.rawValue
            workout.addToExercises(exercise)
            for r in 1...3{
                let exerciseSet: ExerciseSet = CoreDataStackSingleton.shared.newExerciseSet(forType: definition.setType)
                exerciseSet.order = Int16(r-1)
                exerciseSet.plannedKG = e.kg
                exerciseSet.plan = e.plan
                // set actual to the plan as unless the changes this it's assumed they do the plan
                exerciseSet.actualKG = exerciseSet.plannedKG
                exercise.addToSets(exerciseSet)
            }
            order += 1
        }
        return workout
    }
    
    private func populateFunctionalFitnessTes(inWorkout workout: Workout, withExercises exercises: [WorkoutExerciseDefinition]) ->  Workout{
        workout.isTest = true
        var order: Int16 = 0
        for fft in exercises{
            let exercise: Exercise = CoreDataStackSingleton.shared.newExercise()
            let definition: ExerciseDefinition = ExerciseDefinitionManager.shared.exerciseDefinition(for: fft.type)
            let exerciseSet: ExerciseSet = CoreDataStackSingleton.shared.newExerciseSet(forType: definition.setType)
            exerciseSet.order = 0
            exerciseSet.plan = fft.plan
            exerciseSet.plannedKG = fft.kg
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
    
    // MARK:- Power Ups
    
    func weeksForNextDefencePowerUp() -> Int{
        let powerUps: [PowerUp] = CoreDataStackSingleton.shared.getPowerUps().sorted(by: {$0.defense > $1.defense})
        var currentPowerUp: Int16 = 0
        if powerUps.count > 0{
            currentPowerUp = powerUps[0].defense
        }
        // sum of first n integers formula - based on next powerup - ie currentPowerUp+1
        let weeksForNextPower: Int  = Int(0.5 * Double(currentPowerUp + 1) * Double(currentPowerUp + 2))
        
        return weeksForNextPower - currentStreakData().current
    }
    
    func sessionsForNextAttackPowerUp() -> (sessions: Int, repsXKg: Int){
        let powerUps: [PowerUp] = CoreDataStackSingleton.shared.getPowerUps().sorted(by: {$0.attack > $1.attack})
        var currentPowerUp: Int16 = 0
        if powerUps.count > 0{
            currentPowerUp = powerUps[0].attack
        }
        // sum of first n integers formula - based on next powerup - ie currentPowerUp+1
        let targetEdNum: Int  = Int(0.5 * Double(currentPowerUp + 1) * Double(currentPowerUp + 2))
        let edHistory: EddingtonCalculator.EddingtonHistory = attackPowerUpEdSeries()
        let numberContributingToTargetEdNum: Int = edHistory.ltdHistory.filter({$0.contributor >= Double(targetEdNum)}).count
        let plusOne = targetEdNum - numberContributingToTargetEdNum
        return (plusOne, targetEdNum)
    }
    
    func checkforPowerups() -> Bool{
        return checkforPowerups(toDate: Date())
    }
    
    private func attackPowerUpEdSeries() -> EddingtonCalculator.EddingtonHistory{
        return EddingtonCalculator().eddingtonHistory(timeSeries: timeSeries(forExeciseType: .ALL, andMeasure: .maxRepKG))
    }
    
    private func checkforPowerups(toDate date: Date) -> Bool{
        // NB power-up is based on n where the sum of the first n integers is the week streak (for defence)
        // and the eddington number (for attack). This is to make power-ups progressively harder to get
        // This is double whammy for attack since eddington number itself gets ever harder. However since
        // we're using Reps X KG the eddington number could get large - imagine 20 reps of 20kg ... this would
        // be 400 ... accumulating 400 workouts of that level is not unrealistic
        // by doing this we keep the power-ups smaller numbers
        /*
         For a given streak or ed number X we want to find n such that the sum of the first n integers equal X.
         This means we want: 0.5 * n * (n+1) = X
         => n * (n + 1) = 2X
         => n^2 + n - 2X = 0
         Using formula for quadratic and taking the positive root we get:
         n = (-1 + Sqrt(1 + 8X)) / 2
         We take the Int value of this
         */
        print("Checking whether to update power ups to \(date)")
        let orderWeeks: [Week] = getWeeks(toDate: date).sorted(by: {$0.startOfWeek < $1.startOfWeek})
        let maxStreak: Int16 = Int16(Double(orderWeeks.reduce(0, {max($0, $1.recursivelyCalculateConsistencyStreak(toDate: date))})))
        let maxRepKGEdNum: Int16 = Int16(attackPowerUpEdSeries().eddingtonNumber)
        let orderedPowerUps: [PowerUp] = CoreDataStackSingleton.shared.getPowerUps().sorted(by: {$0.date! < $1.date!})
        
        // power ups using n = (-1 +sqrt(1 + 8X)) / 2
        let possibleDefencePUp: Int16 = Int16((-1.0 + Double(1 + 8 * maxStreak).squareRoot())/2.0)
        let possibleAttackPUp: Int16 =  Int16((-1.0 + Double(1 + 8 * maxRepKGEdNum).squareRoot())/2.0)
        
        var newDefence: Int16?
        var newAttack: Int16?
        var date: Date?
        
        if orderedPowerUps.count == 0{
            if maxStreak + maxRepKGEdNum > 0{
                newDefence = possibleDefencePUp
                newAttack = possibleAttackPUp
                if orderWeeks.count > 0{
                    date = orderWeeks[orderWeeks.count - 1].startOfWeek
                }else{
                    date = Date()
                }
            }
        }else{
            let cPUp = orderedPowerUps[orderedPowerUps.count - 1]
            if possibleDefencePUp > cPUp.defense || possibleAttackPUp > cPUp.attack{
                newDefence = max(possibleDefencePUp, cPUp.defense)
                newAttack = max(possibleAttackPUp, cPUp.attack)
                if orderWeeks.count > 0{
                    date = orderWeeks[orderWeeks.count - 1].startOfWeek
                }else{
                    date = Date()
                }
            }
        }
        
        if let defense = newDefence{
            if let attack = newAttack{
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

    func saveLatestPowerUpToCloud(){
        let powerUps: [PowerUp] = CoreDataStackSingleton.shared.getPowerUps().sorted(by: {$0.date! > $1.date!})
        if powerUps.count > 0{
            let attack = powerUps[0].attack
            let defence = powerUps[0].defense
            if let user = Auth.auth().currentUser{
                if let ref = firebaseRef{
                    ref.child("users").child(user.uid).child("attack").setValue(attack)
                    ref.child("users").child(user.uid).child("defence").setValue(defence)
                    print("Updated power-ups to DEFENCE:\(defence)~ATTACK:\(attack) for user with uid: \(user.uid)")
                }
            }else{
                print("no user logged in so can't save power-ups")
            }
        }else{
            print("no power-ups to save")
        }
    }
    
    // MARK:- Init

    private init(){
        firebaseRef = Database.database().reference()
        if let user = Auth.auth().currentUser{
            print("User logged in with uid: \(user.uid)")
            print(firebaseRef!.child("users").child(user.uid).child("attack").observe(.value, with: { (data) in
                print(data)
            }))
            print(firebaseRef!.child("users").child(user.uid).child("defence").observe(.value, with: { (data) in
                print(data)
            }))
        }
    }
    
    // MARK:- Creating Test Data
    
    func createTestDataUsingBuiltInProgresions(){
        var d: Date = calendar.date(byAdding: DateComponents(year: -1), to: Date())!.startOfWeek
        let firstDate: Date = d
        let interval: DateComponents = DateComponents(day: 28)
        // clear any existing workouts
        let existing: [Workout] = CoreDataStackSingleton.shared.getChronologicalOrderedWorkouts(ofType: nil, isTest: nil)
        for e in existing{
            CoreDataStackSingleton.shared.delete(e)
        }
        CoreDataStackSingleton.shared.save()
        
        // create tests first
        let firstTest: Workout = nextFunctionalFitnessTest()
        var currentTest: Workout = firstTest
        firstTest.date = d
        firstTest.complete = true
        // lets do this first one bang on
        for e in firstTest.orderedExerciseArray(){
            for es in e.exerciseSets(){
                es.actual = es.plan
                es.actualKG = es.plannedKG
            }
        }
        CoreDataStackSingleton.shared.save()
        d = calendar.date(byAdding: interval, to: d)!
        
        while d < Date(){
            currentTest = nextFunctionalFitnessTest()
            currentTest.complete = true
            let rdn: Int = Int.random(in: 0...100)
            var factor: Double = 1.0
            if rdn <= 15{
                factor = 1.05
            }else if rdn <= 40{
                factor = 0.8
            }
            for e in currentTest.orderedExerciseArray(){
                for es in e.exerciseSets(){
                    es.actual = es.plan * factor
                    es.actualKG = es.plannedKG * factor
                }
            }
            CoreDataStackSingleton.shared.save()
            d = calendar.date(byAdding: interval, to: d)!
        }

        
        // now for workouts.
        var workout: Workout = createNextWorkout(after: firstTest)
        // this is to track max value so chance of failure is only used if at the max or above
        var maxDictionary: [ExerciseType: (actual: Double, actualKG: Double)] = [:]
        // populate with zeroes
        for t in ExerciseType.allCases{
            let setType: SetType = ExerciseDefinitionManager.shared.exerciseDefinition(for: t).setType
            if setType.moreIsBetter(){
                maxDictionary[t] = (actual: 0.0, actualKG: 0.0)
            }else{
                // really only touches case where we want minimums
                maxDictionary[t] = (10.0, 0.0)
            }
        }
        while workout.date! < Date(){
            let daysSinceFirstDate: Double = Double(Calendar.current.dateComponents([.day], from: firstDate, to: workout.date!).day!)
            // probability of failure needs to increase as we progress and weights get tougher. This function is asymptotic to 1.
            // after 365 days it's ~ 70% chance of failing
            let probabilityOfFailure: Double = daysSinceFirstDate / (150 + daysSinceFirstDate)
            print("Probability of failure: \(probabilityOfFailure)")
            if Double.random(in: 0...1) < probabilityOfFailure{
                // fail
                let factor: Double = Double.random(in: 0.4...0.8)
                for e in workout.orderedExerciseArray(){
                    let maximums = maxDictionary[e.exerciseType()]
                    let exerciseDefinition: ExerciseDefinition = ExerciseDefinitionManager.shared.exerciseDefinition(for: e.exerciseType())
                    let setType: SetType = exerciseDefinition.setType
                    switch setType{
                    case .Distance, .Time:
                        for es in e.exerciseSets(){
                            es.actualKG = es.plannedKG
                            if es.plan >= maximums?.actual ?? 0.0{
                                es.actual = es.plan * factor
                            }else{
                                es.actual = es.plan
                            }
                        }
                    case .Reps:
                        for es in e.exerciseSets(){
                            es.actualKG = es.plannedKG
                            if exerciseDefinition.usesWeight{
                                if es.actualKG >= maximums?.actualKG ?? 0.0 {
                                    // use Int here to make sure it's an exact number of reps
                                    es.actual = Double(Int(es.plan * factor))
                                }else{
                                    es.actual = es.plan
                                }
                            }else{
                                if es.plan >= maximums?.actual ?? 0.0{
                                    // use Int here to make sure it's an exact number of reps
                                    es.actual = Double(Int(es.plan * factor))
                                }else{
                                    es.actual = es.plan
                                }
                            }
                        }
                    case .Touches:
                        for es in e.exerciseSets(){
                            es.actualKG = es.plannedKG
                            if es.plan <= maximums?.actual ?? 0.0{
                                es.actual = es.plan + 1
                            }else{
                                es.actual = es.plan
                            }
                        }
                    case .All:
                        // shouldn't get here
                        print("Shouldn't get this case when generating workouts in WorkoutManager.shared.createTestDataUsingBuiltInProgresions()")
                    }
                }
            }else{
                // success
                for e in workout.orderedExerciseArray(){
                    let setType: SetType = ExerciseDefinitionManager.shared.exerciseDefinition(for: e.exerciseType()).setType
                    for es in e.exerciseSets(){
                        es.actualKG = es.plannedKG
                        es.actual = es.plan
                        // update maxes
                        let current = maxDictionary[e.exerciseType()]
                        if setType.moreIsBetter(){
                            maxDictionary[e.exerciseType()] = (max(current?.actual ?? 0.0, es.actual), max(current?.actualKG ?? 0.0, es.actualKG))
                        }else{
                            // touches. So want to track the least touches
                            maxDictionary[e.exerciseType()] = (min(current?.actual ?? 10.0, es.actual), max(current?.actualKG ?? 0.0, es.actualKG))
                        }
                    }
                }
            }
            workout.complete = true
            CoreDataStackSingleton.shared.save()
            // randomly add an extra workout to ensure some weeks are not consistent.
            // don't want too many ... so say 1 in 50 chance
            if let w = getWeek(containingDate: workout.date!){
                // check if week already has 3 workouts. If we add a workout prior to it already having 3
                // then the createNextWorkout method will still make the week consistent
                if w.dateOrderWorkouts.count > 2{
                    if Double.random(in: 0...1) < 0.1{
                        let d: Date = workout.date!
                        workout = createNextWorkout(after: workout)
                        // ensure in same week
                        workout.date = d
                        workout.complete = true
                        // complete the workout
                        for e in workout.orderedExerciseArray(){
                            for es in e.exerciseSets(){
                                es.actual = es.plan
                                es.actualKG = es.plannedKG
                            }
                        }
                        CoreDataStackSingleton.shared.save()
                        print("Added extra workout: \(d)")
                    }
                }
            }
            
            if checkforPowerups(toDate: workout.date!){
                print("Powerup gained on \(workout.date!)")
            }

            workout = createNextWorkout(after: workout)
        }
        // make sure the next planned test is in place
        let nextTest = nextFunctionalFitnessTest()
        currentTest.nextWorkout = nextTest
        nextTest.previousWorkout = currentTest
        CoreDataStackSingleton.shared.save()
        print(nextFunctionalFitnessTest())

    }
    
    func createTestWorkoutData(){
        var d: Date = calendar.date(byAdding: DateComponents(year: -1), to: Date())!.startOfWeek
        let interval: DateComponents = DateComponents(day: 28)
        var previous: Workout?
        let probTestKeepsWeekConsistent: Double = 0.9
        let progression: [ExerciseType: [Double]] = [.gobletSquat: [5, 6, 7, 7, 8, 9, 10, 12, 14, 14, 15, 16, 17, 20],
                                                     .lunge: [5,7,10, 12, 12, 14, 15, 15, 16, 18, 20, 20, 22, 22],
                                                     .benchPress: [3, 4, 5, 6, 7, 8, 8, 10, 11, 12, 14, 15, 18, 20],
                                                     .pressUp: [5, 5, 6, 6, 7, 8, 9, 10, 10, 10, 11, 12, 15, 16],
                                                     .pullDown: [5, 6, 6, 5, 6, 7, 8, 8, 8, 9, 10, 12, 12, 15]]
        
        let testProgression: [ExerciseType: [Double]] = [.standingBroadJump: [1, 1.1, 1.2, 1.3, 1.4, 1.45, 1.45, 1.5, 1.6, 1.6, 1.65, 1.65, 1.67, 1.7],
                                                         .deadHang: [20.0, 23.0, 28.0, 33.0, 33.0, 35.0, 38.0, 43.0, 45.0, 46.0, 48, 49, 50, 55],
                                                         .farmersCarry: [75.0, 80.0, 90.0, 93.0, 101.0, 102.0, 103.0, 107.0, 112.0, 115.0, 115, 125, 129, 130],
                                                         .plank: [15.0, 25.0, 35.0, 36.0, 37.0, 38.0, 40.0, 41.0, 45.0, 50.0, 53, 55, 57, 60],
                                                         .squat: [21.0, 22.0, 25.0, 27.0, 27.0, 30.0, 40.0, 41.0, 43.0, 45.0, 50, 60, 59, 65],
                                                         .sittingRisingTest: [4, 5, 3, 4, 3, 2, 2, 2, 1, 0, 0, 0, 0, 0]]
        
        for i in 0..<progression[.gobletSquat]!.count{
            // create tests
            var fft: Workout?
            if d <= Date(){
                // only create if on or before today
                fft = createWorkout(forDate: d, session: defaultWorkout(forType: .FFT)!)
                if let p = previous{
                    p.nextWorkout = fft
                    fft!.previousWorkout = p
                }
                for (key, value) in testProgression{
                    if let s = fft!.exercises(ofType: key)[0].exerciseSet(atOrder: 0){
                        s.actual = value[i]
                    }
                }
                fft!.complete = true
                previous = fft
            }
            
            // create weekly workouts
            for wkNumber in 0...3{
                let date: Date = calendar.date(byAdding: DateComponents(day: wkNumber * 7), to: d)!
                var workoutNumber: Int = 0
                var firstDayOfWeek: Bool = true
                for wkDate in createRandomDaysOfWeek(fromDate: date){
                    if wkDate > Date(){
                        break
                    }
                    // this is ensure when we have a test we don't create an additional workout and thus an inconsistent week
                    // note there's a chance of an inconsistent week just to give some realism to the data
                    if fft != nil && firstDayOfWeek && wkNumber == 0 && Double.random(in: 0...1) < probTestKeepsWeekConsistent{
                        fft?.date = wkDate
                    }else{
                        let w: Workout = createWorkout(forDate: wkDate, session: WorkoutDefinition(type: .DescendingReps, exercises:[
                            WorkoutExerciseDefinition(type: .gobletSquat, plan: 5, kg: 4.0, planProgression: 0.0, kgProgression: 2.0),
                            WorkoutExerciseDefinition(type: .lunge, plan: 5, kg: 4.0, planProgression: 0.0, kgProgression: 2.0),
                            WorkoutExerciseDefinition(type: .benchPress, plan: 5, kg: 4.0, planProgression: 0.0, kgProgression: 2.0),
                            WorkoutExerciseDefinition(type: .pressUp, plan: progression[.pressUp]![i], kg: 0.0, planProgression: 1.0, kgProgression: 0.0),
                            WorkoutExerciseDefinition(type: .pullDown, plan: 5, kg: 4.0, planProgression: 0.0, kgProgression: 2.0),
                            ]))
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
                    }
                    CoreDataStackSingleton.shared.save()
                    workoutNumber += 1
                    firstDayOfWeek = false
                }
                let _: Bool = checkforPowerups(toDate: date)
            }
            d = calendar.date(byAdding: interval, to: d)!
        }
        
        
    }
    
    private func createRandomDaysOfWeek(fromDate d: Date) -> [Date]{
        let workoutDaysOfWeek: [[Int]] = [[0,2,5], [0,3,5], [1,2,5], [1,3,5], [1,4,6]]
        let weekly = workoutDaysOfWeek[Int.random(in: 0..<workoutDaysOfWeek.count)]
        var result: [Date] = []
        for dayOfWeek in weekly{
            result.append(calendar.date(byAdding: DateComponents(day: dayOfWeek), to: d.startOfWeek)!)
        }
        return result
    }
}
