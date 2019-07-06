//
//  LoginViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 19/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit
//import Firebase
import FirebaseUI

class LoginViewController: UIViewController{
    
    @IBAction func login(_ sender: Any) {
        if let authUI = FUIAuth.defaultAuthUI() {
            authUI.delegate = self
            let emailAuth = FUIEmailAuth()
            emailAuth.signIn(withPresenting: self, email: nil)
            authUI.providers = [emailAuth]
            let authVC = authUI.authViewController()
            present(authVC, animated: true, completion: nil)
        }else{
            // log error
        }
    }
    
}


extension LoginViewController: FUIAuthDelegate{
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, url: URL?, error: Error?) {
        if let error = error{
            // we have an error
            print(error)
//            return
        }
        performSegue(withIdentifier: "MainTabController", sender: self)
    }
}
