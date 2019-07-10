//
//  SessionManager.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 29/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

enum ExerciseType: Int, CaseIterable{
    case gobletSquat, lunge, benchPress, pushUp, pullDown
    func name() -> String{
        switch self{
        case .benchPress: return "Bench Press"
        case .gobletSquat: return "Goblet Squat"
        case .lunge: return "Lunge"
        case .pullDown: return "Pull Down"
        case .pushUp: return "Push Up"
        }
    }
    func usesWeights() -> Bool{
        switch self{
        case .pushUp: return false
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
        }
    }
}

class WorkoutManager{
    
    struct TestDefaults{
        var type: TestType
        var unitString: String
        var defaultGoal: Double
    }
  
//    private let functionalFitnessTestParts: [TestType] = [.StandingBroadJump, .DeadHang, .FarmersCarry, .Squat, .Plank, .SittingRisingTest]
    
    private let functionalFitnessTest: [TestDefaults] = [
        TestDefaults(type: .StandingBroadJump, unitString: "cm", defaultGoal: 100.0),
        TestDefaults(type: .DeadHang, unitString: "seconds", defaultGoal: 30.0),
        TestDefaults(type: .FarmersCarry, unitString: "metres", defaultGoal: 100.0),
        TestDefaults(type: .Plank, unitString: "seconds", defaultGoal: 30.0),
        TestDefaults(type: .Squat, unitString: "seconds", defaultGoal: 30.0),
        TestDefaults(type: .SittingRisingTest, unitString: "touches", defaultGoal: 2.0)
    ]
    
    func createFunctionalFitnessTest() -> TestSet{
        let testSet: TestSet = CoreDataStackSingleton.shared.newTestSet()
        testSet.date = Date()
        var order: Int16 = 0
        for fft in functionalFitnessTest{
            let test: Test = CoreDataStackSingleton.shared.newTest()
            test.name = fft.type.rawValue
            test.order = order
            test.resultUnit = fft.unitString
            test.goalResult = fft.defaultGoal
//            test.testSet = testSet
            if fft.type.hasKG(){
                test.kg = 10
            }
            testSet.addToTests(test)
            order += 1
        }
        return testSet
    }
    
    func nextWorkout() -> Workout{
        let incompleteWorkouts: [Workout] = CoreDataStackSingleton.shared.incompleteWorkouts()
        if incompleteWorkouts.count > 0{
            let result = incompleteWorkouts[0]
            // update date to today
            result.date = Date()
            return result
        }
        return createWorkout(onDate: Date())
    }

    func createWorkout(onDate date: Date) -> Workout{
        let workout: Workout = CoreDataStackSingleton.shared.newWorkout()
        workout.date = date
        workout.type = "Reducing Pyramid Set"
        workout.explanation = "This is an explanation"
        // for now lets create one of each type
        var order: Int16 = 0
        for e in ExerciseType.allCases{
            let kg = e.usesWeights() ? 10.0 : 0.0
            workout.addToExerciseSets(createReducingRepSet(ofType: e, kg: kg, reduceRepsFrom: 5, order: order))
            order += 1
        }
        
        return workout
    }

    func createReducingRepSet(ofType type: ExerciseType, kg: Double, reduceRepsFrom reps: Int16 , order setOrder: Int16) -> ExerciseSet{
        let exerciseSet: ExerciseSet = CoreDataStackSingleton.shared.newExcerciseSet()
        
        exerciseSet.name = "Reducing reps of \(kg) kg \(type.name())"
        
        var order: Int16 = 0
        for r in (1...reps).reversed(){
            exerciseSet.addToExercises(createExercise(ofType: type, kg: kg, reps: r, order: order))
            order += 1
        }
        exerciseSet.secondsRestBetweenExercises = 90
        if kg > 0{
            exerciseSet.explanation = "\(type.name().uppercased()): \(kg)kg"
        }else{
            exerciseSet.explanation = "\(type.name().uppercased())"
        }
        exerciseSet.order = setOrder
        
        return exerciseSet
    }
    
    func createExercise(ofType type: ExerciseType, kg: Double, reps: Int16, order: Int16) -> Exercise{
        let exercise = CoreDataStackSingleton.shared.newExercise()
        exercise.type = type.name()
        exercise.plannedKG = kg
        exercise.plannedReps = reps
        exercise.order = order
        return exercise
    }
    
}
