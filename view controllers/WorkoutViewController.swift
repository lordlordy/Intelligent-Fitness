//
//  TableViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 24/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit

class WorkoutViewController: UIViewController {

    var workout: Workout = WorkoutManager().nextWorkout()
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var workoutTypeLabel: UILabel!
    
    private var datePicker: UIDatePicker?
    private let df = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        df.dateFormat = "yyyy-MM-dd"
        dateTextField.text = df.string(from: Date())
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        if view.backgroundColor?.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) ?? false{
            dateTextField.backgroundColor = UIColor(hue: hue, saturation: saturation, brightness: brightness * 1.1, alpha: alpha)
        }else{
            dateTextField.backgroundColor = UIColor.clear
        }
        dateTextField.textColor = UIColor.white
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecogniser:)))
        view.addGestureRecognizer(tapGesture)
        
        dateTextField.inputView = datePicker
    }
    
    
    @objc func viewTapped(gestureRecogniser: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker){
        dateTextField.text = df.string(from: datePicker.date)
        workout.date = datePicker.date
        view.endEditing(true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        workoutTypeLabel.text = workout.type
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "StartWorkout"{
            if let vc = segue.destination as? WorkoutTableViewController{
                vc.workout = workout
            }
        }
    }
    
}

