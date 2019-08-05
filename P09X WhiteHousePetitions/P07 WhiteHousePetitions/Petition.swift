//
//  Petition.swift
//  P07 WhiteHousePetitions
//
//  Created by Julian Moorhouse on 04/08/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import Foundation

struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}
