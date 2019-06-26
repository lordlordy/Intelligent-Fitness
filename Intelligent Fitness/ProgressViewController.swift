//
//  ProgressViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 25/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit
import HealthKit

class ProgressViewController: UIViewController {

    private var calories: [(key: Date, value: Double)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getActiveCalories()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func getActiveCalories(){
        let calendar = Calendar.current
        var interval = DateComponents()
        let today = Date()
        interval.day = 1
        
        var anchorComponents = calendar.dateComponents([.day, .month, .year, .hour, .minute, .second], from: today)
        print(anchorComponents)
        anchorComponents.hour = 2  // to account for change in summer time - don't want removal of an hour to take us to previous day
        anchorComponents.minute = 0
        anchorComponents.second = 0
        print(anchorComponents)
        
        guard let anchorDate = calendar.date(from: anchorComponents) else{
            fatalError("!!! unable to create valid date from anchor components !!!")
        }
        
        print(anchorDate)
        
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            fatalError("!!! unable to create activeEnergyBurned type !!!")
        }
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: nil, options: .cumulativeSum, anchorDate: anchorDate, intervalComponents: interval)
        
        query.initialResultsHandler = {
            query, results, error in
            
            guard let statsCollection = results else{
                print("!!! error occurred getting active daily calorie burn")
                return
            }
            
            let tomorrow = calendar.date(byAdding: DateComponents(day: 1), to: today)
            
            var cals: [Date: Double] = [:]
            
            statsCollection.enumerateStatistics(from: Date.distantPast, to: tomorrow!, with: { (stats, stop) in
                if let quantity = stats.sumQuantity(){
                    let value = quantity.doubleValue(for: HKUnit.largeCalorie())
                    cals[stats.startDate] = value
//                    print("\(stats.startDate): \(value) Cals")
                }
            })
            self.calories = cals.sorted(by: {$0.key < $1.key})
            self.caloriesPopulated()
        }
        
        HKHealthStore().execute(query)
    }
    
    private func caloriesPopulated(){
        print(calories)
    }

}
