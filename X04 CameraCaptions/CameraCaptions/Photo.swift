//
//  Photo.swift
//  CameraCaptions
//
//  Created by Julian Moorhouse on 07/08/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import UIKit

class Photo: NSObject, Codable {
    var imageFileName: String
    var caption: String
    
    init(imageFileName: String, caption: String) {
        self.imageFileName = imageFileName
        self.caption = caption
    }
}
