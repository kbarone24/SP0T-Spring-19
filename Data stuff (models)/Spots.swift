//
//  Spots.swift
//  SP0T
//
//  Created by kbarone on 8/2/18.
//  Copyright © 2018 Spot LLC. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreLocation

class Spot
{
    let name: String
    let creatorUID: String
    let directions: String
    let id : String
    let secretLevel: String
    var firstImageURL: String
    
  /*  enum secretLevel: String {
        case NONE
        case LOW
        case MEDIUM
        case HIGH
    }*/
    
    init(id: String, name: String, creatorUID: String, directions: String, secretLevel: String) {
        
        self.id = id
        self.name = name
        self.creatorUID = creatorUID
        self.directions = directions
        self.secretLevel = secretLevel
        self.firstImageURL = ""
    }
    
    func save() {
        //reference to database
        let ref = DatabaseRef.spots(id: id).reference()
        
        //setvalue of the reference
        ref.setValue(toDictionary())
        
    }
    
    func toDictionary() -> [String : Any]
    {
        return [
            "id" : id,
            "creatorUID" : creatorUID,
            "directions" : directions,
            "name" : name,
            "secretLevel" : secretLevel,
            "firstImageURL" : firstImageURL,
        ]
}
 /*  public func getID() -> String {
        return self.id
    }*/
}
