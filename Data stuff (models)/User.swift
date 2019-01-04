//
//  User.swift
//  SP0T
//
//  Created by kbarone on 7/24/18.
//  Copyright © 2018 Spot LLC. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary
import Firebase

class User
{
    let uid: String
    var email: String
    var password: String
    var username: String
    var name: String
    var points: Int
    var friendsCount: Int
    var spotCount: Int
    var profilePic: UIImage?
    var profileImageURL: String
    var createdSpots: Array<Any>
    var unlockedSpots: Array<Any>
    
    init(uid: String, email: String, password: String, username: String, name: String) {
        self.uid = uid
        self.email = email
        self.password = password
        self.username = username
        self.name = name
        self.profilePic = #imageLiteral(resourceName: "blackprofile")
        self.points = 10
        self.friendsCount = 1
        self.spotCount = 0
        self.profileImageURL = String()
        self.createdSpots = Array()
        self.unlockedSpots = Array()
        
    }
    
    func save() {
        //reference to database
        let ref = DatabaseRef.users(uid: uid).reference()
        
        //setvalue of the reference
        ref.setValue(toDictionary())
        
        //profile image stuff
    }
    
    func toDictionary() -> [String : Any]
    {
        return [
            "uid" : uid,
            "email" : email,
            "username" : username,
            "name" : name,
            "password" : password,
            "points" : points,
            "spotCount" : spotCount,
            "friendsCount" : friendsCount,
            "profileImageURL" : profileImageURL,
            "createdSpots" : createdSpots,
            "unlockedSpots" : unlockedSpots
        ]
    }
    
}
