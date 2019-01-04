//
//  ProfileVC.swift
//  SP0T
//
//  Created by kbarone on 7/28/18.
//  Copyright © 2018 Spot LLC. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseUI
import AssetsLibrary


class ProfileVC: UIViewController {
    
  
    @IBOutlet weak var quickView: UIView!
    
    @IBOutlet weak var spotCount: UILabel!
    
    @IBOutlet weak var friendsCount: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var selectNewPicLabel: UILabel!
    
    var selectedImage: UIImage?
    
    let uid = Auth.auth().currentUser?.uid
 
    
    //temporary logout function-- doesn't return to where it needs to go
    
    @IBAction func logoutPressed(_ sender: Any) {
        do {
            
            try Auth.auth().signOut()
        } catch {
            print("There was a problem logging out")
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        
       

        quickView.layer.cornerRadius = 10.0
        quickView.clipsToBounds = true
        
       // let tempTab = self.tabBarController?.tabBar.items![1].image
        //let tabImage = tempTab?.roundedWithBorder(width: 1.0, color: UIColor.init(red: 99/255, green: 229/255, blue: 205/255, alpha: 1.0))
     
        
        
   //set navigation bar to clear and font to white (green commented out)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true

        let attributes = [
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.font: UIFont(name: "Menlo", size: 30)!
            ]
        
         UINavigationBar.appearance().titleTextAttributes = attributes
        
        
        //call to database to fetch username, spotcount, friendscount, check if profile image url exists
        Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
            self.navigationItem.title = dictionary["username"] as?
                String
                print(dictionary["username"] as? String as Any)
                self.spotCount.text = String(dictionary["spotCount"] as! Int)
                print(dictionary["spotCount"] as? Int as Any)
                self.friendsCount.text = String(dictionary["friendsCount"] as! Int)

                print(dictionary["friendsCount"] as? Int as Any)
                
                if (dictionary["profileImageURL"] != nil) {
                    self.selectNewPicLabel.isHidden = true
                 //   let tempURL = dictionary["profileImageURL"]
                    let ref = Storage.storage().reference(forURL: "gs://spot69420.appspot.com").child("profilePic").child(self.uid!)
                    
                    //we can download the url with a reference to the users UID from storage
                    print(ref)
                    ref.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print(error?.localizedDescription as Any)
                        return
                    }
                        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                            if error != nil {
                                print(error as Any)
                                return
                            }
                            
                            guard let imageData = UIImage(data: data!) else { return }
                            
                            DispatchQueue.main.async {
                                self.profileImage.image = imageData
                            }
                        }).resume()
                })
            }
        }
            
        }, withCancel: nil)
        
        //eventually, we want to only be able to click the the main profile when originally selecting a profile picture. After we'll move this to user settings
        
        profileImage.isUserInteractionEnabled = true
        let tapGesture =  UITapGestureRecognizer(target: self, action: #selector(ProfileVC.handleSelectProfileImageView))
        profileImage.addGestureRecognizer(tapGesture)
}
    
    @objc func handleSelectProfileImageView() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
//method for letting the user select their own profile image
extension ProfileVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("picked")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            //the storage reference is the users uid for easy retrieval
            
            let storageRef = Storage.storage().reference(forURL: "gs://spot69420.appspot.com").child("profilePic").child(uid!)
            let databaseRef =  Database.database().reference().child("users").child(uid!)
            
            //setting the image that we selected in the selector to our profile image. It doesn't work with UI right now to display the new image, need to fix
            
            selectedImage = image
            self.profileImage.image = image
            
            let newTabImage =  self.resizeImage(image: image, targetSize: CGSize(width: 50.0, height: 50.0))
            self.tabBarController?.tabBar.items![1].image = newTabImage.withRenderingMode(.alwaysOriginal)
             self.tabBarController?.tabBar.items![1].selectedImage = newTabImage.withRenderingMode(.alwaysOriginal)
            
            //update data and profile image url
            if let pickedImage = selectedImage, let imageData = UIImageJPEGRepresentation(pickedImage, 0.25) {
                storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                    if error != nil {
                        return
                    }
                    storageRef.downloadURL { (url, error) in
                        guard let profileImageURL = url?.absoluteString else {
                            return
                    }
                        let values = ["profileImageURL":profileImageURL]
                        databaseRef.updateChildValues(values) { (err, ref) in
                            
                            if err != nil {
                                print(err!)
                                return
                            }
                }
             }
                    
        }
        selectNewPicLabel.isHidden = true
        dismiss(animated: true, completion: nil)
    }
}
}
}

