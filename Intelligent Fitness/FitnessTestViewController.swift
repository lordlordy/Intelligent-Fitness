//
//  FitnessTestViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 27/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit

class FitnessTestViewController: UITableViewController {

    @IBOutlet weak var standingBroadJumpTextField: UITextField!{didSet{standingBroadJumpTextField.addDoneCancelButton()}}
    @IBOutlet weak var plankTextField: UITextField!{didSet{plankTextField.addDoneCancelButton()}}
    @IBOutlet weak var deadHangTextField: UITextField!{didSet{deadHangTextField.addDoneCancelButton()}}
    @IBOutlet weak var farmersCarryTextField: UITextField!{didSet{farmersCarryTextField.addDoneCancelButton()}}
    @IBOutlet weak var squatTextField: UITextField!{didSet{squatTextField.addDoneCancelButton()}}
    @IBOutlet weak var srtTextField: UITextField!{didSet{srtTextField.addDoneCancelButton()}}
    @IBOutlet weak var textField: UITextView!{didSet{textField.addDoneCancelButton()}}
    @IBOutlet weak var testDate: UITextField!
    
    private var datePicker: UIDatePicker?
    private var functionalFitnessTest: FunctionalFitnessTest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        standingBroadJumpTextField.delegate = self
        plankTextField.delegate = self
        deadHangTextField.delegate = self
        farmersCarryTextField.delegate = self
        squatTextField.delegate = self
        srtTextField.delegate = self

        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecogniser:)))
        view.addGestureRecognizer(tapGesture)
        
        testDate.inputView = datePicker
    }
    
    
    @IBAction func saveTest(_ sender: Any) {
        print("saving test")
        if functionalFitnessTest == nil{
            functionalFitnessTest = CoreDataStackSingleton.shared.newFunctionalFitnessTest()
        }
        functionalFitnessTest?.date = datePicker?.date
        functionalFitnessTest?.deadHang = Int16(deadHangTextField.text!)!
        functionalFitnessTest?.farmersCarry = Int16(farmersCarryTextField.text!)!
        functionalFitnessTest?.notes = textField.text
        functionalFitnessTest?.plank = Int16(plankTextField.text!)!
        functionalFitnessTest?.sittingRisingTest = Int16(srtTextField.text!)!
        functionalFitnessTest?.squat = Int16(squatTextField.text!)!
        functionalFitnessTest?.standingBroadJump = Int16(standingBroadJumpTextField.text!)!
        CoreDataStackSingleton.shared.save()
    }
    
    @objc func viewTapped(gestureRecogniser: UITapGestureRecognizer){
        view.endEditing(true)
    }

    @objc func dateChanged(datePicker: UIDatePicker){
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        testDate.text = df.string(from: datePicker.date)
        view.endEditing(true)
    }
}


extension FitnessTestViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//extension FitnessTestViewController: UITextViewDelegate{
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if(text == "\n"){
//            textView.resignFirstResponder()
//            return false
//        }
//        return true
//    }
//}
