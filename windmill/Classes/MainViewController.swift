//
//  ProjectDetailViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 20/03/2016.
//  Copyright © 2016 qnoid.com. All rights reserved.
//

import AppKit
import os

extension CALayer {
    
    struct Windmill {
        
        static func positionAnchorPoint(_ layer: CALayer, anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)) {
            let frame = layer.frame
            layer.anchorPoint = anchorPoint
            layer.frame = frame
        }
    }
}

extension NSView {
    
    func startAnimation() {
        self.layer?.add(CAAnimation.Windmill.spinAnimation, forKey: "spinAnimation")
    }
    
    func stopAnimation() {
        self.layer?.removeAnimation(forKey: "spinAnimation")
    }
}

@IBDesignable
class MainView: NSView {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
        self.layer?.backgroundColor = NSColor.black.cgColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
        self.layer?.backgroundColor = NSColor.black.cgColor
    }
}

class MainViewController: NSViewController, WindmillDelegate {
    
    @IBOutlet var windmillImageView: NSImageView! {
        didSet{
            windmillImageView.wantsLayer = true
            windmillImageView.toolTip = NSLocalizedString("windmill.toolTip", comment: "")
        }
    }
    
    @IBOutlet weak var activityTextfield: NSTextField! {
        didSet {
            activityTextfield.stringValue = NSLocalizedString("windmill.ui.activityTextfield.idle", comment: "")
        }
    }
    @IBOutlet weak var checkoutActivityView: ActivityView!
    @IBOutlet weak var buildActivityView: ActivityView!
    @IBOutlet weak var testActivityView: ActivityView!
    @IBOutlet weak var archiveActivityView: ActivityView!
    @IBOutlet var textView: NSTextView! {
        didSet {
            textView.wantsLayer = true
            textView.isAutomaticSpellingCorrectionEnabled = false
            textView.isAutomaticQuoteSubstitutionEnabled = false
            textView.isAutomaticDashSubstitutionEnabled = false
            textView.isAutomaticTextReplacementEnabled = false
            textView.usesFontPanel = false
            textView.usesFindPanel = false
            textView.usesRuler = false
        }
    }
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    weak var topConstraint: NSLayoutConstraint!
    
    lazy var activityViews: [ActivityType: ActivityView] = { [unowned self] in
        return [.checkout: self.checkoutActivityView, .build: self.buildActivityView, .test: self.testActivityView, .archive: self.archiveActivityView]
    }()
    
    let defaultCenter = NotificationCenter.default
    var windmill: Windmill!
    var scheduler: Scheduler!
    
    var location: Int = 0
    var buffer: String = ""
    
    static func make() -> MainViewController {
        let mainStoryboard = NSStoryboard(name: "Main", bundle: Bundle(for: MainViewController.self))
        
        return mainStoryboard.instantiateController(withIdentifier: String(describing: MainViewController.self)) as! MainViewController
    }
    
    override func updateViewConstraints() {
        
        if(self.topConstraint == nil) {
        
            let topAnchor = (self.view.window?.contentLayoutGuide as AnyObject?)?.topAnchor
        
            let topConstraint = self.checkoutActivityView.topAnchor.constraint(equalTo: topAnchor!, constant: 11)
        
            topConstraint.isActive = true
        
            self.topConstraint = topConstraint
        }
        
        super.updateViewConstraints()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        CALayer.Windmill.positionAnchorPoint(self.windmillImageView.layer!)
    }
    
