//
//  WorkoutTableViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 01/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit

class WorkoutTableViewController: UITableViewController{

    var workout: Workout!
    private let EXERCISE_SET_CELL = "ExerciseCell"
    private let EXERCISE_DESCRIPTION_CELL = "ExerciseDescriptionCell"
    private let DONE_CELL = "DoneCell"
    private let SAVE_SET_CELL = "SaveSetCell"
    private let EXERCISE_SECTION: Int = 0
    private let EXERCISE_SETS_SECTION: Int = 1
    private let EXERCISE_END_EARLY_SECTION: Int = 2
    fileprivate var currentExerciseSet: Int16 = 0
    
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
                    if let e = workout.exercise(atOrder: currentSet){
                        return e.numberOfSets()
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
                c.label.text = workout.exercise(atOrder: currentExerciseSet)?.exerciseType()?.name() ?? ""
            }
            return cell
        }else if indexPath.section == EXERCISE_SETS_SECTION{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EXERCISE_SET_CELL) else {
                print("No cell found for identifier: \(EXERCISE_SET_CELL)")
                return UITableViewCell()
            }
            if let c = cell as? ExerciseCell{
                c.setExerciseSet(workout.exercise(atOrder: currentExerciseSet)?.exerciseSet(atOrder: Int16(indexPath.row)))
                c.workoutCompletionDelegate = self
            }
            return cell
        }else if indexPath.section == EXERCISE_END_EARLY_SECTION{
            if workout.workoutFinished(){
                guard let cell = tableView.dequeueReusableCell(withIdentifier: SAVE_SET_CELL) else{
                    print("No cell found for identifier: \(SAVE_SET_CELL)")
                    return UITableViewCell()
                }
                return cell
            }else{
                guard let cell = tableView.dequeueReusableCell(withIdentifier: DONE_CELL) else{
                    print("No cell found for identifier: \(DONE_CELL)")
                    return UITableViewCell()
                }
                if let c = cell as? ExerciseDoneCell{
                    c.workoutCompletionDelegate = self
                    c.setExercise(workout.exercise(atOrder: currentExerciseSet))
                }
                return cell
            }
        }else{
            return UITableViewCell()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "SaveWorkoutSegue" {
            if let tabVC = segue.destination as? UITabBarController{
                tabVC.selectedIndex = 3
            }
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
    
    private var exercise: ExerciseSet?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    var workoutCompletionDelegate: WorkoutCompletionDelegate?
    
    func setExerciseSet(_ exercise: ExerciseSet?){
        self.exercise = exercise
        if let e = exercise as? Reps{
            label.text = "\(e.exerciseReps?.exerciseType()?.name() ?? ""): \(e.plannedReps) x \(e.plannedKG) KG"
            slider.maximumValue = Float(e.plannedReps)
            repsLabel.text = e.actualReps > 0 ? String(e.actualReps) : ""
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
        exercise?.actualKG = exercise?.plannedKG ?? 0.0
        print(exercise)
        if let e  = exercise as? Reps{
            e.actualReps = Int16(reps)
        }
        if exercise?.setCompleted() ?? false{
            if let wcd = workoutCompletionDelegate{
                wcd.checkIfWorkoutFinished()
            }
        }
    }
    
}

class ExerciseDescriptionCell: UITableViewCell{
    
    @IBOutlet weak var label: UILabel!
    
}

class SaveSetCell: UITableViewCell{
    
    var viewController: UIViewController?

    @IBAction func home(_ sender: Any) {
        CoreDataStackSingleton.shared.save()
        if let vc = viewController{
            vc.performSegue(withIdentifier: "SaveTestSegue", sender: self)
        }
    }
    
}

class ExerciseDoneCell: UITableViewCell{
    
    private var exercise: Exercise?
    var workoutCompletionDelegate: WorkoutCompletionDelegate?

    func setExercise(_ exercise: Exercise?){
        self.exercise = exercise
    }
    
    @IBAction func done(_ sender: Any) {
        if let e = exercise{
            e.endedEarly = true
        }
        if let wcd = workoutCompletionDelegate{
            wcd.checkIfWorkoutFinished()
        }
    }
    
}


