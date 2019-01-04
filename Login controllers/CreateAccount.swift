//
//  ViewController.swift
//  SP0T
//
//  Created by kbarone on 6/14/18.
//  Copyright © 2018 Spot LLC. All rights reserved.
//

//to do:
//need to add rules to make sure that database rules are consistent with firebase authentication.
//check to make sure for no duplicate usernames and emails in database

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class CreateAccountVC: UIViewController {
    
    
    var _segue = false
    
    @IBOutlet weak var _name: UITextField!
  
    @IBOutlet weak var _email: UITextField!
    
    @IBOutlet weak var _username: UITextField!
    
    @IBOutlet weak var _password: UITextField!
    
    //these are for checking for valid password
 
    
    var ref : DatabaseReference! = nil
    // This might be the error or a Storage reference
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        
        //firebase reference
        ref = Database.database().reference(fromURL: "https://spot69420.firebaseio.com/")    }

    
    //this is checking for a valid email
    func isValidEmail(email:String?) -> Bool {
        
        guard email != nil else { return false }
        
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: email)
    }
    
    //checking for password length >= 6
    func isValidPassword(password:String) -> Bool {
        if (password.count >= 6) {
            return true
        }
        return false
    }
    
    
    @IBAction func createAccount(_ sender: Any) {
        //need to check if valid username, password, email- all of these should come up if fields are blank
        //need to check to make sure another user doesn't have username
        
        guard let name = _name.text, name != "" else {
            emptyStringAlert()
            return
        }
        guard let email = _email.text, email != "" else {
            emptyStringAlert()
            return
        }
        guard let username = _username.text, username != "" else {
            emptyStringAlert()
            return
        }
        guard let password = _password.text, password != "" else {
            emptyStringAlert()
            return
        }
        
        if !(isValidPassword(password: password)) {
            passwordLengthAlert()
            return
            }
        if !(isValidEmail(email: email)) {
            emailAlert()
            return
            }
            
            //firebase createUser
            else { Auth.auth().createUser(withEmail: email, password: password) { (user, error)  in if let firebaseError = error {
            self.firebaseAlert(localDescription: firebaseError.localizedDescription)
            
            
            self._segue = false
            return
        }
            //moved this up so that we create account on first tap
            self._segue = true

            }
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }

            let newUser = User(uid: uid, email: email, password: password, username: username, name: name)
            print("gothere")
            newUser.save()
            self.performSegue(withIdentifier: "createAccountToIntro", sender: self)

        }
    }
            
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
                if (identifier.elementsEqual("createAccountToIntro")) {
                    return self._segue
                }
                else {
                    return true
                }
           }
    //alerts to display
    
    func firebaseAlert(localDescription: String) {
    let alert = UIAlertController(title: "Error", message: localDescription, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(action)
    self.present(alert, animated: true, completion: nil)
    }
    
    func emptyStringAlert() {
        let alert = UIAlertController(title: "Error", message: "All fields must be filled out", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    func passwordLengthAlert() {
        let alert = UIAlertController(title: "Error", message: "Password must be at least 6 characters", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    func emailAlert() {
        let alert = UIAlertController(title: "Error", message: "Not a valid email address", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

            
    }


 /*   @IBAction func loginPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "signUpToLogin",
*/

