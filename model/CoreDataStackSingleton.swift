//
//  CoreDataStackSingleton.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 15/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation
import CoreData

/*
 This class is meant to be purely for mediating with the Core Data Stack. There is some
 additional functionality in here that should be extracted in to another class mainly
 around creation of Base Data
 */
class CoreDataStackSingleton{
    
    static let shared = CoreDataStackSingleton()
    
    // MARK: - Core Data stack
    
    lazy var modelPC: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            let type = storeDescription.type
            let url = storeDescription.url
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()
    
    func save(){
        do {
            try modelPC.viewContext.save()
        } catch {
            print(error)
        }
    }

    //MARK: - New Entities
    
    func newFunctionalFitnessTest() -> FunctionalFitnessTest{
        let fft: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: "FunctionalFitnessTest", into: modelPC.viewContext)
        let test = fft as! FunctionalFitnessTest
        return test
    }
    
    
    func getFunctionFitnessTests() -> [FunctionalFitnessTest]{
        let fetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: "FunctionalFitnessTest")
        do{
            let results = try modelPC.viewContext.fetch(fetch) as! [FunctionalFitnessTest]
            return results.sorted(by: {$0.date! > $1.date!})
        }catch{
            print("fetch faled with error: \(error)")
        }
        return []
    }
    
//    func newPerson() -> Person{
//        let mo: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: "Person", into: modelPC.viewContext)
//        let user = mo as! Person
//        return user
//    }
//    
//    func getPerson() -> Person{
//        let userRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Person")
////        workoutRequest.predicate = NSPredicate(format: "day.trainingDiary = %@", argumentArray: [td])
//        do{
//            let users = try modelPC.viewContext.fetch(userRequest)
//            if users.count > 0{
//                return users[0] as! Person
//            }else{
//                return newPerson()
//            }
//        }catch{
//            print("failed to get users for model")
//            return newPerson()
//        }
//    }
//    
    private init(){
    }
    
}
