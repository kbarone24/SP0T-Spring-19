//
//  CustomCalloutView.swift
//  SP0T
//
//  Created by kbarone on 9/2/18.
//  Copyright © 2018 Spot LLC. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class CustomCalloutView: UIView {
    
    @IBOutlet weak var customCallout: UIView!
    
    @IBOutlet weak var spotName: UILabel!
    
    @IBOutlet weak var founder: UILabel!
    
    @IBOutlet weak var spotPicture: UIImageView!
    
    
    private var dataModel = CustomAnnotation(spotID: "", spotTitle: "", picture: #imageLiteral(resourceName: "spotRainbow"), coordinate: CLLocationCoordinate2D(latitude: 10.0, longitude: 10.0), subtitle: "")
    
        func viewDidLoad() {
            dataModel.delegate = self
            dataModel = dataModel.requestData()
            spotName.text = dataModel.spotTitle
            founder.text = dataModel.subtitle
            spotPicture.image = dataModel.picture
    }
    
    var preferredContentSize:CGSize{
        if customCallout != nil{
            return customCallout.sizeThatFits(self.bounds.size)
        }
        else{
            return CGSize(width: 0, height: 0)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func getID() -> String {
        return dataModel.spotID!
    }
    
}
extension UIView: AnnotationModelDelegate {
    func didRecieveDataUpdate(data: String) {
        print(data)
    }
}
