//
//  ViewController.swift
//  project-with-build-errors
//
//  Created by Markos Charatzas on 5/3/18.
//  Copyright © 2018 qnoid. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let goodbye = Stringg("Goodbye World")        
        print(goodbye)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

