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
    var description: String { get }
    var embedVideoHTML: String? { get }
}

enum ExerciseType: Int16, CaseIterable{
    case gobletSquat, lunge, benchPress, pressUp, pullDown, bentOverRow, sitUp, stepUp
    case standingBroadJump, plank, deadHang, farmersCarry, squat, sittingRisingTest
    case ALL
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
        var description: String
        var embedVideoHTML: String?
    }
    private var dict: [ExerciseType: ExerciseDefinition] = [:]
    
    
    private init(){
        for e in ExerciseType.allCases{
            switch e{
            case .stepUp:
                dict[e] = ExerciseDefinitionImpl(name: "Step Up", setType: .Reps, usesWeight: true, description: "a exercise description", embedVideoHTML: nil)
            case .sitUp:
                dict[e] = ExerciseDefinitionImpl(name: "Sit Up", setType: .Reps, usesWeight: false, description: "a exercise description", embedVideoHTML: nil)
            case .bentOverRow:
                dict[e] = ExerciseDefinitionImpl(name: "Bent Over Row", setType: .Reps, usesWeight: true, description: "a exercise description", embedVideoHTML: nil)
            case .benchPress:
                dict[e] = ExerciseDefinitionImpl(name: "Bench Press", setType: .Reps, usesWeight: true, description: "a exercise description", embedVideoHTML: nil)
            case .deadHang:
                dict[e] = ExerciseDefinitionImpl(name: "Dead Hang", setType: .Time, usesWeight: false, description: "a exercise description", embedVideoHTML: nil)
            case .farmersCarry:
                dict[e] = ExerciseDefinitionImpl(name: "Farmers Carry", setType: .Distance, usesWeight: true, description: "a exercise description", embedVideoHTML: nil)
            case .gobletSquat:
                dict[e] = ExerciseDefinitionImpl(name: "Goblet Squat", setType: .Reps, usesWeight: true, description: "a exercise description", embedVideoHTML: "<iframe width=\"951\" height=\"535\" src=\"https://www.youtube.com/embed/gXjNTLSVvGM\" frameborder=\"0\" allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen></iframe>")
            case .lunge:
                dict[e] = ExerciseDefinitionImpl(name: "Lunge", setType: .Reps, usesWeight: true, description: "a exercise description", embedVideoHTML: nil)
            case .plank:
                dict[e] = ExerciseDefinitionImpl(name: "Plank", setType: .Time, usesWeight: false, description: "a exercise description", embedVideoHTML: nil)
            case .pullDown:
                dict[e] = ExerciseDefinitionImpl(name: "Pull Down", setType: .Reps, usesWeight: true, description: "a exercise description", embedVideoHTML: nil)
            case .pressUp:
                dict[e] = ExerciseDefinitionImpl(name: "Push Up", setType: .Reps, usesWeight: false, description: "a exercise description", embedVideoHTML: nil)
            case .sittingRisingTest:
                dict[e] = ExerciseDefinitionImpl(name: "Sitting Rising Test", setType: .Touches, usesWeight: false, description: "a exercise description", embedVideoHTML: nil)
            case .squat:
                dict[e] = ExerciseDefinitionImpl(name: "Squat", setType: .Time, usesWeight: false, description: "a exercise description", embedVideoHTML: "<iframe width=\"951\" height=\"535\" src=\"https://www.youtube.com/embed/_izLJ0giePc\" frameborder=\"0\" allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen></iframe>")
            case .standingBroadJump:
                dict[e] = ExerciseDefinitionImpl(name: "Standing Broad Jump", setType: .Distance, usesWeight: false, description: "a exercise description", embedVideoHTML: nil)
            case .ALL:
                dict[e] = ExerciseDefinitionImpl(name: "All Exercises", setType: .All, usesWeight: true, description: "Aggregation across all exercise types", embedVideoHTML: nil)
            }
        }
        
    }
    
}
