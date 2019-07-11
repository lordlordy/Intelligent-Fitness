//
//  FunctionalFitnessTestViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 04/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit

class FunctionalFitnessTestViewController: UIViewController {

    @IBOutlet weak var dateTextField: UITextField!
    
    private var datePicker: UIDatePicker?
    private let df = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let testDate: Date = WorkoutManager.shared.nextFunctionalFitnessTest().date ?? Date()
        df.dateFormat = "yyyy-MM-dd"
        dateTextField.text = df.string(from: testDate)
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
        datePicker?.date = testDate
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecogniser:)))
        view.addGestureRecognizer(tapGesture)
        
        dateTextField.inputView = datePicker
    }
    
    @objc func viewTapped(gestureRecogniser: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker){
        dateTextField.text = df.string(from: datePicker.date)
        WorkoutManager.shared.nextFunctionalFitnessTest().date = datePicker.date
        view.endEditing(true)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "StartFFT"{
//            if let vc = segue.destination as? FunctionalFitnessTestTableViewController{
////                vc.testDate = datePicker?.date ?? Date()
//                if let d = datePicker?.date{
//                    WorkoutManager.shared.nextFunctionalFitnessTest().date = d
//                }
//            }
//        }
//    }

}
