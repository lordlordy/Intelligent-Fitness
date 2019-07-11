//
//  ExerciseDefinition.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 11/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

protocol ExerciseDefinition{
    var name: String { get }
    var setType: SetType { get }
    var usesWeight: Bool { get }

}

class ExerciseDefinitionManager{
    
    static let shared = ExerciseDefinitionManager()

    func exerciseDefinition(for type: ExerciseType) -> ExerciseDefinition{
        return dict[type]!
    }
    
    private struct ExerciseDefinitionImpl: ExerciseDefinition{
        var name: String
        var setType: SetType
        var usesWeight: Bool
    }
    private var dict: [ExerciseType: ExerciseDefinition] = [:]
    
    
    private init(){
        for e in ExerciseType.allCases{
            switch e{
            case .benchPress:
                dict[e] = ExerciseDefinitionImpl(name: "Bench Press", setType: .Reps, usesWeight: true)
            case .deadHang:
                dict[e] = ExerciseDefinitionImpl(name: "Dead Hang", setType: .Time, usesWeight: false)
            case .farmersCarry:
                dict[e] = ExerciseDefinitionImpl(name: "Farmers Carry", setType: .Distance, usesWeight: true)
            case .gobletSquat:
                dict[e] = ExerciseDefinitionImpl(name: "Goblet Squat", setType: .Reps, usesWeight: true)
            case .lunge:
                dict[e] = ExerciseDefinitionImpl(name: "Lunge", setType: .Reps, usesWeight: true)
            case .plank:
                dict[e] = ExerciseDefinitionImpl(name: "Plank", setType: .Time, usesWeight: false)
            case .pullDown:
                dict[e] = ExerciseDefinitionImpl(name: "Pull Down", setType: .Reps, usesWeight: true)
            case .pushUp:
                dict[e] = ExerciseDefinitionImpl(name: "Push Up", setType: .Reps, usesWeight: true)
            case .sittingRisingTest:
                dict[e] = ExerciseDefinitionImpl(name: "Sitting Rising Test", setType: .Touches, usesWeight: false)
            case .squat:
                dict[e] = ExerciseDefinitionImpl(name: "Squat", setType: .Time, usesWeight: false)
            case .standingBroadJump:
                dict[e] = ExerciseDefinitionImpl(name: "Standing Broad Jump", setType: .Distance, usesWeight: false)

            }
        }
        
    }
    
}