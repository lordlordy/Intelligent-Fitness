//
//  Exercise+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 02/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension Exercise{    
    
    static let percentageForReduction: Double = 0.75
    static let precentageForIncrease: Double = 0.99
    
    var percentageComplete: Double{
        let sets = exerciseSets()
        if sets.count == 1{
            return sets[0].percentageComplete
        }else{
            let numerator: Double = sets.reduce(0.0, {$0 + $1.percentageComplete * $1.actual})
            let denominator: Double = sets.reduce(0.0, {$0 + $1.plan})
            if denominator == 0.0{
                return 0.0
            }else{
                return numerator / denominator
            }
        }
    }

    
    var exerciseDefinition: ExerciseDefinition{
        return ExerciseDefinitionManager.shared.exerciseDefinition(for: exerciseType())
    }
    
    var date: Date?{ return workout?.date}
    private var plan: Double{
        return exerciseSet(atOrder: 0)?.plan ?? 0.0
    }
    private var plannedKG: Double{
        return exerciseSet(atOrder: 0)?.plannedKG ?? 0.0
    }
    
    
    func progression(basedOnDefinition definition: WorkoutExerciseDefinition) -> WorkoutExerciseDefinition{
        if percentageComplete <= 0.6{
            // failed badly - reduce by double
            return WorkoutExerciseDefinition(type: exerciseType(), plan: max(0,plan - definition.planProgression * 2) , kg: max(0, plannedKG - definition.kgProgression * 2), planProgression: definition.planProgression, kgProgression: definition.kgProgression)
        }else if percentageComplete <= 0.8{
            // failed - reduce exercise
            return WorkoutExerciseDefinition(type: exerciseType(), plan: max(0,plan - definition.planProgression) , kg: max(0, plannedKG - definition.kgProgression), planProgression: definition.planProgression, kgProgression: definition.kgProgression)
        }else if percentageComplete < percentageComplete{
            // close - try same again
            return WorkoutExerciseDefinition(type: exerciseType(), plan: plan , kg: plannedKG, planProgression: definition.planProgression, kgProgression: definition.kgProgression)
        }else{
            // near enough completed so progress
            return WorkoutExerciseDefinition(type: exerciseType(), plan: max(0, plan + definition.planProgression) , kg: max(0,plannedKG + definition.kgProgression), planProgression: definition.planProgression, kgProgression: definition.kgProgression)
        }
    }
    
    func getValue(forMeasure measure: ExerciseMeasure) -> Double{
        if exerciseSets().count == 0{
            return 0.0
        }
        switch measure.aggregator() {
        case .Sum:
            return exerciseSets().reduce(0.0, {$0 + $1.getValue(forMeasure: measure)})
        case .Max:
            return exerciseSets().reduce(0.0, {max($0, $1.getValue(forMeasure: measure))})
        case .Min:
            return exerciseSets().reduce(Double.greatestFiniteMagnitude, {min($0, $1.getValue(forMeasure: measure))})
        case .Average:
            if measure.weighted(){
                let numerator: Double = exerciseSets().reduce(0.0, {$0 + $1.getValue(forMeasure: measure) * $1.actual})
                let denominator: Double = exerciseSets().reduce(0.0, {$0 + $1.actual})
                if denominator == 0.0{
                    return 0.0
                }else{
                    return numerator / denominator
                }
            }else{
                return exerciseSets().reduce(0.0, {$0 + $1.getValue(forMeasure: measure)}) / Double(exerciseSets().count)
            }
        }
    }
    
    func totalActual(forSetType st: SetType) -> Double{
        if st == exerciseDefinition.setType{
            return exerciseSets().reduce(0.0, {$0 + $1.actual})
        }else{
            return 0.0
        }
    }
    
    func numberOfSets() -> Int{
        return sets?.count ?? 0
    }
    
    func exerciseSet(atOrder order: Int16) -> ExerciseSet?{
        for set in exerciseSets(){
            if set.order == order{
                return set
            }
        }
        return nil
    }
    
    func exerciseType() -> ExerciseType{
        return ExerciseType(rawValue: type)!
    }
    

    
    func exerciseFinished() -> Bool {
        return endedEarly || exerciseCompleted()
    }

    func exerciseCompleted() -> Bool {
        for r in exerciseSets(){
            if !r.setCompleted(){
                return false
            }
        }
        return true
    }
    
    func summary() -> String{
        if numberOfSets() == 1{
            return "\(exerciseDefinition.name): \(exerciseSet(atOrder: 0)?.summary() ?? "no summary")"
        }
        return "Summary of exercise still to be written"
    }
    
    func exerciseSets() -> [ExerciseSet]{
        return sets?.allObjects as? [ExerciseSet] ?? []
    }

}
