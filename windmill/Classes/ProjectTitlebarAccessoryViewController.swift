//
//  ProjectTitlebarAccessoryViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 10/3/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import AppKit
import os

class ProjectTitlebarAccessoryViewController: NSTitlebarAccessoryViewController {
    
    @IBOutlet weak var launchButton: NSButton! {
        didSet{
            self.isLaunchButtonEnabledObserver = launchButton.observe(\.isEnabled, options: [.new]) { (button, change) in
                if let isEnabled = change.newValue {
                    if isEnabled {
                        button.toolTip = "Launch the app on the simulator."
                    } else {
                        button.toolTip = "As soon as the test stage is complete, you will be able to run the app on the simulator."
                    }
                }
            }
        }
    }
    
    let log = OSLog(subsystem: "io.windmill.windmill", category: "windmill")
    
    var isLaunchButtonEnabledObserver: NSKeyValueObservation?
    
    var appBundle: AppBundle?
    
    var destination: Devices.Destination?
    
    deinit {
        isLaunchButtonEnabledObserver?.invalidate()
    }
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBAction func launchOnSimulator(_ sender: Any) {
        
        guard let appBundle = appBundle, let destination = destination else {
            os_log("AppBundle and/or Destination are not available.", log: log, type: .debug)
            return
        }
        
        let process = Process.makeLaunch(destination: destination, info: appBundle.info)
        process.launch()
    }
}
