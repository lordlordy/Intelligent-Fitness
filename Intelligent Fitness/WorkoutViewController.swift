//
//  TableViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 24/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit

class WorkoutViewController: UITableViewController {

    var workout: Workout = WorkoutManager().createTestSession(onDate: Date())
    private let workoutCellID = "WorkoutCell"
    private let exerciseSetCellID = "ExerciseSetCell"
    
    override func viewDidLoad() {
        super.viewDidLoad() 

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else if section == 1{
            return workout.exerciseSets?.count ?? 0
        }
        return 0
    }
    
    
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            if section == 0{
                return "Workout"
            }else{
                return "Sets"
            }
        }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 45.0
        }else{
            return 140.0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: workoutCellID, for: indexPath)
            if let c = cell as? WorkoutTableViewCell{
                c.descriptionLabel.text = workout.explanation
                print(workout.explanation)
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: exerciseSetCellID, for: indexPath)
            if let c = cell as? ExerciseSetTableViewCell{
                let description: String = workout.exerciseSet(atOrder: Int16(indexPath.row))?.explanation ?? "no description found"
                c.descriptionLabel.text = description
                print(description)
            }
            return cell
        }
    }
    
}


class WorkoutTableViewCell: UITableViewCell{
    
    @IBOutlet weak var descriptionLabel: UILabel!
}


class ExerciseSetTableViewCell: UITableViewCell{
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var set1Label: UILabel!
    @IBOutlet weak var set1Reps: UILabel!
    @IBOutlet weak var set2Label: UILabel!
    @IBOutlet weak var set2Reps: UILabel!
    @IBOutlet weak var set3Label: UILabel!
    @IBOutlet weak var set3Reps: UILabel!
    @IBOutlet weak var set4Label: UILabel!
    @IBOutlet weak var set4Reps: UILabel!
    @IBOutlet weak var set5Label: UILabel!
    @IBOutlet weak var set5Reps: UILabel!
    
    @IBAction func set1Changed(_ sender: UISlider) {
        let value = Int(sender.value)
        if sender.value == sender.maximumValue{
            set1Reps.text = "DONE!"
        }else{
            set1Reps.text = String(value)
        }
    }

    @IBAction func set2Changed(_ sender: UISlider) {
        let value = Int(sender.value)
        set2Reps.text = String(value)
    }
    
    @IBAction func set3Changed(_ sender: UISlider) {
        let value = Int(sender.value)
        set3Reps.text = String(value)
    }
    
    @IBAction func set4Changed(_ sender: UISlider) {
        let value = Int(sender.value)
        set4Reps.text = String(value)
    }
    
    @IBAction func set5Changed(_ sender: UISlider) {
        let value = Int(sender.value)
        set5Reps.text = String(value)
    }
    
}
