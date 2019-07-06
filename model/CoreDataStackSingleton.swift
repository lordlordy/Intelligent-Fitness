//
//  CoreDataStackSingleton.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 15/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation
import CoreData


enum EntityType: String{
    case Exercise, ExerciseSet, Workout, Test, TestSet
}

/*
 This class is meant to be purely for mediating with the Core Data Stack.
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
    
    func newFunctionalFitnessTest() -> TestSet {
        let test: TestSet = newEntity(ofType: .TestSet) as! TestSet
        test.name  = "Functional Fitness Test"
        return test
    }
    
    func newWorkout() -> Workout { return newEntity(ofType: .Workout) as! Workout}
    func newExercise() -> Exercise { return newEntity(ofType: .Exercise) as! Exercise}
    func newExcerciseSet() -> ExerciseSet { return newEntity(ofType: .ExerciseSet) as! ExerciseSet}
    func newTest() -> Test { return newEntity(ofType: .Test) as! Test}
    func newTestSet() -> TestSet { return newEntity(ofType: .TestSet) as! TestSet}
    
    func getAllSessions() -> [Workout]{
        let results = getAllEntities(ofType: .Workout) as! [Workout]
        return results.sorted(by: {$0.date! > $1.date!})
    }
    
    func getTestSets() -> [TestSet]{
        let results = getAllEntities(ofType: .TestSet) as! [TestSet]
        return results.sorted(by: {$0.date! > $1.date!})
    }
    
    private func getAllEntities(ofType type: EntityType) -> [NSManagedObject]{
        let fetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: type.rawValue)
        do{
            return try modelPC.viewContext.fetch(fetch) as! [NSManagedObject]
        }catch{
            print("fetch faled with error: \(error)")
        }
        return []
    }
    
    private func newEntity(ofType type: EntityType) -> NSManagedObject{
        return NSEntityDescription.insertNewObject(forEntityName: type.rawValue, into: modelPC.viewContext)
    }

    private init(){
    }
    
}
