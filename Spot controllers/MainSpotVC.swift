//
//  MainSpotVC.swift
//  SP0T
//
//  Created by kbarone on 8/4/18.
//  Copyright © 2018 Spot LLC. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class MainSpotVC:UIViewController {
    
    var spotID = String()


    @IBOutlet weak var firstImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        let attributes = [
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.font: UIFont(name: "Menlo", size: 30)!
        ]
        
        UINavigationBar.appearance().titleTextAttributes = attributes
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        //call to database

        print(Database.database().reference().child("spots").child(spotID))
        Database.database().reference().child("spots").child(spotID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.navigationItem.title = dictionary["name"] as?
                String

                print("first image check" )
                if (dictionary["firstImageURL"] != nil) {
                    let ref = Storage.storage().reference(forURL: "gs://spot69420.appspot.com").child("spotPics").child(self.spotID)
                    
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
                            
                            print(imageData)
                            DispatchQueue.main.async {
                                self.firstImage.image = imageData
                            }
                        }).resume()
                    })
                }
            }
            
            
        }, withCancel: nil)
    }
}
