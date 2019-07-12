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
}

enum SetType: Int16{
    case Reps, Distance, Time, Touches
    func string(forValue d: Double) -> String{
        switch self{
        case .Reps: return "\(Int(d)) reps"
        case .Distance: return "\(d)m"
        case .Time: return "\(Int(d))s"
        case .Touches: return "\(Int(d)) touches"
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

class WorkoutManager{
    
    static var shared: WorkoutManager = WorkoutManager()
    
    struct ExerciseDefaults{
        var type: ExerciseType
        var defaultPlan: Double
        var defaultKG: Double
    }
    
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
    
    
    func nextFunctionalFitnessTest() -> Workout{
        let incomplete: [Workout] = CoreDataStackSingleton.shared.incompleteWorkouts().filter({$0.type == WorkoutType.FFT.rawValue})
        if incomplete.count > 0{
            return incomplete[0]
        }else{
            // really shouldn't get to this point as the next test should be created when the last one was saved
            print("Shouldn't really get here: WorkoutManager.nextFunctionFitnessTest as the next test should have been ")
            let tests: [Workout] = CoreDataStackSingleton.shared.getFunctionalFitnessTests().sorted(by: {$0.date! > $1.date!})
            if tests.count > 0{
                createNextFunctionalFitnessTest(after: tests[0])
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
    
    func createNextFunctionalFitnessTest(after: Workout){
        // aim for tests every 4 weeks
        let oneMonthFromNow: Date = Calendar.current.date(byAdding: DateComponents(day: 28), to: Date())!
        let test: Workout = createFunctionalFitnessTest(forDate: oneMonthFromNow)
        after.nextWorkout = test
        test.previousWorkout = after
        CoreDataStackSingleton.shared.save()
    }
    
    private func createFunctionalFitnessTest(forDate date: Date) ->  Workout{
        let workout: Workout = CoreDataStackSingleton.shared.newWorkout()
        workout.date = date
        workout.isTest = true
        workout.type = WorkoutType.FFT.rawValue
        var order: Int16 = 0
        for fft in functionalFitnessTest{
            let exercise: Exercise = CoreDataStackSingleton.shared.newExercise()
            let exerciseSet: ExerciseSet = CoreDataStackSingleton.shared.newExerciseSet()
            exerciseSet.order = 0
            exerciseSet.plan = fft.defaultPlan
            exerciseSet.plannedKG = fft.defaultKG
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
        let incomplete: [Workout] = CoreDataStackSingleton.shared.incompleteWorkouts().filter({$0.type == WorkoutType.DescendingReps.rawValue})
        if incomplete.count > 0{
            return incomplete[0]
        }else{
            // really shouldn't get to this point as the next test should be created when the last one was saved
            print("Shouldn't really get here: nextWorkout as the next workout should have been ")
            let workouts: [Workout] = CoreDataStackSingleton.shared.getWorkouts(ofType: nil, isTest: nil).sorted(by: {$0.date! > $1.date!})
            if workouts.count > 0{
                createNextWorkout(after: workouts[0])
                // have created next workout so call this method re-cursively
                return nextWorkout()
            }else{
                
                let newWorkout: Workout = createWorkout(forDate: Date())
                //save it before returning
                CoreDataStackSingleton.shared.save()
                return newWorkout
            }
        }
    }

    func createNextWorkout(after: Workout){
        // set for tomorrow
        let tomorrow: Date = Calendar.current.date(byAdding: DateComponents(day: 1), to: Date())!
        let workout: Workout = createWorkout(forDate: tomorrow)
        after.nextWorkout = workout
        workout.previousWorkout = after
        CoreDataStackSingleton.shared.save()
    }
    
    private func createWorkout(forDate date: Date) -> Workout{
        let workout: Workout = CoreDataStackSingleton.shared.newWorkout()
        workout.date = date
        workout.type = WorkoutType.DescendingReps.rawValue
        workout.explanation = "This is an explanation"
        // for now lets create one of each type
        var order: Int16 = 0
        for e in exerciseSet1{
            let exercise: Exercise = CoreDataStackSingleton.shared.newExercise()
            exercise.order = order
            exercise.type = e.type.rawValue
            workout.addToExercises(exercise)
            let maxReps: Int16 = Int16(e.defaultPlan)
            var setOrder: Int16 = 0
            for r in (1...maxReps).reversed(){
                let exerciseSet: ExerciseSet = CoreDataStackSingleton.shared.newExerciseSet()
                exerciseSet.order = setOrder
                exerciseSet.plannedKG = e.defaultKG
                exerciseSet.plan = Double(r)
                exercise.addToSets(exerciseSet)
                setOrder += 1
            }
            order += 1
        }
        
        return workout
    }

    private init(){}
    
}
