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
    
    var insightCount: Int{
        return insightsArray.count
    }
    
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
    
    func getInsight(atIndex index: Int) -> Insight?{
        if index < insightsArray.count{
            return insightsArray[index]
        }
        return nil
    }

    func numberOfInsights() -> Int{
        var count: Int = 0
        for i in insightsArray{
            count = count + 1 + i.subInsightArray.count
        }
        return count
    }
    
    func printSummary(){
        print("\(type ?? "Not set")")
        for i in insightsArray{
            i.printSummary(tabCount: 1)
        }
    }
    
    private var insightsArray: [Insight]{
        let array = insights?.allObjects as? [Insight] ?? []
        return array.sorted(by: {$0.type! < $1.type!})
    }
}
