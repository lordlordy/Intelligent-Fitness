//
//  HealthKitSetUp.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 20/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import HealthKit

class HealthKitSetUp {
    
    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }
    
    class func getAgeAndSex() throws -> (age: Int,
        biologicalSex: HKBiologicalSex) {
            
            let healthKitStore = HKHealthStore()
            print(healthKitStore)
            
            do {
                
                let birthdayComponents =  try healthKitStore.dateOfBirthComponents()
                print(birthdayComponents)
                let biologicalSex =       try healthKitStore.biologicalSex()
                print(biologicalSex)
                
                let today = Date()
                let calendar = Calendar.current
                let todayDateComponents = calendar.dateComponents([.year],
                                                                  from: today)
                let thisYear = todayDateComponents.year!
                let age = thisYear - birthdayComponents.year!
                
                let unwrappedBiologicalSex = biologicalSex.biologicalSex
                
                return (age, unwrappedBiologicalSex)
            }
    }
    
    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }
        
        guard let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
            let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
            let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
            let height = HKObjectType.quantityType(forIdentifier: .height),
            let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
            let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
                completion(false, HealthkitSetupError.dataTypeNotAvailable)
                return
        }
        
//        let healthKitTypesToWrite: Set<HKSampleType> = [bodyMassIndex,
//                                                        activeEnergy,
//                                                        HKObjectType.workoutType()]
//
        let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth,
                                                       bloodType,
                                                       biologicalSex,
                                                       bodyMassIndex,
                                                       height,
                                                       bodyMass,
                                                       HKObjectType.workoutType()]
        
        //4. Request Authorization
        HKHealthStore().requestAuthorization(toShare: nil,
                                             read: healthKitTypesToRead) { (success, error) in
                                                completion(success, error)
        }
    }
}
