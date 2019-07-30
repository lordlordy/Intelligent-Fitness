//
//  TableViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 24/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit

class WorkoutViewController: UITableViewController {

//    var workout: Workout = WorkoutManager.shared.nextWorkout()
    
//    @IBOutlet weak var dateTextField: UITextField!
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
    
//    private var datePicker: UIDatePicker = UIDatePicker()
    private let df = DateFormatter()

    private let descriptionText: String = "Your aim is to do three sessions per week with no more than two rest days between sessions. Consecutive weeks of consistency will be rewarded with power ups in the 'Fitness Invaders' game."

    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.text = descriptionText
        df.dateFormat = "yyyy-MM-dd"
        
//        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
//        if view.backgroundColor?.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) ?? false{
//            dateTextField.backgroundColor = UIColor(hue: hue, saturation: saturation, brightness: brightness * 1.1, alpha: alpha)
//        }else{
//            dateTextField.backgroundColor = UIColor.clear
//        }
//        dateTextField.textColor = UIColor.white
        
//        datePicker.datePickerMode = .date
//        datePicker.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecogniser:)))
//        view.addGestureRecognizer(tapGesture)
        
//        dateTextField.inputView = datePicker
    }
    
    
    
//    @objc func viewTapped(gestureRecogniser: UITapGestureRecognizer){
//        view.endEditing(true)
//    }
    
//    @objc func dateChanged(datePicker: UIDatePicker){
//        dateTextField.text = df.string(from: datePicker.date)
//        WorkoutManager.shared.nextWorkout().date = datePicker.date
//        view.endEditing(true)
//    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let nextWorkout: Workout = WorkoutManager.shared.nextWorkout()
        let d: Date = nextWorkout.date ?? Date()
        suggestedDate.text = df.string(from: d)
//        dateTextField.text = df.string(from: d)
//        datePicker.date = d

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


