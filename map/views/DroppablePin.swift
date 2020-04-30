//
//  DroppablePin.swift
//  map
//
//  Created by Hosam Elnabawy on 4/29/20.
//  Copyright © 2020 Hosam Elnabawy. All rights reserved.
//

import UIKit
import MapKit


class DroppablePin: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
    
}
