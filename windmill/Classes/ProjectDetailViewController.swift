//
//  ProjectDetailViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 20/03/2016.
//  Copyright © 2016 qnoid.com. All rights reserved.
//

import AppKit

extension CALayer {
    
    struct Windmill {
        
        static func positionAnchorPoint(layer: CALayer, anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)) {
            let frame = layer.frame
            layer.anchorPoint = anchorPoint
            layer.frame = frame
        }
    }
}

class ProjectDetailViewController: NSViewController {

    struct Windmill {
        static let spinAnimation: CAAnimation = {
            let basicAnimation = CABasicAnimation(keyPath:"transform.rotation")
            basicAnimation.fromValue = 0.0
            basicAnimation.toValue = NSNumber(double: 2.0 * M_PI)
            basicAnimation.duration = 1.0
            basicAnimation.repeatCount = Float.infinity
            
            return basicAnimation
        }()
    }
    
    @IBOutlet weak var activityIndicatorImageView: NSImageView! {
        didSet{
            activityIndicatorImageView.wantsLayer = true
        }
    }
    
    let defaultCenter = NSNotificationCenter.defaultCenter()
    var scheduler: Scheduler!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.defaultCenter.addObserver(self, selector: Selector("\(NSTask.Notifications.taskDidLaunch):"), name: NSTask.Notifications.taskDidLaunch, object: nil)
        self.defaultCenter.addObserver(self, selector: Selector("\(NSTask.Notifications.taskDidExit):"), name: NSTask.Notifications.taskDidExit, object: nil)
    }
    
    func taskDidLaunch(aNotification: NSNotification)
    {
        CALayer.Windmill.positionAnchorPoint(self.activityIndicatorImageView.layer!)

        let type = TaskType(rawValue: aNotification.userInfo!["type"] as! String)!

        switch(type){
            case .Checkout, .Build, .Test, .Package:
                self.activityIndicatorImageView.image = NSImage(named: type.imageName)
            case .Deploy:
                debugPrint("DEBUG: \(__FILE__):\(__FUNCTION__):\(__LINE__)")
            case .Nightly:
                self.activityIndicatorImageView.image = NSImage(named: "windmill-activity-indicator")
        }
        
        self.activityIndicatorImageView.layer?.addAnimation(Windmill.spinAnimation, forKey: "spinAnimation")
    }
    
    func taskDidExit(aNotification: NSNotification)
    {
        _ = TaskType(rawValue: aNotification.userInfo!["type"] as! String)!
    }
    
}