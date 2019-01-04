//
//  DatabaseReference.swift
//  SP0T
//
//  Created by kbarone on 7/25/18.
//  Copyright © 2018 Spot LLC. All rights reserved.
//

import Foundation
import Firebase

enum DatabaseRef
{
    case root
    case users(uid: String)
    case spots(id: String)
    //mark as public
   
    
    func reference() -> DatabaseReference
    {
        switch self {
            case .root:
                return rootReference
            default:
                return rootReference.child(path)
        }
    }
    
    private var rootReference: DatabaseReference {
        return Database.database().reference()
    }
   
    private var path: String {
        switch self {
        case .root:
            return ""
        case .users(let uid):
            return "users/\(uid)"
        case .spots(let id):
            return "spots/\(id)"
    }
    }
}
/*enum StorageRef
{
    case root
    case profilePics
    
    func reference() -> StorageReference {
        switch self {
        case .root:
            return rootReference
        default:
        return rootReference.child(path)
    }
    }
    private var rootReference: StorageReference {
        return Storage.storage().reference()
    }
    private var path: String {
        switch self{
        case .root:
            return ""
        case .profilePics:
            return "profilePics"
        }
    }
}*/
