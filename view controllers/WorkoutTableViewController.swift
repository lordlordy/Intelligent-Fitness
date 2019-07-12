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
    private let ADJUST_KG_CELL = "AdjustKGCell"
    private let EXERCISE_SECTION: Int = 0
    private let ADJUST_KG_SECTION: Int = 1
    private let EXERCISE_SETS_SECTION: Int = 2
    private let EXERCISE_END_EARLY_SECTION: Int = 3
    fileprivate var currentExerciseSet: Int16 = 0
    
    func updateLabels(){
        for cell in tableView.visibleCells{
            if let c = cell as? ExerciseCell{
                c.updateLabel()
            }
        }
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
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if workout.workoutCompleted(){
            switch section{
            case EXERCISE_END_EARLY_SECTION: return 1
            default: return 0
            }
        }else{
            switch section{
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
            case EXERCISE_SECTION, ADJUST_KG_SECTION: return 0.0
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
                c.label.text = workout.exercise(atOrder: currentExerciseSet)?.exerciseDefinition().name ?? ""
                c.viewController = self
                c.exercise = workout.exercise(atOrder: currentExerciseSet)
            }
            return cell
        }else if indexPath.section == ADJUST_KG_SECTION{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ADJUST_KG_CELL) else{
                return UITableViewCell()
            }
            if let c = cell as? AdjustKGCell{
                c.exercise = workout.exercise(atOrder: currentExerciseSet)
                c.tableView = self
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
            workout.complete = true
            CoreDataStackSingleton.shared.save()
            WorkoutManager.shared.createNextWorkout(after: workout)
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
    
    func setExerciseSet(_ exerciseSet: ExerciseSet?){
        self.exercise = exerciseSet
        updateLabel()
        slider.maximumValue = Float(exerciseSet?.plan ?? 0.0)
        repsLabel.text = (exerciseSet?.actual ?? 0.0) > 0.0 ? String(exerciseSet?.actual ?? 0) : ""
    }
    
    func updateLabel(){
        if let e = exercise{
            let kg: Double = e.actualKG > 0 ? e.actualKG : e.plannedKG
            label.text = "\(e.exercise?.exerciseDefinition().name ?? "No name"): \(e.plan) x \(kg) KG"
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
        if let e = exercise{
            if e.actualKG < 0{
                // thie means actual has not been updated so set it to the planned
                e.actualKG = e.plannedKG
            }
            e.actual = Double(reps)
            if e.setCompleted(){
                if let wcd = workoutCompletionDelegate{
                    wcd.checkIfWorkoutFinished()
                }
            }

        }
    }
    
}

class ExerciseDescriptionCell: UITableViewCell{
    
    @IBOutlet weak var label: UILabel!
    var exercise: Exercise?
    var viewController: UIViewController?
    
    @IBAction func infoTapped(_ sender: Any) {
        if let vc = viewController{
            if let e = exercise{
                let alert = UIAlertController(title: e.exerciseDefinition().name, message: e.exerciseDefinition().description, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                vc.present(alert, animated: true, completion: nil)
            }
        }
    }
}

class AdjustKGCell: UITableViewCell{
    
    var exercise: Exercise?
    var tableView: WorkoutTableViewController?
    
    @IBAction func minus(_ sender: Any) {
        if let e = exercise{
            for s in e.exerciseSets(){
                let baseKG: Double = s.actualKG > 0 ? s.actualKG : s.plannedKG
                s.actualKG = max(0,max(baseKG,0) - 1.0)
            }
        }
        reload()
    }
    
    @IBAction func plus(_ sender: Any) {
        if let e = exercise{
            for s in e.exerciseSets(){
                let baseKG: Double = s.actualKG > 0 ? s.actualKG : s.plannedKG
                s.actualKG = max(baseKG, 0) + 1.0
            }
        }
        reload()
    }
    
    private func reload(){
        if let tv = tableView{
            tv.updateLabels()
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


