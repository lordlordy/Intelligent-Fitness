//
//  TableViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 24/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit

class WorkoutViewController: UITableViewController {
    
    @IBOutlet weak var workoutTypeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var currentStreakTextField: UITextField!
    @IBOutlet weak var bestStreakTextField: UITextField!
    @IBOutlet weak var workoutsThisWeekTextField: UITextField!
    @IBOutlet weak var testsThisWeekTextField: UITextField!
    @IBOutlet weak var currentlyConsistentTextField: UITextField!
    @IBOutlet weak var weeksForNextPowerUp: UITextField!
    @IBOutlet weak var sessionsForAttackPowerUp: UITextField!
    @IBOutlet weak var suggestedDate: UITextField!
    
    private let df = DateFormatter()

    private let descriptionText: String = "Your aim is to do three sessions per week with no more than two rest days between sessions. Consecutive weeks of consistency will be rewarded with power ups in the 'Fitness Invaders' game. "

    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.text = descriptionText
        df.dateFormat = "yyyy-MM-dd"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let nextWorkout: Workout = WorkoutManager.shared.nextWorkout()
        let d: Date = nextWorkout.date ?? Date()
        suggestedDate.text = df.string(from: d)

        let type: WorkoutType? = nextWorkout.workoutType()
        workoutTypeLabel.text = type?.string() ?? "Workout Type Unknown"
        let streak = WorkoutManager.shared.currentStreakData()
        currentStreakTextField.text = "\(streak.current) weeks"
        bestStreakTextField.text = "\(streak.best) weeks"
        
        let weeksForDefence: Int = WorkoutManager.shared.weeksForNextDefencePowerUp()
        weeksForNextPowerUp.text = "In \(weeksForDefence) weeks"
        
        let attackPower = WorkoutManager.shared.sessionsForNextAttackPowerUp()
        sessionsForAttackPowerUp.text = "\(attackPower.sessions) sets of \(attackPower.repsXKg) kg-reps"
        
        if let currentWeek = WorkoutManager.shared.currentWeek(){
            if currentWeek.consistent{
                currentlyConsistentTextField.text = "Yes"
            }else{
                currentlyConsistentTextField.text = "No"
            }
            let formatter: DateFormatter = DateFormatter()
            formatter.dateFormat = "E"
            let completedWorkoutDays: [String] = currentWeek.completeWorkouts.filter({!$0.isTest}).map({formatter.string(from: $0.date!)})
            let completedTestDays: [String] = currentWeek.completeWorkouts.filter({$0.isTest}).map({formatter.string(from: $0.date!)})
            let incompleteTestsDays: [String] = currentWeek.incompleteWorkouts.filter({$0.isTest}).map({formatter.string(from: $0.date!)})
            
            workoutsThisWeekTextField.text = completedWorkoutDays.joined(separator: ", ")
            var testsStr: [String] = []
            if completedTestDays.count > 0{
                testsStr.append("Done: ")
                testsStr = testsStr + completedTestDays
            }
            if incompleteTestsDays.count > 0{
                testsStr.append("ToDo: ")
                testsStr = testsStr + incompleteTestsDays
            }
            if testsStr.count == 0{
                testsThisWeekTextField.text = "No Tests"
            }else{
                testsThisWeekTextField.text = testsStr.joined(separator: " ")
            }
            
        }
        
        adjustDescriptioBasedOnPreparedNess()
        
    }
    
    private func adjustDescriptioBasedOnPreparedNess(){
        var additionalText: String = ""
        WorkoutManager.shared.latestPreparedness { (preparednessDataPoint) in
            // check sadness
            var restDayDueToSadness: Bool = false
            if let sadness = preparednessDataPoint.sadnessTone{
                // arbitrary for now - sadness score of more than 75% and have an easy day
                restDayDueToSadness = sadness.score > 0.75
            }
            // again relatively arbitrary - eventually the app should calculate this number based on some analysis
            let restDayDueToTSB: Bool = preparednessDataPoint.tsb.tsb < -75.0
            
            if preparednessDataPoint.hrv.dayOff{
                // HRV reading very low should take the day off
                additionalText += "We suggest you take today off from training since your heart rate variability is in the bottom 3%."
            }else if preparednessDataPoint.hrv.goEasy{
                // HRV reading low.
                additionalText += "Your HRV in is the bottom 25% so we suggest either an easy day or the day off"
            }else if restDayDueToTSB{
                additionalText += "You've been training excellently and have accumulated a lot of fatigue so we suggest you take a rest day today"
            }else if restDayDueToSadness{
                // don't give explanation for this
                additionalText += "We think you would really benefit from not training today and getting extra sleep"
            }else if (true || preparednessDataPoint.hrv.goHard){
                // good HRV score potentially go hard.
                additionalText += "Your HRV is in the top 25% suggesting you're in excellent shape to train today. Consider doing extra in your session today and perhaps adding some cardio"
            }
            
            if additionalText != ""{
                // we want to add something to the description. This needs to be one on main thread
                DispatchQueue.main.async {
                    self.descriptionLabel.text = (self.descriptionLabel.text ?? "") + "\r\r" + additionalText
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "StartWorkout"{
            if let vc = segue.destination as? WorkoutTableViewController{
                //set workout to maximum of today
                let w: Workout = WorkoutManager.shared.nextWorkout()
                w.date = min(w.date ?? Date(), Date())
                vc.workout = w
            }
        }
    }
    
}


