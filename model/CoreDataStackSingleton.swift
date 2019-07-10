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
    
    func incompleteWorkouts() -> [Workout]{
        let fetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: EntityType.Workout.rawValue)
        fetch.predicate = NSPredicate(format: "complete == %@", argumentArray: [false])
        do{
            return try modelPC.viewContext.fetch(fetch) as! [Workout]
        }catch{
            print("fetch failed with error: \(error)")
        }
        return []
    }
    
    func getTestSets() -> [TestSet]{
        let results = getAllEntities(ofType: .TestSet) as! [TestSet]
        return results.sorted(by: {$0.date! > $1.date!})
    }
    
    func getMostRecentTestSet() -> TestSet?{
        let tests = getTestSets()
        if tests.count > 0{
            return tests[0]
        }
        return nil
    }
    
    func getMostRecentTest(ofType type: TestType) -> Test?{
        let tests = getTests(forName: type.rawValue)
        for t in tests{
            print(t.testSet)
            print(t.testSet?.date ?? "No Date" )
        }
        let sortedTests = tests.filter({$0.result >= 0.0}).sorted(by: {$0.testSet!.date! > $1.testSet!.date!})
        if sortedTests.count > 0{
            return sortedTests[0]
        }
        return nil
    }
    
    func getTests(forName name: String) -> [Test]{
        let fetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: EntityType.Test.rawValue)
        fetch.predicate = NSPredicate(format: "name == %@", argumentArray: [name])
        do{
            return try modelPC.viewContext.fetch(fetch) as! [Test]
        }catch{
            print("fetch failed with error: \(error)")
        }
        return []
    }
    
    func getWorkouts() -> [Workout]{
        let results = getAllEntities(ofType: .Workout) as! [Workout]
        return results.sorted(by: {$0.date! > $1.date!})
    }
    
    func delete(_ obj: NSManagedObject){
        modelPC.viewContext.delete(obj)
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
