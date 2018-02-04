
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
    
    var project: Project? {
        didSet {
            guard let project = project else {
                return
            }
            
            self.schemeTextField.stringValue = project.scheme
        }
    }
    
    @IBAction func didTouchUpInsideApplyButton(_ button: NSButton) {

        guard let project = project else {
            return
        }

        let scheme = self.schemeTextField.stringValue
        
        let delegate = NSApplication.shared.delegate as? AppDelegate
        
        delegate?.projects = [Project(name: project.name, scheme: scheme, origin: project.origin)]
    }
}
