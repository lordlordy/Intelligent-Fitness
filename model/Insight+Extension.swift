//
//  Insight+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 05/08/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

enum InsightProperty: String{
    case readings, subInsights
}

extension Insight{
    
    private var subIArray: [Insight]{
        return subInsights?.allObjects as? [Insight] ?? []
    }
    
    var insightReadingArray: [InsightReading]{
        let array = readings?.allObjects as? [InsightReading] ?? []
        return array.sorted(by: {$0.date! > $1.date!})
    }
    
    var currentReading: InsightReading{
        let sortedReadings = insightReadingArray.sorted(by: {$0.date! > $1.date!})
        return sortedReadings[0]
    }
    
    func remove(insightReading reading: InsightReading){
        CoreDataStackSingleton.shared.delete(reading)
        CoreDataStackSingleton.shared.save()
    }
    
    func setReading(toValue value: Double, forDate date: Date?){
        let readingDate: Date = date ?? Date()
        let newReading: InsightReading = reading(forDate: readingDate)
        newReading.date = readingDate
        newReading.percentile = value
        self.mutableSetValue(forKey: InsightProperty.readings.rawValue).add(newReading)
        CoreDataStackSingleton.shared.save()
    }
    
    func subCategory(atIndex index: Int) -> Insight?{
        if index < subIArray.count{
            return subIArray[index]
        }
        return nil
    }

    func getSubCategory(forType type: String) -> Insight{
        for i in subIArray{
            if i.type == type{
                return i
            }
        }
        let newInsight: Insight = CoreDataStackSingleton.shared.newInsight()
        newInsight.type = type
        self.mutableSetValue(forKey: InsightProperty.subInsights.rawValue).add(newInsight)
        CoreDataStackSingleton.shared.save()
        return newInsight
    }
    
    func printSummary(tabCount: Int){
        var str: String = ""
        for _ in 0..<tabCount{
            str += "\t"
        }
        print(str + (type ?? "No type set"))
        for r in insightReadingArray{
            print(str + "\(r.date!): \(r.percentile)")
        }
        if subIArray.count > 0{
            print(str + "CHILDREN:")
            for s in subIArray{
                s.printSummary(tabCount: tabCount+1)
            }
        }
    }
    
    // returns existing if one exists for this date otherwise returns a new one
    private func reading(forDate date: Date) -> InsightReading{
        for i in insightReadingArray{
            if Calendar.current.compare(i.date!, to: date, toGranularity: .day) == ComparisonResult.orderedSame{
                return i
            }
        }
        let newReading: InsightReading = CoreDataStackSingleton.shared.newInsightReading()
        newReading.date = date
        return newReading
    }
    
}

extension Insight: InsightProtocol{
    func name() -> String {
        return type ?? "Not Set"
    }
    
    func numberOfReadings() -> Int {
        return insightReadingArray.count
    }
    
    func mostRecentReading() -> (date: Date, value: Double) {
        return (date: currentReading.date!, value: currentReading.percentile)
    }
    
    func insightReadings() -> [(date: Date, value: Double)] {
        return insightReadingArray.map({($0.date!, $0.percentile)})
    }
    
    func subInsightsArray() -> [InsightProtocol] {
        return subIArray
    }
    
    func subInsight(atIndex index: Int) -> InsightProtocol?{
        return subCategory(atIndex: index)
    }
    
    func removeReading(forDate date: Date){
        for r in insightReadingArray{
            if Calendar.current.compare(date, to: r.date!, toGranularity: .day) == ComparisonResult.orderedSame{
                remove(insightReading: r)
                return
            }
        }
    }
    
    func setInsightReading(forDate date: Date, toValue value: Double){
        setReading(toValue: value, forDate: date)
    }
    
}
