//
//  ViewController.swift
//  Debugging
//
//  Created by Julian Moorhouse on 12/08/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        print("I'm inside the viewDidLoad method.")
        print(1,2,3,4,5, separator: "-")
        print ("Some message", terminator: "")
        
        assert(1 == 1, "Maths failure!") // never execute in live app
        assert(1 == 2, "Maths failure!")

        //assert(myReallSlowMethod() == true, "The slow method returned false, which is a bad thing.")
        
        // breakpoints
        
        for i in 1...100 {
            print("Got number \(i).")
        }
    }

    //    func myReallySlowMethod() -> Bool {
    //        return false
    //    }

}

