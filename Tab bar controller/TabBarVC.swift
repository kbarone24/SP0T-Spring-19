//
//  TabBarVC.swift
//  SP0T
//
//  Created by kbarone on 8/24/18.
//  Copyright © 2018 Spot LLC. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary
import Firebase

class TabBarVC:UITabBarController {
    @IBOutlet weak var mainTabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("tab")
        self.mainTabBar.tintColor = UIColor(red: 0.3137, green: 0.89, blue: 0.761, alpha: 1)
        self.mainTabBar.unselectedItemTintColor = UIColor.white
        self.mainTabBar.barTintColor = UIColor.black
        self.mainTabBar.backgroundColor = UIColor.black
        self.mainTabBar.isTranslucent = false
    }
    
    
}

