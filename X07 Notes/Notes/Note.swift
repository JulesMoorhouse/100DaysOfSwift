//
//  Note.swift
//  Notes
//
//  Created by Julian Moorhouse on 15/08/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import Foundation

class Note: Codable {
    var uuid: String?
    var content: String?
    var folderUuid: String?
    
    init(content: String, folderUuid: String) {
        self.content = content
        self.folderUuid = folderUuid
        self.uuid = UUID().uuidString
    }
}
