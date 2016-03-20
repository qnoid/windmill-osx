//
//  ProjectDetailViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 20/03/2016.
//  Copyright © 2016 qnoid.com. All rights reserved.
//

import AppKit

class ProjectDetailViewController: NSViewController {

    @IBOutlet weak var checkoutProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var buildProgressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var originTextField: NSTextField!
    @IBOutlet weak var commitTextField: NSTextField!
    
    let defaultCenter = NSNotificationCenter.defaultCenter()
    var scheduler: Scheduler!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.defaultCenter.addObserver(self, selector: Selector("\(NSTask.Notifications.taskDidLaunch):"), name: NSTask.Notifications.taskDidLaunch, object: nil)
        self.defaultCenter.addObserver(self, selector: Selector("\(NSTask.Notifications.taskDidExit):"), name: NSTask.Notifications.taskDidExit, object: nil)
    }
    
    func taskDidLaunch(aNotification: NSNotification)
    {
        let type = TaskType(rawValue: aNotification.userInfo!["type"] as! String)!

        switch(type){
        case .OnCommit:
            self.checkoutProgressIndicator.startAnimation(self)
        case .Nightly:
            self.buildProgressIndicator.startAnimation(self)
        }
    }
    
    func taskDidExit(aNotification: NSNotification)
    {
        let type = TaskType(rawValue: aNotification.userInfo!["type"] as! String)!
        
        switch(type){
        case .OnCommit:
            self.checkoutProgressIndicator.stopAnimation(self)
        case .Nightly:
            self.buildProgressIndicator.stopAnimation(self)
        }
    }
    
}