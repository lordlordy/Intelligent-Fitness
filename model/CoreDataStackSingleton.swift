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
    case Exercise, ExerciseSet, Workout
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
    
    
    func newWorkout() -> Workout { return newEntity(ofType: .Workout) as! Workout}
    func newExerciseSet() -> ExerciseSet {return newEntity(ofType: .ExerciseSet) as! ExerciseSet}
    func newExercise() -> Exercise {return newEntity(ofType: .Exercise) as! Exercise}
    
    func getAllSessions() -> [Workout]{
        let results = getAllEntities(ofType: .Workout, predicate: nil) as! [Workout]
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

    
    func getFunctionalFitnessTests() -> [Workout]{
        return getAllEntities(ofType: .Workout, predicate: NSPredicate(format: "isTest == %@", argumentArray: [true])) as! [Workout]
    }
    
    
    func getWorkouts(ofType type: WorkoutType?, isTest test: Bool? ) -> [Workout]{
        var predicateStr: [String] = []
        var variables: [Any] = []
        if let t = type{
            predicateStr.append("type == %@")
            variables.append(t.string())
        }
        if let t = test{
            predicateStr.append("isTest == %@")
            variables.append(t)
        }
        var predicate: NSPredicate? = nil
        if predicateStr.count > 0{
            predicate = NSPredicate(format: predicateStr.joined(separator: " and "), argumentArray: variables)
        }
        let results = getAllEntities(ofType: .Workout, predicate: predicate) as! [Workout]
        return results.sorted(by: {$0.date! > $1.date!})
    }
    
    func delete(_ obj: NSManagedObject){
        modelPC.viewContext.delete(obj)
    }
    
    private func getAllEntities(ofType type: EntityType, predicate: NSPredicate?) -> [NSManagedObject]{
        let fetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: type.rawValue)
        if let p = predicate{
            fetch.predicate = p
        }
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
