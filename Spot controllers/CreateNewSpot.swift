//
//  CreateNewSpot.swift
//  SP0T
//
//  Created by kbarone on 8/4/18.
//  Copyright © 2018 Spot LLC. All rights reserved.
//

import Foundation
import UIKit
import IQDropDownTextField
import Firebase
import FirebaseStorage
import FirebaseDatabase
import Photos
import GeoFire

class CreateNewSpotVC: UITableViewController {
    
    @IBOutlet weak var spotName: UITextField!
    
    @IBOutlet weak var selectedImage: UIImageView!
    
    @IBOutlet weak var secrecyPicker: IQDropDownTextField!
    
    @IBOutlet weak var directions: UITextField!
    
    var spotID = String()
    
   // var longitudeCoordinate = Double()
  
  //  var latitudeCoordinate = Double()
    
    var newSpotLocation = CLLocation()
    
    
    let pickerController = UIImagePickerController()
    
    var segue = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerController.delegate = self
        
        pickerController.allowsEditing = true
        pickerController.sourceType = .photoLibrary
        
        checkPermission()

        
      /*  let attributes = [
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.font: UIFont(name: "Menlo", size: 20)!
        ]
        UINavigationBar.appearance().titleTextAttributes = attributes
        self.navigationItem.title = "New Spot"*/
        
        secrecyPicker.isOptionalDropDown = false
            secrecyPicker.itemList = ["public", "low", "medium", "high"]
        
        selectedImage.isUserInteractionEnabled = true
        let tapGesture =  UITapGestureRecognizer(target: self, action: #selector(self.handleSelectImageView))
        selectedImage.addGestureRecognizer(tapGesture)
        
    }
    @objc func handleSelectImageView() {
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func createSpotPressed(_ sender: Any) {
        guard let spotNameText = spotName.text, spotNameText != "" else {
            emptyStringAlert()
            return
        }
        guard let directionsText = directions.text, directionsText != "" else {
            emptyStringAlert()
            return
        }
        guard let secretLevelText = secrecyPicker.selectedItem else {
            emptyStringAlert()
            return
        }
        
        let uid = Auth.auth().currentUser?.uid
        spotID = NSUUID().uuidString
        
        
        let storageRef = Storage.storage().reference().child("spotPics").child(spotID)
        //    let storageRef = Storage.storage().reference(forURL: "gs://spot69420.appspot.com").child("spotPics").child(spotID)
        
        let databaseRef =  Database.database().reference().child("spots")

        let founderRefKey = Database.database().reference().child("users").child(uid!).child("foundSpotIDs").childByAutoId()
     //   let founderRef = Database.database().reference().child("users").child(uid!).child("foundSpotIDs")
        let spotVal = ["spotID":spotID]
        founderRefKey.setValue(spotVal)
        
        let geoFireRef = GeoFire(firebaseRef: databaseRef)
        
        let newSpot = Spot(id: spotID, name: spotNameText, creatorUID: uid!, directions: directionsText, secretLevel: secretLevelText)
        
        newSpot.save()
        
        
        
        geoFireRef.setLocation(newSpotLocation, forKey: spotID)

        print("spot saved")
        
        if let pickedImage = selectedImage.image, let imageData = UIImageJPEGRepresentation(pickedImage, 0.25) {
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if error != nil {
                    return
                }

                storageRef.downloadURL { (url, error) in
                    guard let spotImageURL = url?.absoluteString else {
                        return
                    }
                    let values = ["firstImageURL":spotImageURL]
                    databaseRef.child(self.spotID).updateChildValues(values) { (err, ref) in
                        if err != nil {
                            print(err!)
                            return
                        }
            print("image saved")
            self.segue = true
                        self.performSegue(withIdentifier: "segueToSpot", sender: self)
                    }
                }
                
            }
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "segueToSpot" {
            if let nav = segue.destination as? UINavigationController {
                if let vc = nav.topViewController as? MainSpotVC {
                    vc.spotID = self.spotID
                }
            }
            
        }
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier.elementsEqual("segueToSpot")) {
            return self.segue
        }
        else {
            return true
        }
    }

    func checkPermission() {
        let photoAuthorizationStatus =
            PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
    }
    
    func emptyStringAlert() {
        let alert = UIAlertController(title: "Error", message: "All fields must be filled out", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
extension CreateNewSpotVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("picked")
        if let newImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage.image = newImage
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
