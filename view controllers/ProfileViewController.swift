//
//  ProfileViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 26/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit
import HealthKit
import Firebase
import FirebaseUI

class ProfileViewController: UITableViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var sexTextField: UITextField!
    @IBOutlet weak var restingHRTextField: UITextField!
    @IBOutlet weak var restingHRDateTextField: UITextField!
    @IBOutlet weak var hrvTextField: UITextField!
    @IBOutlet weak var hrvDateTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var heightDateTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var weightDateTextField: UITextField!
    @IBOutlet weak var loginRegisterButton: UIButton!
    private var buttonIsLogin: Bool = true
    
    @IBAction func authorizeHealthKit(_ sender: Any) {
        HealthKitAccess.shared.authorizeHealthKit { (success, error) in
            if success{
                print("Authorized")
                let alert = UIAlertController(title: "Authorisation Success", message: "Thank you. Access to healthkit succesfully given", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                print("Authorization failed: \(String(describing: error))")
                let alert = UIAlertController(title: "Authorisation Failure", message: "Thank you. Access to healthkit failed", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func loginRegister(_ sender: Any) {
        if buttonIsLogin{
            if let authUI = FUIAuth.defaultAuthUI() {
                authUI.delegate = self
                let emailAuth = FUIEmailAuth()
                emailAuth.signIn(withPresenting: self, email: nil)
                authUI.providers = [emailAuth]
                let authVC = authUI.authViewController()
                present(authVC, animated: true, completion: {
                    self.buttonIsLogin = false
                    self.loginRegisterButton.titleLabel?.text = "Logout"
                })
            }else{
                
            }
        }else{
            do{
                try Auth.auth().signOut()
                self.buttonIsLogin = true
                self.loginRegisterButton.titleLabel?.text = "Login / Register"
            }catch{
                print("signout failed")
                print(error)
            }
        }
    }
    
    @IBAction func test(_ sender: UIButton) {
        WorkoutManager.shared.saveLatestPowerUpToCloud()
    }
    
    @IBAction func restingHRInfoTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Resting Heart Rate Explantion", message: "This is a message", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func hrvInfoTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Heart Rate Variability Explantion", message: "This is a message", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func heightInfoTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Height Explantion", message: "This is a message", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func weightInfoTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Weight Explantion", message: "This is a message", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let df = DateFormatter()
        df.dateFormat = "dd MMM yy"
        
        if let user = Auth.auth().currentUser{
            emailTextField.text = user.email
        }else{
            emailTextField.text = "Not Set"
        }
        
        if let dob = HealthKitAccess.shared.getDOB(){
            self.dobTextField.text = df.string(from: dob)
        }else{
            self.dobTextField.text = "Not Set"
        }

        self.sexTextField.text = HealthKitAccess.shared.getSexString()
        
        HealthKitAccess.shared.getLatestRestingHR { (hrString, hr, date) in
            self.restingHRTextField.text = hrString
            if let d = date{
                self.restingHRDateTextField.text = df.string(from: d)
            }
        }
        
        HealthKitAccess.shared.getLatestHRV { (hrvString, hrv, date) in
            self.hrvTextField.text = hrvString
            if let d = date{
                self.hrvDateTextField.text = df.string(from: d)
            }
        }

        HealthKitAccess.shared.getLatestKG { (heightString, metres, date) in
            self.heightTextField.text = heightString
            if let d = date{
                self.heightDateTextField.text = df.string(from: d)
            }
        }
        
        HealthKitAccess.shared.getLatestKG { (displayString, kg, date) in
            self.weightTextField.text = displayString
            if let d = date{
                self.weightDateTextField.text = df.string(from: d)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = Auth.auth().currentUser{
            loginRegisterButton.titleLabel?.text = "Logout"
            buttonIsLogin = false
        }else{
            loginRegisterButton.titleLabel?.text = "Login / Register"
            buttonIsLogin = true
        }
    }


    @IBAction func createTestData(_ sender: Any) {
        // create some data to allow testing of various features. For now aim to create a years worth of data
//        WorkoutManager.shared.createTestWorkoutData()
        WorkoutManager.shared.createTestDataUsingBuiltInProgresions()

    }
}

extension ProfileViewController: FUIAuthDelegate{
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, url: URL?, error: Error?) {
        if let error = error{
            print(error)
        }
    }
}
