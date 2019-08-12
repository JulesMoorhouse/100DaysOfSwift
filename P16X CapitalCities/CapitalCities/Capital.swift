//
//  Capital.swift
//  CapitalCities
//
//  Created by Julian Moorhouse on 12/08/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import UIKit
import MapKit

class Capital: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    var wikiUrl: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String, wikiUrl: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
        self.wikiUrl = wikiUrl
    }
}
