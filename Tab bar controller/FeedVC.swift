//
//  FeedVC.swift
//  SP0T
//
//  Created by kbarone on 7/28/18.
//  Copyright © 2018 Spot LLC. All rights reserved.
//

import Foundation
import UIKit

class FeedVC:UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
    }
}

extension FeedVC:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        cell.backgroundColor = UIColor.green
        return cell
    }
}


