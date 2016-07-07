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

extension NSView {
    
    func startAnimation() {
        self.layer?.addAnimation(CAAnimation.Windmill.spinAnimation, forKey: "spinAnimation")
    }
    
    func stopAnimation() {
        self.layer?.removeAnimationForKey("spinAnimation")
    }
}

class MainViewController: NSViewController, WindmillDelegate {
    
    let logger : ConsoleLog = ConsoleLog()
    
    @IBOutlet weak var windmillButton: NSButton! {
        didSet{
            windmillButton.toolTip = NSLocalizedString("windmill.toolTip", comment: "")
            windmillButton.showsBorderOnlyWhileMouseInside = true
        }
    }
    @IBOutlet weak var activityTextfield: NSTextField!
    @IBOutlet weak var checkoutActivityView: ActivityView!
    @IBOutlet weak var buildActivityView: ActivityView!
    @IBOutlet weak var testActivityView: ActivityView!
    @IBOutlet weak var archiveActivityView: ActivityView!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    weak var topConstraint: NSLayoutConstraint!
    
    lazy var activityViews: [ActivityType: ActivityView] = { [unowned self] in
        return [.Checkout: self.checkoutActivityView, .Build: self.buildActivityView, .Test: self.testActivityView, .Archive: self.archiveActivityView]
    }()
    
    let defaultCenter = NSNotificationCenter.defaultCenter()
    var scheduler: Scheduler!
    
    override func updateViewConstraints() {
        
        if(self.topConstraint == nil) {
        
            let topAnchor = self.view.window?.contentLayoutGuide!.topAnchor
        
            let topConstraint = self.checkoutActivityView.topAnchor.constraintEqualToAnchor(topAnchor, constant: 8)
        
            topConstraint!.active = true
        
            self.topConstraint = topConstraint
        }
        
        super.updateViewConstraints()
    }
    
    override func loadView() {
        super.loadView()
        
        self.view.window?.addTitlebarAccessoryViewController(ProjectTitlebarAccessoryViewController())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layerContentsRedrawPolicy = .OnSetNeedsDisplay
        self.view.layer?.backgroundColor = NSColor.blackColor().CGColor


        self.defaultCenter.addObserver(self, selector: #selector(MainViewController.taskDidLaunch(_:)), name: NSTask.Notifications.taskDidLaunch, object: nil)
        self.defaultCenter.addObserver(self, selector: #selector(MainViewController.taskError(_:)), name: NSTask.Notifications.taskError, object: nil)
        self.defaultCenter.addObserver(self, selector: #selector(MainViewController.taskDidExit(_:)), name: NSTask.Notifications.taskDidExit, object: nil)
    }
    
    override func viewDidAppear() {
        CALayer.Windmill.positionAnchorPoint(self.windmillButton.layer!)
    }

    func append(textView: NSTextView, output: String) {
        textView.string?.appendContentsOf("\n \(output)")
        
        let range = NSRange(location:textView.string!.characters.count,length:0)
        textView.scrollRangeToVisible(range)
    }
    
    func windmill(windmill: Windmill, standardOutput: String) {
        self.append(self.textView, output: standardOutput)
    }
    
    func windmill(windmill: Windmill, standardError: String) {
        self.append(self.textView, output: standardError)
        self.textViewHeightConstraint.animator().constant = 105
    }

    
    func windmill(windmill: Windmill, projects: Array<Project>, addedProject project: Project) {
    }
    
    func windmill(windmill: Windmill, willDeployProject project: Project) {
        self.textView.string = ""
        self.windmillButton.startAnimation()
        self.windmillButton.toolTip = NSLocalizedString("windmill.toolTip.active", comment: "")
        self.view.window?.title = project.name        
        self.windmillButton.image = NSImage(named: "windmill-activity-indicator-inactive")
        for activityView in self.activityViews.values {
            activityView.hidden = true
            activityView.alphaValue = 0.5
        }
        
        
        let projectTitlebarAccessoryViewController = self.view.window?.titlebarAccessoryViewControllers[0] as! ProjectTitlebarAccessoryViewController
        projectTitlebarAccessoryViewController.project = project        
    }
    
    func taskDidLaunch(aNotification: NSNotification) {
        
        let activityType = ActivityType(rawValue: aNotification.userInfo!["activity"] as! String)!
        self.logger.log(.DEBUG,  activityType)
        
        switch(activityType){
            case .Checkout, .Build, .Test, .Archive:
                self.windmillButton.image = NSImage(named: activityType.imageName)
                self.activityViews[activityType]?.hidden = false
            default:
            break
        }
        
        self.activityTextfield.stringValue = activityType.description
    }

    func taskError(aNotification: NSNotification) {
        self.windmillButton.toolTip = NSLocalizedString("windmill.toolTip.error", comment: "")
        self.windmillButton.stopAnimation()
        
        self.activityTextfield.stringValue = "stopped"
    }

    func taskDidExit(aNotification: NSNotification) {
        
        let activityType = ActivityType(rawValue: aNotification.userInfo!["activity"] as! String)!
        
        switch(activityType){
        case .Checkout, .Build, .Test, .Archive:
            self.activityViews[activityType]?.alphaValue = 1.0
        default:
            break
        }
    }
}