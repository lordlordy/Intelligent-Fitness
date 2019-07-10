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

class TestViewController: UIViewController {

//    @objc dynamic var person: Person?
    
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var timerLabel: UILabel!
    var timer: Timer?
    var startTime: Date = Date()
    var runningTime: TimeInterval = TimeInterval()

    
    @IBAction func start(_ sender: Any) {
        timer = Timer(timeInterval: 0.1,
                          target: self,
                          selector: #selector(updateTimer),
                          userInfo: nil,
                          repeats: true)
        startTime = Date()
        RunLoop.current.add(timer!, forMode: .common)
        timer!.tolerance = 0.1
    }
    
    
    @IBAction func stop(_ sender: Any) {
        timer!.invalidate()
        timer = nil
    }

    @objc func updateTimer(){
        runningTime = Date().timeIntervalSince(startTime)
        
        let hours = Int(runningTime) / 3600
        let minutes = Int(runningTime) / 60 % 60
        let seconds = Int(runningTime) % 60
        let subSeconds = Int((runningTime - Double(Int(runningTime))) * 10)
        
        var times: [String] = []
        if hours > 0 {
            times.append("\(hours)")
        }
        if minutes > 0 {
            times.append("\(minutes)")
        }
        times.append("\(seconds).\(subSeconds)")
        
        timerLabel.text = times.joined(separator: ":")
    }
    
    
    @IBAction func printUserData(_ sender: Any) {
        if #available(iOS 9.3, *) {
            let endDate = Date()
            let start = Calendar.current.date(byAdding: DateComponents(day:-7), to: endDate)!
            
//            let units: NSCalendarUnit = [.Day, .Month, .Year, .Era]
            
            var startDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: start)
            startDateComponents.calendar = Calendar.current
            
            var endDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: endDate)
            endDateComponents.calendar = Calendar.current
            
            
            // Create the predicate for the query
//            let summariesWithinRange = HKQuery.predicate(forActivitySummariesBetweenStart: startDateComponents, end: endDateComponents)
            
            
            let query = HKActivitySummaryQuery.init(predicate: nil) { (query, summaries, error) in
                print(summaries ?? "Nothing Returned")
                let calendar = Calendar.current
                for summary in summaries! {
                    let dc = summary.dateComponents(for: calendar)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    let date = dc.date
                    
                    print("Date: \(dateFormatter.string(from: date!)), Active Energy Burned: \(summary.activeEnergyBurned), Active Energy Burned Goal: \(summary.activeEnergyBurnedGoal)")
                    print("Date: \(dateFormatter.string(from: date!)), Exercise Time: \(summary.appleExerciseTime), Exercise Goal: \(summary.appleExerciseTimeGoal)")
                    print("Date: \(dateFormatter.string(from: date!)), Stand Hours: \(summary.appleStandHours), Stand Hours Goal: \(summary.appleStandHoursGoal)")
                    print("----------------")
                }
            }
            HKHealthStore().execute(query)
        } else {
            // Fallback on earlier versions
        }
    }
    
//    @IBAction func printTests(_ sender: Any) {
//        print("printing tests")
//        let tests = CoreDataStackSingleton.shared.getFunctionFitnessTests()
//        for t in tests{
//            print("\(String(describing: t.date)): deadHang: \(t.deadHang)")
//        }
//    }
//    
    
    @IBAction func printWorkouts(_ sender: Any) {
        let workouts = HKQuery.predicateForWorkouts(with: .running)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: true)
        
        let query = HKSampleQuery(sampleType: HKSampleType.workoutType(), predicate: workouts, limit: 0, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            DispatchQueue.main.async {
                
                guard let samples = samples as? [HKWorkout] else {
                    
                    print(error as Any)
                    return
                }

                var c = 1
                for s in samples{
                    print(c)
                    print(s.workoutEvents as Any)
                    print(s.totalDistance as Any)
                    print(s.totalEnergyBurned as Any)
                    print(s.duration)
//                    print(s.workoutEvents)
                    c += 1
                }

            }
        }
        
        HKHealthStore().execute(query)
        
    }
    
    @IBAction func printCalories(_ sender: UIButton) {
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
                fatalError("!!! error occurred getting active daily calorie burn")
            }
            
            let tomorrow = calendar.date(byAdding: DateComponents(day: 1), to: today)
            
            statsCollection.enumerateStatistics(from: Date.distantPast, to: tomorrow!, with: { (stats, stop) in
                if let quantity = stats.sumQuantity(){
                    let value = quantity.doubleValue(for: HKUnit.largeCalorie())
                    print("\(stats.startDate): \(value) Cals")
                }
            })
            
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
                        
                    print(error as Any)
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
        HealthKitAccess.shared.authorizeHealthKit { (authorized, error) in
            
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
    
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        person = CoreDataStackSingleton.shared.getPerson()
//        if person?.firstName != nil{
//            firstNameTextField.text = person?.firstName
//        }
//        if person?.surname != nil{
//            surnameTextField.text = person?.surname
//        }
//    }
//
//    @IBAction func userSaveButton(_ sender: UIButton) {
//        print("\(firstNameTextField.text ?? "none set") \(surnameTextField.text ?? "none set")")
//        person?.firstName = firstNameTextField.text
//        person?.surname = surnameTextField.text
//        CoreDataStackSingleton.shared.save()
////        getTest()
//        postTest(person: person!)
//
//    }
    
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
    
//    private func postTest(person: Person){
//
//        let parameters = ["FirstName": person.firstName!, "Surname": person.surname!]
//
//        guard let url = URL(string: "https://lord-lordy2.eu-gb.mybluemix.net/test") else {
//            print("oops")
//            return
//        }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
//        request.httpBody = httpBody
//
//        let session = URLSession.shared
//        session.dataTask(with: request){ (data, response, error) in
//            if let response = response{
//                print(response)
//            }
//            if let data = data{
//                print(data)
//                do{
//                    let json = try JSONSerialization.jsonObject(with: data, options: [])
//                    print(json)
//                } catch {
//                    print(error)
//                }
//            }
//        }.resume()
//
//
//    }
    
}
