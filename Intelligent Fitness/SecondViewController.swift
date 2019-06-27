//
//  SecondViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 14/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var carryTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        carryTextField.delegate = self
    }


}

extension SecondViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    
}

