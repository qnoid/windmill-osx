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
        
        self.wantsLayer = true
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.wantsLayer = true
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
    }
    
    override var intrinsicContentSize: NSSize {
        return NSSize(width: 786, height: 622)
    }
}

class MainViewController: NSViewController {
    
    @IBOutlet weak var mainView: MainView!
    @IBOutlet weak var branchTextField: NSTextField! {
        didSet{
            branchTextField.toolTip = String(format: NSLocalizedString("windmill.branch.toolTip", comment: ""), branchTextField.stringValue)
        }
    }
    @IBOutlet weak var checkoutActivityView: ActivityView!
    @IBOutlet weak var buildActivityView: ActivityView!
    @IBOutlet weak var testActivityView: ActivityView!
    @IBOutlet weak var archiveActivityView: ActivityView!
    @IBOutlet weak var exportActivityView: ActivityView!
    @IBOutlet weak var deployActivityView: ActivityView! {
        didSet {
            deployActivityView.isHidden = (try? Keychain.defaultKeychain().findWindmillUser()) == nil
        }
    }
    
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
            self.defaultCenter.addObserver(self, selector: #selector(willStartProject(_:)), name: Windmill.Notifications.willStartProject, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(activityDidLaunch(_:)), name: Windmill.Notifications.activityDidLaunch, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(activityError(_:)), name: Windmill.Notifications.didError, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(activityDidExitSuccesfully(_:)), name: Windmill.Notifications.activityDidExitSuccesfully, object: windmill)
            self.artefactsViewController?.windmill = windmill
        }
    }
    
    static func make() -> MainViewController {
        let mainStoryboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: Bundle(for: MainViewController.self))
        
        return mainStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: String(describing: MainViewController.self))) as! MainViewController
    }
    
    override func updateViewConstraints() {

        if(self.topConstraint == nil) {
            if let topAnchor = (self.checkoutActivityView.window?.contentLayoutGuide as AnyObject).topAnchor {
                topConstraint = self.checkoutActivityView.topAnchor.constraint(equalTo: topAnchor, constant: 20)
                topConstraint.isActive = true
            }
        }


        super.updateViewConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func willStartProject(_ aNotification: Notification) {
        for activityView in self.activityViews.values {
            activityView.imageView.alphaValue = 0.1
            activityView.stopLightsAnimation()
        }        
    }
    
    @objc func activityDidLaunch(_ aNotification: Notification) {
        guard let activity = aNotification.userInfo?["activity"] as? ActivityType else {
            return
        }
                
        self.activityViews[activity]?.imageView.alphaValue = 1.0
        self.activityViews[activity]?.startLightsAnimation(activityType: activity)
    }

    @objc func activityError(_ aNotification: Notification) {

        if let activity = aNotification.userInfo?["activity"] as? ActivityType {
            self.activityViews[activity]?.imageView.alphaValue = 0.1
            self.activityViews[activity]?.stopLightsAnimation()
        } else {
            os_log("Warning: `activity` wasn't set in the notification.", log:.default, type: .debug)
        }
    }

    @objc func activityDidExitSuccesfully(_ aNotification: Notification) {
        guard let activity = aNotification.userInfo?["activity"] as? ActivityType else {
            return
        }
        
        self.activityViews[activity]?.stopLightsAnimation()
    }
    
    @discardableResult func cleanDerivedData() -> Bool {
        return windmill?.removeDerivedData() ?? false
    }
    
    @discardableResult func cleanProjectFolder() -> Bool {
        return windmill?.projectSourceDirectory.remove() ?? false
    }
}
