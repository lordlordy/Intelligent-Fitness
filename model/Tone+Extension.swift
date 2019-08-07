//
//  Tone+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 06/08/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

enum ToneProperty: String{
    case readings
}

extension Tone{
 
    var readingArray: [ToneReading]{
        let array: [ToneReading] = readings?.allObjects as? [ToneReading] ?? []
        return array.sorted(by: {$0.date! > $1.date!})
    }
    
    var currentReading: ToneReading{
        return readingArray[0]
    }
    
    func summaryString() -> String{
        return "\(type!): \(currentReading.summaryString())"
    }
    
    func setReading(toValue value: Double, forDate date: Date?){
        let readingDate: Date = date ?? Date()
        let newReading: ToneReading = reading(forDate: readingDate)
        newReading.date = readingDate
        newReading.score = value
        self.mutableSetValue(forKey: ToneProperty.readings.rawValue).add(newReading)
        CoreDataStackSingleton.shared.save()
    }
    
    
    // returns existing if one exists for this date otherwise returns a new one
    private func reading(forDate date: Date) -> ToneReading{
        for i in readingArray{
            if Calendar.current.compare(i.date!, to: date, toGranularity: .day) == ComparisonResult.orderedSame{
                return i
            }
        }
        let newReading: ToneReading = CoreDataStackSingleton.shared.newToneReading()
        newReading.date = date
        return newReading
    }
    
}

extension Tone: InsightProtocol{
    func name() -> String {
        return type ?? ""
    }
    
    func numberOfReadings() -> Int {
        return readingArray.count
    }
    
    func mostRecentReading() -> (date: Date, value: Double) {
        return (currentReading.date!, currentReading.score)
    }
    
    func insightReadings() -> [(date: Date, value: Double)] {
        print(readingArray)
        return readingArray.map({($0.date!, $0.score)})
    }
    
    func subInsightsArray() -> [InsightProtocol] {
        return []
    }
    
    func subInsight(atIndex index: Int) -> InsightProtocol? {
        return nil
    }
    
    func removeReading(forDate date: Date) {
        for r in readingArray{
            if Calendar.current.compare(date, to: r.date!, toGranularity: .day) == ComparisonResult.orderedSame{
                CoreDataStackSingleton.shared.delete(r)
                CoreDataStackSingleton.shared.save()
                return
            }
        }
    }
    
    func setInsightReading(forDate date: Date, toValue value: Double) {
        setReading(toValue: value, forDate: date)
    }
    
    
}
