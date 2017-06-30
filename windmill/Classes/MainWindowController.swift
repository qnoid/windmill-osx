//
//  MainWindowController.swift
//  windmill
//
//  Created by Markos Charatzas on 10/01/2016.
//  Copyright © 2016 qnoid.com. All rights reserved.
//

import AppKit


class MainWindowController: NSWindowController, NSToolbarDelegate {
    
    @IBOutlet weak var toolbar: NSToolbar! {
        didSet {
            toolbar.delegate = self
        }
    }
    
    fileprivate lazy var projectTitlebarAccessoryViewController: ProjectTitlebarAccessoryViewController = { [weak storyboard = self.storyboard] in
        storyboard?.instantiateController(withIdentifier: "ProjectTitlebarAccessoryViewController") as! ProjectTitlebarAccessoryViewController
        }()
    

    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.collectionBehavior = [self.window!.collectionBehavior, .fullScreenAllowsTiling]
        self.window?.addTitlebarAccessoryViewController(self.projectTitlebarAccessoryViewController)
        self.window?.titleVisibility = .hidden
        self.window?.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
        
        NotificationCenter.default.post(name: Notification.Name("mainWindowDidLoad"), object: self)
    }    
}
