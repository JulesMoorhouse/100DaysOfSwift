//
//  Storm.swift
//  StormViewer
//
//  Created by Julian Moorhouse on 07/08/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import UIKit

class Storm: NSObject, Codable {
    var pictureName: String
    var viewCount: Int
    
    init(pictureName: String, viewCount: Int) {
        self.pictureName = pictureName
        self.viewCount = viewCount
    }
}
