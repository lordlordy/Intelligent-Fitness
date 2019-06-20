//
//  FirstViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 14/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit
import Firebase
import HealthKit

class UserViewController: UIViewController {

    @objc dynamic var person: Person?
    
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBAction func printUserData(_ sender: Any) {
        do{
            let data = try HealthKitSetUp.getAgeAndSex()
            print(data)
        }catch{
            print(error)
        }
    }
    @IBAction func printWorkouts(_ sender: Any) {
        let workouts = HKQuery.predicateForWorkouts(with: .running)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: true)
        
        let query = HKSampleQuery(sampleType: HKSampleType.workoutType(), predicate: workouts, limit: 0, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            DispatchQueue.main.async {
                
                guard let samples = samples as? [HKWorkout] else {
                    
                    print(error)
                    return
                }

                var c = 1
                for s in samples{
                    print(c)
                    print(s.workoutEvents)
                    print(s.totalDistance)
                    print(s.totalEnergyBurned)
                    print(s.duration)
//                    print(s.workoutEvents)
                    c += 1
                }

            }
        }
        
        HKHealthStore().execute(query)
        
    }
    
    @IBAction func printHeartRate(_ sender: Any) {
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                              end: Date(),
                                                              options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)
        
        let query = HKSampleQuery(sampleType: HKSampleType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!, predicate: mostRecentPredicate, limit: 30, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            DispatchQueue.main.async {
                
                guard let samples = samples else {
                        
                        print(error)
                        return
                }
                
                print(samples)
            }
        }
        
        HKHealthStore().execute(query)
    
    }
    
    @IBAction func signOut(_ sender: Any) {

        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
        } catch (let error) {
            print("Auth sign out failed: \(error)")
        }
    }
    
    @IBAction func authoriseHealthKit(_ sender: Any) {
        HealthKitSetUp.authorizeHealthKit { (authorized, error) in
            
            guard authorized else {
                
                let baseMessage = "HealthKit Authorization Failed"
                
                if let error = error {
                    print("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                    print(baseMessage)
                }
                
                return
            }
            
            print("HealthKit Successfully Authorized.")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        person = CoreDataStackSingleton.shared.getPerson()
        if person?.firstName != nil{
            firstNameTextField.text = person?.firstName
        }
        if person?.surname != nil{
            surnameTextField.text = person?.surname
        }
    }

    @IBAction func userSaveButton(_ sender: UIButton) {
        print("\(firstNameTextField.text ?? "none set") \(surnameTextField.text ?? "none set")")
        person?.firstName = firstNameTextField.text
        person?.surname = surnameTextField.text
        CoreDataStackSingleton.shared.save()
//        getTest()
        postTest(person: person!)
        
    }
    
    private func getTest(){
        guard let url = URL(string: "https://lord-lordy2.eu-gb.mybluemix.net/test") else {
            print("oops")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let response = response{
                print(response)
            }
            
            if let data = data{
                print(data)
            }
        }
        task.resume()
    }
    
    private func postTest(person: Person){
        
        let parameters = ["FirstName": person.firstName!, "Surname": person.surname!]
        
        guard let url = URL(string: "https://lord-lordy2.eu-gb.mybluemix.net/test") else {
            print("oops")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request){ (data, response, error) in
            if let response = response{
                print(response)
            }
            if let data = data{
                print(data)
                do{
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
        }.resume()
        
        
    }
    
}

