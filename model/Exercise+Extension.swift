//
//  Exercise+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 02/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension Exercise{
    
    var totalPlanKG: Double{
        get{
            return exerciseSets().reduce(0.0, {$0 + $1.totalPlanKG})
        }
    }
    
    var totalActualKG: Double{
        get{
            return exerciseSets().reduce(0.0, {$0 + $1.totalActualKG})
        }
    }
    
    var percentageComplete: Double{
        get{
            if exerciseDefinition.setType.moreIsBetter(){
                let aKG: Double = exerciseSets().reduce(0.0, {$0 + $1.actual * max(1.0, $1.actualKG)})
                let pKG: Double = exerciseSets().reduce(0.0, {$0 + $1.plan * max(1.0, $1.plannedKG)})
                if pKG > 0{
                    return aKG / pKG
                }
            }else if exerciseSets().count > 0{
                return exerciseSets().reduce(0.0, {$0 + $1.percentageComplete}) / Double(exerciseSets().count)
            }
            return 1.0
        }
    }
    
    
    var exerciseDefinition: ExerciseDefinition{
        return ExerciseDefinitionManager.shared.exerciseDefinition(for: exerciseType())
    }
    
    var date: Date?{ return workout?.date}
    
    func valueFor(exerciseMeasure measure: ExerciseMeasure) -> Double{
        switch measure{
        case .avKG:
            let kgXrep: Double = exerciseSets().reduce(0.0, {$0 + $1.actualKG * $1.actual})
            let totalRep: Double = exerciseSets().reduce(0.0, {$0 + $1.actual})
            if totalRep > 0{
                return kgXrep / totalRep
            }else{
                return 0.0
            }
        case .maxKG:
            return exerciseSets().reduce(0.0,{ max($0, $1.actualKG)})
        case .minKG:
            return exerciseSets().reduce(0.0, {min($0, $1.actualKG)})
        case .totalRepKG: return exerciseSets().reduce(0.0, {$0 + $1.actual * $1.actualKG})
        case .totalReps:
            return exerciseSets().reduce(0.0, {$0 + $1.actual})
        case .avReps:
            let count: Double = Double(exerciseSets().count)
            if count > 0{
                return valueFor(exerciseMeasure: .totalReps) / count
            }else{
                return 0.0
            }
        case .minReps: return exerciseSets().reduce(0.0, {min($0, $1.actual)})
        case .maxReps: return exerciseSets().reduce(0.0, {max($0, $1.actual)})
        default: return 0.0 // temp implementation
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
