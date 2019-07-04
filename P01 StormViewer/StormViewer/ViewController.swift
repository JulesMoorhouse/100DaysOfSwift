//
//  ViewController.swift
//  StormViewer
//
//  Created by Julian Moorhouse on 04/07/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var pictures = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("nssl") {
                // this is a picture to load!
                
                pictures.append(item)
            }
        }

        print(pictures)
    }


}

