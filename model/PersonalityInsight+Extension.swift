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
        return iArray.count
    }
    
    func getInsight(forType type: String) -> Insight{
        for i in iArray{
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
        if index < iArray.count{
            return iArray[index]
        }
        return nil
    }

//    func numberOfInsights() -> Int{
//        var count: Int = 0
//        for i in iArray{
//            count = count + 1 + i.subInsightsArray().count
//        }
//        return count
//    }
    
    func printSummary(){
        print("\(type ?? "Not set")")
        for i in iArray{
            i.printSummary(tabCount: 1)
        }
    }
    
    private var iArray: [Insight]{
        let array = insights?.allObjects as? [Insight] ?? []
        return array.sorted(by: {$0.type! < $1.type!})
    }
}

extension PersonalityInsight: InsightCategoryProtocol{
    func numberOfInsights() -> Int {
        return iArray.count
    }
    
    func categoryName() -> String {
        return type ?? "not set"
    }
    
    func insightsArray() -> [InsightProtocol] {
        return iArray
    }
    
    func insight(atIndex index: Int) -> InsightProtocol? {
        return getInsight(atIndex: index)
    }
    
    func hasSubInsights() -> Bool{
        for s in insightsArray(){
            if s.subInsightsArray().count > 0{
                return true
            }
        }
        return false
    }
    
}
