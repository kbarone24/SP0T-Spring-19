//
//  passwordVerification.swift
//  SP0T
//
//  Created by kbarone on 7/5/18.
//  Copyright © 2018 Spot LLC. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

class PasswordVerificationVC: UIViewController {
    
    
    override func viewDidLoad() {
//        var _newPassword = Auth.auth().currentUser?

    }
  /*  var _code = "dummy"
    
    var _segue = true
  
    @IBAction func confirmCode(_ sender: Any) {
        let code = _code
        let newPassword = _newPassword
        
   /*     guard let code = _code.text, code != "" else {
            print("Not valid")
            return
        }
        guard let newPassword = _newPassword.text, newPassword != "" else {
            print("Not valid")
            return
        }*/
        Auth.auth().confirmPasswordReset(withCode: code, newPassword: newPassword) { (error)  in if error != nil {
        /*    self._segue = false
            print(firebaseError.localizedDescription)
            let alert = UIAlertController(title: "Error", message: firebaseError.localizedDescription, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)*/
            return
            }
            
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            let ref = Database.database().reference(fromURL: "https://spot69420.firebaseio.com/")
            let usersReference = ref.child("users").child(uid)
            let values = ["password": newPassword]
            
            usersReference.updateChildValues(values) { (err, ref) in
                
                if err != nil {
                    print(err!)
                    return
                }
                print("Password Updated")
            }
        }
    }*/

}
