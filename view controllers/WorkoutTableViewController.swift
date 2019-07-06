//
//  WorkoutTableViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 01/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit

class WorkoutTableViewController: UITableViewController{

    var workout: Workout = WorkoutManager().createWorkout(onDate: Date())
    private let EXERCISE_SET_CELL = "ExerciseCell"
    private let EXERCISE_DESCRIPTION_CELL = "ExerciseDescriptionCell"
    private let DONE_CELL = "DoneCell"
    private let HOME_CELL = "HomeCell"
    private let EXERCISE_SECTION: Int = 0
    private let EXERCISE_SETS_SECTION: Int = 1
    private let EXERCISE_END_EARLY_SECTION: Int = 2
    fileprivate var currentExerciseSet: Int16 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if workout.workoutFinished(){
            switch section{
            case EXERCISE_SECTION: return "Well Done. Workout Finished"
            default: return " "
            }
        }else{
            switch section{
            case EXERCISE_SECTION: return "Exercise"
            case EXERCISE_SETS_SECTION: return "Sets"
            default: return " "
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if workout.workoutCompleted(){
            switch section{
            case EXERCISE_END_EARLY_SECTION: return 1
            default: return 0
            }
        }else{
            switch section{
            case EXERCISE_SECTION: return 1
            case EXERCISE_SETS_SECTION:
                if let currentSet = workout.currentSet(){
                    if let es = workout.exerciseSet(atOrder: currentSet){
                        return es.numberOfSets()
                    }
                }
                return 0
            default: return 1
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if workout.workoutFinished(){
            switch indexPath.section{
            case EXERCISE_SECTION: return 0.0
            default: return 40.0
            }
        }else{
            switch indexPath.section{
            case EXERCISE_SECTION: return 50.0
            case EXERCISE_SETS_SECTION: return 85.0
            default: return 40.0
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == EXERCISE_SECTION{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EXERCISE_DESCRIPTION_CELL) else{
                print("No cell found for identifier: \(EXERCISE_DESCRIPTION_CELL)")
                return UITableViewCell()
            }
            if let c = cell as? ExerciseDescriptionCell{
                c.label.text = workout.exerciseSet(atOrder: currentExerciseSet)?.name ?? ""
            }
            return cell
        }else if indexPath.section == EXERCISE_SETS_SECTION{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EXERCISE_SET_CELL) else {
                print("No cell found for identifier: \(EXERCISE_SET_CELL)")
                return UITableViewCell()
            }
            if let c = cell as? ExerciseCell{
                c.setExercise(workout.exerciseSet(atOrder: currentExerciseSet)?.exercise(atOrder: Int16(indexPath.row)))
                c.workoutCompletionDelegate = self
            }
            return cell
        }else if indexPath.section == EXERCISE_END_EARLY_SECTION{
            if workout.workoutFinished(){
                guard let cell = tableView.dequeueReusableCell(withIdentifier: HOME_CELL) else{
                    print("No cell found for identifier: \(HOME_CELL)")
                    return UITableViewCell()
                }
//                if let c = cell as? HomeCell{
//                    c.viewController = self
//                }
                return cell
            }else{
                guard let cell = tableView.dequeueReusableCell(withIdentifier: DONE_CELL) else{
                    print("No cell found for identifier: \(DONE_CELL)")
                    return UITableViewCell()
                }
                if let c = cell as? ExerciseDoneCell{
                    c.workoutCompletionDelegate = self
                    c.setExerciseSet(workout.exerciseSet(atOrder: currentExerciseSet))
                }
                return cell
            }
        }else{
            return UITableViewCell()
        }
    }

}

protocol WorkoutCompletionDelegate{
    func checkIfWorkoutFinished()
}

extension WorkoutTableViewController: WorkoutCompletionDelegate{
    func checkIfWorkoutFinished() {
        if let currentSet = workout.currentSet(){
            if currentSet != currentExerciseSet{
                // set has changed
                currentExerciseSet = currentSet
                for cell in tableView.visibleCells{
                    if let c = cell as? ExerciseCell{
                        c.slider.value = 0.0
                    }
                }
                tableView.reloadData()
            }
        }
        if workout.workoutFinished(){
            tableView.reloadData()
        }
    }
}

class ExerciseCell: UITableViewCell{
    
    private var exercise: Exercise?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    var workoutCompletionDelegate: WorkoutCompletionDelegate?
    
    func setExercise(_ exercise: Exercise?){
        self.exercise = exercise
        if let e = exercise{
            label.text = "\(e.type ?? ""): \(e.plannedReps) x \(e.plannedKG) KG"
            slider.maximumValue = Float(e.plannedReps)
            repsLabel.text = String(e.actualReps)
        }
        
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        let value: Float = sender.value.rounded()
        slider.value = value
        setActualReps(to: Int(value))
    }
    
    @IBAction func minusTapped(_ sender: Any) {
        let value = max(slider.minimumValue, slider.value - 1.0)
        slider.value = value
        setActualReps(to: Int(value))
    }
    
    @IBAction func plusTapped(_ sender: Any) {
        let value = min(slider.maximumValue, slider.value + 1.0)
        slider.value = value
        setActualReps(to: Int(value))
    }
    
    private func setActualReps(to reps: Int){
        repsLabel.text = String(reps)
        exercise?.actualReps = Int16(reps)
        if exercise?.exerciseComplete() ?? false{
            if let wcd = workoutCompletionDelegate{
                wcd.checkIfWorkoutFinished()
            }
        }
    }
    
}

class ExerciseDescriptionCell: UITableViewCell{
    
    @IBOutlet weak var label: UILabel!
    
}

class HomeCell: UITableViewCell{
    
    var viewController: UIViewController?

    @IBAction func home(_ sender: Any) {
        if let vc = viewController{
            vc.performSegue(withIdentifier: "MainTabViewController", sender: self)
        }
    }
    
}

class ExerciseDoneCell: UITableViewCell{
    
    private var exerciseSet: ExerciseSet?
    var workoutCompletionDelegate: WorkoutCompletionDelegate?

    func setExerciseSet(_ exerciseSet: ExerciseSet?){
        self.exerciseSet = exerciseSet
    }
    
    @IBAction func done(_ sender: Any) {
        if let es = exerciseSet{
            es.endedSetEarly = true
        }
        if let wcd = workoutCompletionDelegate{
            wcd.checkIfWorkoutFinished()
        }
    }
    
}


