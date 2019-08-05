//
//  PersonalityInsight+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 05/08/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

enum PersonalityInsightProperty: String{
    case insights
}

extension PersonalityInsight{
    
    func getInsight(forType type: String) -> Insight{
        for i in insightsArray{
            if i.type == type{
                return i
            }
        }
        // no insight of this type yet
        let insight: Insight = CoreDataStackSingleton.shared.newInsight()
        insight.type = type
        self.mutableSetValue(forKey: PersonalityInsightProperty.insights.rawValue).add(insight)
        CoreDataStackSingleton.shared.save()
        return insight
    }

    func printSummary(){
        print("\(type ?? "Not set")")
        for i in insightsArray{
            i.printSummary(tabCount: 1)
        }
    }
    
    private var insightsArray: [Insight]{
        return insights?.allObjects as? [Insight] ?? []
    }
}
