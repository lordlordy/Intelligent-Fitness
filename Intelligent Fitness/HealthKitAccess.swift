//
//  HealthKitSetUp.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 20/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import HealthKit

class HealthKitAccess {
    
    static let shared = HealthKitAccess()
    private let healthStore = HKHealthStore()
    
    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }
    
    private init(){}
    
    func getDOB() -> Date?{
        do{
            var birthdayComponents =  try healthStore.dateOfBirthComponents()
            birthdayComponents.hour = 3
            return Calendar.current.date(from: birthdayComponents)
        }catch{
            print(error)
            return nil
        }
    }

    func getSex() -> HKBiologicalSex?{
        do{
            return try healthStore.biologicalSex().biologicalSex
        }catch{
            print(error)
            return nil
        }
    }

    func getSexString() -> String?{
        if let sex = getSex(){
            switch sex{
            case .male: return "Male"
            case .female: return "Female"
            case .notSet: return "Not Set"
            case .other: return "Other"
            @unknown default:
                return "New Value"
            }
        }else{
            return "Not set"
        }
    }
    
    func getLatestKG(completion: @escaping (String, Double?, Date?) -> Swift.Void){
        getMostRecentSample(for: HKSampleType.quantityType(forIdentifier: .bodyMass)!) { (sample) in
            guard let sample = sample else{
                completion("not measured", nil, nil)
                return
            }
            let kg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            let date = sample.startDate
            let weightFormatter = MassFormatter()
            weightFormatter.isForPersonMassUse = true
            let kgString = weightFormatter.string(fromKilograms: kg)
            completion(kgString, kg, date)
        }
    }
    
    func getLatestHeightInMetres(completion: @escaping (String, Double?, Date?) -> Swift.Void){
        getMostRecentSample(for: HKSampleType.quantityType(forIdentifier: .height)!) { (sample) in
            guard let sample = sample else{
                completion("not measured", nil, nil)
                return
            }
            let height = sample.quantity.doubleValue(for: HKUnit.meter())
            let date = sample.startDate
            let mString = String(format: "%.2f m", height)
            completion(mString, height, date)
        }
    }
    
    func getLatestHRV(completion: @escaping (String, Double?, Date?) -> Swift.Void){
        getMostRecentSample(for: HKSampleType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!) { (sample) in
            guard let sample = sample else{
                completion("not measured", nil, nil)
                return
            }
            let hrv = sample.quantity.doubleValue(for: HKUnit(from: "ms"))
            let date = sample.startDate
            let hrvText = String(format: "%.1f ms", hrv)
            completion(hrvText, hrv, date)
        }
    }
    
    func getLatestRestingHR(completion: @escaping (String, Double?, Date?) -> Swift.Void){
        getMostRecentSample(for: HKSampleType.quantityType(forIdentifier: .restingHeartRate)!) { (sample) in
            guard let sample = sample else{
                completion("not measured", nil, nil)
                return
            }
            let beatsPerMinute = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            let date = sample.startDate
            let hrString = String(Int(beatsPerMinute))
            completion(hrString, beatsPerMinute, date)
        }
    }
    
    
    
    func getMostRecentSample(for sampleType: HKSampleType,
                                   completion: @escaping (HKQuantitySample?) -> Swift.Void) {
        
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let query = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: 1,
                                        sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                                            DispatchQueue.main.async {
                                                guard let samples = samples,
                                                      let mostRecentSample = samples.first as? HKQuantitySample else {
                                                        print(error ?? "Error occurred sampling \(sampleType)")
                                                        completion(nil)
                                                        return
                                                }
                                                completion(mostRecentSample)
                                            }
        }
        
        HKHealthStore().execute(query)
    }
    
    
    
    func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }
    
        
        let healthKitTypesToRead: Set<HKObjectType> = [HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
                                                       HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
                                                       HKObjectType.quantityType(forIdentifier: .height)!,
                                                       HKObjectType.quantityType(forIdentifier: .bodyMass)!,
                                                       HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                                                       HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                                                       HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
                                                       HKObjectType.activitySummaryType(),
                                                       HKObjectType.workoutType()]
        
        HKHealthStore().requestAuthorization(toShare: nil, read: healthKitTypesToRead) { (success, error) in
            completion(success, error)
        }
    }
    
    func getCalorieSummary(dateRange: (from: Date, to:Date)?, completion: @escaping ([(date: Date, value: Double)]) -> Swift.Void){
        getActivitySummary(dateRange: dateRange) { (summaryArray) in
            var result: [(date: Date, value: Double)] = []
            for s in summaryArray{
                let dc = s.dateComponents(for: Calendar.current)
                if let d = dc.date{
                    result.append((d, s.activeEnergyBurned.doubleValue(for: HKUnit.largeCalorie())))
                }
            }
            completion(result)
        }
    }

    func getExerciseTimeSummary(dateRange: (from: Date, to:Date)?, completion: @escaping ([(date: Date, value: Double)]) -> Swift.Void){
        getActivitySummary(dateRange: dateRange) { (summaryArray) in
            var result: [(date: Date, value: Double)] = []
            for s in summaryArray{
                let dc = s.dateComponents(for: Calendar.current)
                if let d = dc.date{
                    result.append((d, s.appleExerciseTime.doubleValue(for: HKUnit.hour())))
                }
            }
            completion(result)
        }
    }
    
    
    func getRestingHRData(dateRange: (from: Date, to:Date)?, completion: @escaping ([(date: Date, value: Double)]) -> Swift.Void){
        getQuantityData(quantityType: HKSampleType.quantityType(forIdentifier: .restingHeartRate)!, dateRange: dateRange) { (samples) in
            var result: [(date: Date, value: Double)] = []
            for s in samples{
                if let qs = s as? HKQuantitySample{
                    result.append((s.startDate, qs.quantity.doubleValue(for: HKUnit(from: "count/min"))))
                }
            }
            completion(result)
        }
    }
    
    func getHRVData(dateRange: (from: Date, to:Date)?, completion: @escaping ([HRVDataPoint]) -> Swift.Void){
        // HRV may be sampled multiple times a day - we just want a daily sample. This call returns the average of the days
        getDailyQuantityData(quantityType: HKSampleType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!, completion: {
            query, results, error in
            var result: [HRVDataPoint] = []
            if let stats = results{
                let endDate: Date = Date()
                // for now look for past 180 days - this allows 90 days to accumulate the correct thresholds then display the last 90 days
                // TO DO - this will need refactoring when graphs allow the user to select the date range to display
                if let startDate = Calendar.current.date(byAdding: DateComponents(day: -180), to: endDate){
                    stats.enumerateStatistics(from: startDate, to: endDate, with: { (stats, pointer) in
                        if let quantity = stats.averageQuantity(){
                            result.append(HRVDataPoint(date: stats.startDate, sdnn: quantity.doubleValue(for: HKUnit(from: "ms")), offValue: 0.0, easyValue: 0.0, hardValue: 0.0))
                        }
                    })
                    
                }
            }
            let fullHRVData: [HRVDataPoint] = self.populateHRVThresholds(forData: result)
            completion(fullHRVData)
        })
    }
    
    private func populateHRVThresholds(forData data: [HRVDataPoint]) -> [HRVDataPoint]{
        // this calculates the HRV levels for off, easy and hard
        var result: [HRVDataPoint] = []
        // going to calculate the thresholds looking at the standard deviation over previous 91 days readings
        let sdnnQueue: RollingSumQueue = RollingSumQueue(size: 91)
        let threshold = HRVDataPoint.thresholdSDs()
        print(threshold)
        let mathsCalculator: Maths = Maths()
        for d in data.sorted(by: {$0.date < $1.date}){
            let mean = sdnnQueue.addAndReturnAverage(value: d.sdnn)
            let std = mathsCalculator.standardDeviation(sdnnQueue.array())
            result.append(HRVDataPoint(date: d.date, sdnn: d.sdnn, offValue: mean + threshold.off * std, easyValue: mean + threshold.easy * std, hardValue: mean + threshold.hard * std))
        }
        
        return result
    }
    
    private func getQuantityData(quantityType: HKQuantityType, dateRange: (from: Date, to:Date)?, completion: @escaping ([HKSample]) -> Swift.Void){
        var from: Date = Date.distantPast
        var to: Date = Date()
        var limit: Int = HKObjectQueryNoLimit
        
        if let dr = dateRange{
            from = dr.from
            to = dr.to
            limit = HKObjectQueryNoLimit
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: from, end: to, options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: limit, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            if let error = error{
                print(error)
            }
            if let sample = samples{
                completion(sample)
            }else{
                print("Nothing returned")
                completion([])
            }
        }
        
        HKHealthStore().execute(query)
    
    }
    
    private func getDailyQuantityData(quantityType: HKQuantityType, completion: @escaping (HKStatisticsCollectionQuery, HKStatisticsCollection?, Error?) -> Void){
        let interval = DateComponents(day:1)
        // anchor samples at 3am - being cautious to avoid issues with daylight saving
        var anchorComponents = Calendar.current.dateComponents([.day, .month, .year], from: Date())
        anchorComponents.hour = 3
        
        guard let anchorDate = Calendar.current.date(from: anchorComponents) else{
            fatalError("*** unable to create a valid date from the given components ***")
        }

        let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: nil, options: .discreteAverage, anchorDate: anchorDate, intervalComponents: interval)
        query.initialResultsHandler = completion
        HKHealthStore().execute(query)
    }

    private func getActivitySummary(dateRange: (from: Date, to: Date)?, completion: @escaping ([HKActivitySummary]) -> Swift.Void) {
        if #available(iOS 9.3, *) {
            
            // this only checks write permissions so no need here. If no read permissions then just no data returned
//            // check for permissions
//            if healthStore.authorizationStatus(for: HKObjectType.activitySummaryType()) != .{
//                return false
//            }
            
            var dateRangePredicate: NSPredicate? = nil
            
            if let dateRange = dateRange{
                var startDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: dateRange.from)
                startDateComponents.calendar = Calendar.current
                var endDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: dateRange.to)
                endDateComponents.calendar = Calendar.current
                dateRangePredicate = HKQuery.predicate(forActivitySummariesBetweenStart: startDateComponents, end: endDateComponents)
            }
            
            let query = HKActivitySummaryQuery.init(predicate: dateRangePredicate) { (query, summaries, error) in
                if let error = error{
                    DispatchQueue.main.async {
                        print(error)
                    }
                }
                if let summary = summaries{
                    completion(summary)
                }else{
                    DispatchQueue.main.async {
                        print("Nothing Returned")
                    }
                    completion([])
                }
            }
        healthStore.execute(query)
        } else {
            // TO DO - better handle earlier iOS version
            print("not implement for pre iOS 9.3")
        }
    }
}
