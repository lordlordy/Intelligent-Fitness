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

    
    func name() -> String{
        switch self{
        case .benchPress: return "Bench Press"
        case .gobletSquat: return "Goblet Squat"
        case .lunge: return "Lunge"
        case .pullDown: return "Pull Down"
        case .pushUp: return "Push Up"
        case .standingBroadJump: return "Standing Broad Jump"
        case .plank: return  "Plank"
        case .deadHang: return "Dead Hang"
        case .farmersCarry: return "Farmers Carry"
        case .squat: return "Squat"
        case .sittingRisingTest: return "Sitting Rising Test"        }
    }
    
    func usesWeights() -> Bool{
        switch self{
        case .pushUp, .standingBroadJump, .plank, .deadHang, .squat, .sittingRisingTest: return false
        default: return true
        }
    }
    
    func exerciseDescription() -> String{
        switch self{
        case .benchPress:
            return "This is how you do a bench press"
        case .gobletSquat:
            return "This is how you do a goblet squat"
        case .lunge:
            return "This is how you do a lunge"
        case .pullDown:
            return "This is how you do a pull down"
        case .pushUp:
            return "This is how you do a push up"
        default:
            return "Need to sort out description for \(self)"
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
    
    struct ExerciseDefaults{
        var type: ExerciseType
        var exerciseType: ExerciseEntity
        var defaultPlan: Double
        var defaultKG: Double
    }
    
    private let functionalFitnessTest: [ExerciseDefaults] = [
        ExerciseDefaults(type: .standingBroadJump, exerciseType: .ExerciseDistance, defaultPlan: 100.0, defaultKG: 0.0),
        ExerciseDefaults(type: .deadHang, exerciseType: .ExerciseInterval , defaultPlan: 30.0, defaultKG: 0.0),
        ExerciseDefaults(type: .farmersCarry, exerciseType: .ExerciseDistance , defaultPlan: 100.0, defaultKG: 10.0),
        ExerciseDefaults(type: .plank, exerciseType: .ExerciseInterval, defaultPlan: 30.0, defaultKG: 0.0),
        ExerciseDefaults(type: .squat, exerciseType: .ExerciseInterval, defaultPlan: 30.0, defaultKG: 0.0),
        ExerciseDefaults(type: .sittingRisingTest, exerciseType: .ExerciseReps, defaultPlan: 2.0, defaultKG: 0.0)
    ]
    
    private let exerciseSet1: [ExerciseDefaults] = [
        ExerciseDefaults(type: .gobletSquat, exerciseType: .ExerciseReps, defaultPlan: 5, defaultKG: 5.0),
        ExerciseDefaults(type: .lunge, exerciseType: .ExerciseReps, defaultPlan: 5, defaultKG: 10.0),
        ExerciseDefaults(type: .benchPress, exerciseType: .ExerciseReps, defaultPlan: 5, defaultKG: 5.0),
        ExerciseDefaults(type: .pushUp, exerciseType: .ExerciseReps, defaultPlan: 5, defaultKG: 0.0),
        ExerciseDefaults(type: .pullDown, exerciseType: .ExerciseReps, defaultPlan: 5, defaultKG: 5.0),
    ]
    
    func createFunctionalFitnessTest() -> Workout{
        let workout: Workout = CoreDataStackSingleton.shared.newWorkout()
        workout.date = Date()
        workout.isTest = true
        workout.type = WorkoutType.FFT.rawValue
        var order: Int16 = 0
        for fft in functionalFitnessTest{
            let exercise: Exercise = CoreDataStackSingleton.shared.newExercise(forEntity: fft.exerciseType)
            let exerciseSet: ExerciseSet = CoreDataStackSingleton.shared.newExerciseSet(forEntity: fft.exerciseType)
            exerciseSet.order = 0
            exerciseSet.set(planned: fft.defaultPlan)
            exerciseSet.plannedKG = fft.defaultKG
            exercise.add(exerciseSet: exerciseSet)
            exercise.order = order
            exercise.type = fft.type.rawValue
            workout.addToExercises(exercise)
            order += 1
        }
        return workout
    }
    
    
    func nextWorkout() -> Workout{
        let incompleteWorkouts: [Workout] = CoreDataStackSingleton.shared.incompleteWorkouts()
        if incompleteWorkouts.count > 0{
            let result = incompleteWorkouts[0]
            // update date to today
            result.date = Date()
            return result
        }
        return createWorkout()
    }

    func createWorkout() -> Workout{
        let workout: Workout = CoreDataStackSingleton.shared.newWorkout()
        workout.date = Date()
        workout.type = WorkoutType.DescendingReps.rawValue
        workout.explanation = "This is an explanation"
        // for now lets create one of each type
        var order: Int16 = 0
        for e in exerciseSet1{
            let exercise: Exercise = CoreDataStackSingleton.shared.newExercise(forEntity: e.exerciseType)
            exercise.order = order
            workout.addToExercises(exercise)
            let maxReps: Int16 = Int16(e.defaultPlan)
            var setOrder: Int16 = 0
            for r in (1...maxReps).reversed(){
                let exerciseSet: ExerciseSet = CoreDataStackSingleton.shared.newExerciseSet(forEntity: e.exerciseType)
                exerciseSet.order = setOrder
                exerciseSet.plannedKG = e.defaultKG
                exerciseSet.set(planned: Double(r))
                exercise.add(exerciseSet: exerciseSet)
                setOrder += 1
            }
            order += 1
        }
        
        return workout
    }

    
}
