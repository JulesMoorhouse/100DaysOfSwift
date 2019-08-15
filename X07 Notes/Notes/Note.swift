//
//  Note.swift
//  Notes
//
//  Created by Julian Moorhouse on 15/08/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import Foundation

struct Note {
    var uuid: String?
    var name: String?
    
    init(name: String) {
        self.name = name
        self.uuid = UUID().uuidString
    }
}
