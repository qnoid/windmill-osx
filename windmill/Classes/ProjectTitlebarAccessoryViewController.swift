//
//  ProjectTitlebarAccessoryViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 07/07/2016.
//  Copyright © 2016 qnoid.com. All rights reserved.
//

import AppKit

class ProjectTitlebarAccessoryViewController: NSTitlebarAccessoryViewController {
    @IBOutlet weak var schemeTextField: NSTextField!
    
    var project: Project! {
        didSet {
            self.schemeTextField.stringValue = project.scheme
        }
    }
    
    @IBAction func didTouchUpInsideApplyButton(button: NSButton) {
        
        let scheme = self.schemeTextField.stringValue
        
        let project = Project(name: self.project.name, scheme: scheme, origin: self.project.origin)
        
        NSOutputStream.outputStreamOnProjects().write([project])
    }
}
