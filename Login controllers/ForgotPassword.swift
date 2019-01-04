//
//  forgotPassword.swift
//  SP0T
//
//  Created by kbarone on 7/5/18.
//  Copyright © 2018 Spot LLC. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var _email: UITextField!
    
    var _segue = true
    
    
    @IBAction func sendForgotPassword(_ sender: Any) {
        
        guard let email = _email.text, email != "" else {
            print("Not a valid username")
            return
        }
        
        //send password reset if email exists, only perform segue to next screen if email exists
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error)  in if let firebaseError = error {
            self._segue = false
            print(firebaseError.localizedDescription)
            let alert = UIAlertController(title: "Error", message: firebaseError.localizedDescription, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
            }

        }
        
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
            return self._segue
        }
    }
    

