//
//  CustomAnnotation.swift
//  SP0T
//
//  Created by kbarone on 9/2/18.
//  Copyright © 2018 Spot LLC. All rights reserved.
//

import Foundation
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    let spotID: String?
    let spotTitle: String?
    let picture: UIImage?
    let subtitle: String?
    weak var delegate: AnnotationModelDelegate?
    
    init(spotID: String, spotTitle: String, picture: UIImage, coordinate: CLLocationCoordinate2D, subtitle: String) {
        self.spotID = spotID
        self.spotTitle = spotTitle
        self.picture = picture
        self.coordinate = coordinate
        self.subtitle = subtitle
        super.init()
    }
        func requestData() -> CustomAnnotation {
            // the data was received and parsed to String
            let data = "anything"
            delegate?.didRecieveDataUpdate(data: data)
            return self
        }
    }

