//
//  EddingtonCalculator.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 17/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

class EddingtonCalculator{
    
    struct EddingtonHistory{
        var eddingtonNumber: Int
        var annualEddingtonNumber: Int
        var ltdHistory: [(date: Date, edNum: Int, plusOne: Int, contributor: Double)]
        var annualHistory: [(date: Date, edNum: Int, plusOne: Int, contributor: Double)]
        var annualSummary: [(year: Int, annualEdNum: Int, annualPlusOne: Int)]
    }
    
    func eddingtonHistory(timeSeries: [(date:Date, value: Double)]) -> EddingtonHistory{
    
        if timeSeries.count == 0{
            return EddingtonHistory(eddingtonNumber: 0, annualEddingtonNumber: 0, ltdHistory: [], annualHistory: [], annualSummary: [])
        }
        
        let cal: Calendar = Calendar(identifier: .iso8601)
        let sortedTS: [(date: Date, value: Double)] = timeSeries.sorted(by: {$0.date < $1.date})
        
        var currentYear: Int = cal.dateComponents([Calendar.Component.year], from: sortedTS[0].date).year!
        var edNum: Int = 0
        var annualEdNum: Int = 0
        var annualPlusOne: Int = 0
        var annualSummary: [(year: Int, annualEdNum: Int, annualPlusOne: Int)] = []
        var thisYearsAnnualContributorsToNext: [Double] = []
        var ltdContributorsToNext: [Double] = []
        var ltdHistory: [(date: Date, edNum: Int, plusOne: Int, contributor: Double)] = []
        var annualHistory: [(date: Date, edNum: Int, plusOne: Int, contributor: Double)] = []

        for i in sortedTS{
            let year: Int = cal.dateComponents([Calendar.Component.year], from: i.date).year!
            
            if year != currentYear{
                // store the annual number for the year
                annualSummary.append((currentYear, annualEdNum, annualPlusOne))
                // reset all the annual stuff
                currentYear = year
                annualEdNum = 0
                thisYearsAnnualContributorsToNext = []
            }
            
            // figure out any changes to LTD eddinton number
            if i.value >= Double(edNum + 1){
                // this contributes to the LTD eddington number
                ltdContributorsToNext.append(i.value)
                // calculate how many more we need to increase the eddington number by 1.
                var plusOne: Int = (edNum + 1) - ltdContributorsToNext.count
                if plusOne == 0{
                    // this means we have a new Eddington number
                    edNum += 1
                    // need to remove all elemenst that no longer contribute to the next
                    ltdContributorsToNext = ltdContributorsToNext.filter({$0 >= Double(edNum+1)})
                    // recalc +1
                    plusOne = (edNum + 1) - ltdContributorsToNext.count
                }
                // add to history
                ltdHistory.append((i.date, edNum, plusOne, i.value))
            }
            
            // figure out any changes to Annual eddington number
            if i.value >= Double(annualEdNum + 1){
                // this contribues to the annual eddington number
                thisYearsAnnualContributorsToNext.append(i.value)
                annualPlusOne = (annualEdNum + 1) - thisYearsAnnualContributorsToNext.count
                if annualPlusOne == 0{
                    // this means we have a new eddington number
                    annualEdNum += 1
                    // need to remove non contributors to this new ed num
                    thisYearsAnnualContributorsToNext = thisYearsAnnualContributorsToNext.filter({$0 >= Double(annualEdNum + 1)})
                    // recalc +1
                    annualPlusOne = (annualEdNum + 1) - thisYearsAnnualContributorsToNext.count
                }
                // add to history
                annualHistory.append((i.date, annualEdNum, annualPlusOne, i.value))
            }
        }
        // add the current state of the final annual number
        annualSummary.append((currentYear, annualEdNum, annualPlusOne))
     
        return EddingtonHistory(eddingtonNumber: edNum, annualEddingtonNumber: annualEdNum, ltdHistory: ltdHistory, annualHistory: annualHistory, annualSummary: annualSummary)
    }
    
}