    override func loadView() {
        super.loadView()
        
        self.view.window?.addTitlebarAccessoryViewController(ProjectTitlebarAccessoryViewController())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.defaultCenter.addObserver(self, selector: #selector(MainViewController.windmillWillDeployProject(_:)), name: Windmill.Notifications.willDeployProject, object: nil)
        self.defaultCenter.addObserver(self, selector: #selector(MainViewController.activityDidLaunch(_:)), name: Process.Notifications.activityDidLaunch, object: nil)
        self.defaultCenter.addObserver(self, selector: #selector(MainViewController.activityError(_:)), name: Process.Notifications.activityError, object: nil)
        self.defaultCenter.addObserver(self, selector: #selector(MainViewController.activityDidExitSuccesfully(_:)), name: Process.Notifications.activityDidExitSuccesfully, object: nil)
    }
    
    func append(_ textView: NSTextView, output: String, count: Int) {
        
        self.buffer.append("\n \(output)")
        self.location = self.location + count
        
        textView.string = self.buffer
        let range = NSRange(location:location,length:0)
        textView.scrollRangeToVisible(range)
    }
    
    func windmill(_ windmill: Windmill, standardOutput: String, count: Int) {
        self.append(self.textView, output: standardOutput, count: count)
    }
    
    func windmill(_ windmill: Windmill, standardError: String, count: Int) {
        self.append(self.textView, output: standardError, count: count)
    }

    
    func windmillWillDeployProject(_ aNotification: Notification) {
        let project = aNotification.object as! Project
        self.buffer = ""
        self.location = 0
        self.textView.string = ""
        textView.isSelectable = false
        
        self.windmillImageView.startAnimation()
        self.windmillImageView.toolTip = NSLocalizedString("windmill.toolTip.active", comment: "")
        self.view.window?.title = project.name        
        self.windmillImageView.image = NSImage(named: "windmill-activity-indicator-inactive")
        for activityView in self.activityViews.values {
            activityView.isHidden = true
            activityView.alphaValue = 0.5
        }
        
        let projectTitlebarAccessoryViewController = self.view.window?.titlebarAccessoryViewControllers[0] as! ProjectTitlebarAccessoryViewController
        projectTitlebarAccessoryViewController.project = project        
    }
    
    func activityDidLaunch(_ aNotification: Notification) {
        let activityType = ActivityType(rawValue: aNotification.userInfo!["activity"] as! String)!
        let log = OSLog(subsystem: "io.windmill.windmill", category: activityType.rawValue)
        os_log("%{public}@", log: log, type: .debug, activityType.description)
        
        switch(activityType){
            case .checkout, .build, .test, .archive:
                self.activityViews[activityType]?.isHidden = false
        default:
            break
        }
        
        self.activityTextfield.stringValue = activityType.description
    }

    func activityError(_ aNotification: Notification) {
        let activityType = ActivityType(rawValue: aNotification.userInfo!["activity"] as! String)!
        let log = OSLog(subsystem: "io.windmill.windmill", category: activityType.rawValue)
        os_log("%{public}@", log: log, type: .error, activityType.description)
        
        self.windmillImageView.toolTip = NSLocalizedString("windmill.toolTip.error", comment: "")
        self.windmillImageView.stopAnimation()
        
        self.activityTextfield.stringValue = NSLocalizedString("windmill.ui.activityTextfield.stopped", comment: "")
        self.textViewHeightConstraint.animator().constant = 105
        self.textView.isSelectable = true
    }

    func activityDidExitSuccesfully(_ aNotification: Notification) {
        
        let activityType = ActivityType(rawValue: aNotification.userInfo!["activity"] as! String)!
        let log = OSLog(subsystem: "io.windmill.windmill", category: activityType.rawValue)
        os_log("%{public}@", log: log, type: .debug, activityType.description)

        switch(activityType){
        case .checkout, .build, .test, .archive:
            self.windmillImageView.image = NSImage(named: activityType.imageName)
            self.activityViews[activityType]?.alphaValue = 1.0
        default:
            break
        }
    }
    
    @IBAction func run(_ sender: Any) {
        self.windmill.projects = InputStream.inputStreamOnProjects().read()
        self.windmill.start()
    }
    
    @IBAction func showDebugArea(_ menuItem: NSMenuItem) {
        let isClosed = self.textViewHeightConstraint.constant == 0.0

        menuItem.title = isClosed ? NSLocalizedString("windmill.ui.toolbar.view.hideDebugArea", comment: "") : NSLocalizedString("windmill.ui.toolbar.view.showDebugArea", comment: "")
        self.textViewHeightConstraint.animator().constant = isClosed ? 105.0 : 0.0
        textView.isSelectable = isClosed
    }
}
