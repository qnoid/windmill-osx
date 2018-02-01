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
    
    func startAnimation(animation: CAAnimation = CAAnimation.Windmill.spinAnimation, key: String = "spinAnimation") {
        if let _ = self.layer?.animation(forKey: key) {
            self.layer?.removeAnimation(forKey: key)
        }
        
        self.layer?.add(animation, forKey: key)
    }
    
    func stopAnimation(key: String = "spinAnimation") {
        self.layer?.removeAnimation(forKey: key)
    }
}

@IBDesignable
class MainView: NSView, CALayerDelegate {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.layer = CALayer()
        self.wantsLayer = true
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.layer = CALayer()
        self.wantsLayer = true
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
    }
    
    override var intrinsicContentSize: NSSize {
        return NSSize(width: 850, height: 622)
    }
    
    func display(_ layer: CALayer) {
        CALayer.Windmill.positionAnchorPoint(layer)
        
    }
}

class MainViewController: NSViewController {
    
    @IBOutlet weak var mainView: MainView!
    @IBOutlet var windmillImageView: NSImageView! {
        didSet{
            windmillImageView.layer = CALayer()
            windmillImageView.wantsLayer = true
            windmillImageView.layerContentsRedrawPolicy = .onSetNeedsDisplay
            windmillImageView.toolTip = NSLocalizedString("windmill.toolTip", comment: "")
            windmillImageView.layer?.delegate = self.mainView
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
    @IBOutlet weak var exportActivityView: ActivityView!
    @IBOutlet weak var deployActivityView: ActivityView!
    
    weak var topConstraint: NSLayoutConstraint!
    
    lazy var activityViews: [ActivityType: ActivityView] = { [unowned self] in
        return [.checkout: self.checkoutActivityView, .build: self.buildActivityView, .test: self.testActivityView, .archive: self.archiveActivityView, .export: self.exportActivityView, .deploy: self.deployActivityView]
    }()
    
    var artefactsViewController: ArtefactsViewController? {
        return self.childViewControllers[0] as? ArtefactsViewController
    }
    
    let defaultCenter = NotificationCenter.default
    
    weak var windmill: Windmill? {
        didSet{
            self.defaultCenter.addObserver(self, selector: #selector(windmillWillDeployProject(_:)), name: Windmill.Notifications.willDeployProject, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(activityDidLaunch(_:)), name: Windmill.Notifications.activityDidLaunch, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(activityError(_:)), name: Windmill.Notifications.activityError, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(activityDidExitSuccesfully(_:)), name: Windmill.Notifications.activityDidExitSuccesfully, object: windmill)
            self.artefactsViewController?.windmill = windmill
        }
    }
    var project: Project?
    
    
    static func make() -> MainViewController {
        let mainStoryboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: Bundle(for: MainViewController.self))
        
        return mainStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: String(describing: MainViewController.self))) as! MainViewController
    }
    
    override func updateViewConstraints() {
        
        if(self.topConstraint == nil) {        
            if let topAnchor = (self.windmillImageView.window?.contentLayoutGuide as AnyObject).topAnchor {
                topConstraint = self.windmillImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20)
                topConstraint.isActive = true
            }
        }
        
        
        super.updateViewConstraints()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        self.windmillImageView.layer?.setNeedsDisplay()        
    }
    
    override func loadView() {
        super.loadView()
        
        self.view.window?.addTitlebarAccessoryViewController(ProjectTitlebarAccessoryViewController())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func windmillWillDeployProject(_ aNotification: Notification) {
        guard let project = aNotification.userInfo?["project"] as? Project else {
            return
        }
        
        self.project = project
        
        self.windmillImageView.startAnimation()
        self.windmillImageView.toolTip = NSLocalizedString("windmill.toolTip.active", comment: "")
        for activityView in self.activityViews.values {
            activityView.imageView.alphaValue = 0.1
            activityView.stopLightsAnimation()
        }
        let projectTitlebarAccessoryViewController = self.view.window?.titlebarAccessoryViewControllers[0] as! ProjectTitlebarAccessoryViewController
        projectTitlebarAccessoryViewController.project = project        
    }
    
    @objc func activityDidLaunch(_ aNotification: Notification) {
        guard let activity = aNotification.userInfo?["activity"] as? String, let activityType = ActivityType(rawValue: activity) else {
            return
        }
                
        self.windmillImageView.image = NSImage(named: NSImage.Name(rawValue: activityType.imageName))
        self.windmillImageView.toolTip = NSLocalizedString("windmill.toolTip.active.\(activityType.rawValue)", comment: "")
        self.activityViews[activityType]?.imageView.alphaValue = 1.0
        self.activityViews[activityType]?.startLightsAnimation(activityType: activityType)
        
        self.activityTextfield.stringValue = activityType.description
    }

    @objc func activityError(_ aNotification: Notification) {

        self.windmillImageView.stopAnimation()
        self.activityTextfield.stringValue = NSLocalizedString("windmill.ui.activityTextfield.stopped", comment: "")
        
        if let error = aNotification.userInfo?["error"] as? NSError {
            self.windmillImageView.toolTip = error.localizedDescription
        }

        if let activity = aNotification.userInfo?["activity"] as? ActivityType {
            self.windmillImageView.image = NSImage(named: NSImage.Name(rawValue: activity.imageName))
            self.activityViews[activity]?.imageView.alphaValue = 0.1
            self.activityViews[activity]?.stopLightsAnimation()
        } else {
            os_log("Warning: `activity` wasn't set in the notification.", log:.default, type: .debug)
        }
    }

    @objc func activityDidExitSuccesfully(_ aNotification: Notification) {
        guard let activity = aNotification.userInfo?["activity"] as? String, let activityType = ActivityType(rawValue: activity) else {
            return
        }

        self.activityViews[activityType]?.stopLightsAnimation()
    }
    
    @discardableResult func cleanBuildFolder() -> Bool {
        
        guard let project = self.project else {
            return false
        }
        
        do {
            let url = FileManager.default.buildDirectoryURL(forProject: project.name).appendingPathComponent("/Build")
            try FileManager.default.removeItem(at: url)
            return true
        } catch let error as NSError {
            os_log("%{public}@", log:.default, type: .error, error)
            return false
        }
    }
    
    @discardableResult func cleanProjectFolder() -> Bool {

        guard let project = self.project else {
            return false
        }

        do {
            try FileManager.default.removeItem(at: project.directoryPathURL)
            return true
        } catch let error as CocoaError {
            guard let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? POSIXError, underlyingError.code == POSIXError.ENOTEMPTY else {
                return false
            }
            
            try? FileManager.default.removeItem(at: project.directoryPathURL)
            return true
        } catch let error as NSError {
            os_log("%{public}@", log:.default, type: .error, error)
            return false
        }
    }    
}
