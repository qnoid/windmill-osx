//
//  ProjectDetailViewController.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 20/03/2016.
//  Copyright © 2014-2020 qnoid.com. All rights reserved.
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation is required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.
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
class MainView: NSView {
    
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
    @IBOutlet weak var checkoutActivityView: ActivityView! {
        didSet{
            checkoutActivityView.isHidden = true
        }
    }
    @IBOutlet weak var buildActivityView: ActivityView! {
        didSet{
            buildActivityView.isHidden = true
        }
    }
    @IBOutlet weak var testActivityView: ActivityView! {
        didSet{
            testActivityView.isHidden = true
        }
    }
    @IBOutlet weak var archiveActivityView: ActivityView! {
        didSet{
            archiveActivityView.isHidden = true
        }
    }
    @IBOutlet weak var exportActivityView: ActivityView! {
        didSet{
            exportActivityView.isHidden = true
        }
    }
    @IBOutlet weak var distributeActivityView: ActivityView! {
        didSet{
            distributeActivityView.isHidden = true
        }
    }
    @IBOutlet weak var divider: NSImageView!
    
    weak var topConstraint: NSLayoutConstraint!
    
    lazy var activityViews: [ActivityType: ActivityView] = { [unowned self] in
        return [.checkout: self.checkoutActivityView, .build: self.buildActivityView, .test: self.testActivityView, .archive: self.archiveActivityView, .export: self.exportActivityView, .distribute: self.distributeActivityView]
    }()
    
    var artefactsViewController: ArtefactsViewController? {
        return self.children[0] as? ArtefactsViewController
    }
    
    var subscriptionStatus = SubscriptionStatus.default
    let defaultCenter = NotificationCenter.default
    
    weak var windmill: Windmill? {
        didSet{
            self.defaultCenter.addObserver(self, selector: #selector(willRun(_:)), name: Windmill.Notifications.willRun, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(activityDidLaunch(_:)), name: Windmill.Notifications.activityDidLaunch, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(activityError(_:)), name: Windmill.Notifications.didError, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(activityDidExitSuccesfully(_:)), name: Windmill.Notifications.activityDidExitSuccesfully, object: windmill)
            self.artefactsViewController?.windmill = windmill
            
            windmill?.configuration.activities.forEach { activity in
                let activityView = self.activityViews[activity]
                activityView?.isHidden = false
            }
            
            self.mainView.needsUpdateConstraints = true
        }
    }
    
    static func make() -> MainViewController {
        let mainStoryboard = NSStoryboard(name: "Main", bundle: Bundle(for: MainViewController.self))
        
        return mainStoryboard.instantiateController(withIdentifier: String(describing: MainViewController.self)) as! MainViewController
    }
    
    override func updateViewConstraints() {

        if(self.topConstraint == nil) {
            if let topAnchor = (self.checkoutActivityView.window?.contentLayoutGuide as AnyObject).topAnchor {
                topConstraint = self.checkoutActivityView.topAnchor.constraint(equalTo: topAnchor, constant: 20)
                topConstraint.isActive = true
            }
        }
        
        if let activities = windmill?.configuration.activities {
            
            if let activityView = self.activityViews.reversed().first(where: { type, value -> Bool in
                return type == activities.last
            }) {
                self.divider.trailingAnchor.constraint(equalTo: activityView.value.trailingAnchor, constant: 0).isActive = true
            }
        }

        super.updateViewConstraints()
    }
    
    @objc func willRun(_ aNotification: Notification) {
        self.branchTextField.stringValue = self.windmill?.configuration.branch ?? ""

        for activityView in self.activityViews.values {
            activityView.toolTip = nil
            activityView.imageView.alphaValue = 0.1
            activityView.stopLightsAnimation()
            activityView.removeTrackingArea()
        }        
    }
    
    @objc func activityDidLaunch(_ aNotification: Notification) {
        guard let activity = aNotification.userInfo?["activity"] as? ActivityType else {
            os_log("Warning: `activity` wasn't set in the notification.", log:.default, type: .debug)
            return
        }
        let activityView = self.activityViews[activity]
        activityView?.toolTip = NSLocalizedString("windmill.toolTip.active.\(activity.rawValue)", comment: "")
        activityView?.imageView.alphaValue = 1.0
        activityView?.startLightsAnimation(activityType: activity)
    }

    @objc func activityError(_ aNotification: Notification) {

        let error = aNotification.userInfo?["error"] as? NSError
        let activity = aNotification.userInfo?["activity"] as? ActivityType
        
        switch (error, activity) {
        case (let error?, let activity?):
            if case .distribute = activity {
                self.distributeActivityView.addTrackingArea(action: "distribute:")
            }
            
            let activityView = self.activityViews[activity]
            activityView?.toolTip = error.localizedDescription
            activityView?.imageView.alphaValue = 0.1
            activityView?.stopLightsAnimation()
        default:
            os_log("Warning: neither `error` nor `activity` were set for the `didError` notification.", log:.default, type: .debug)
        }
    }

    @objc func activityDidExitSuccesfully(_ aNotification: Notification) {
        let activity = aNotification.userInfo?["activity"] as? ActivityType
        
        switch activity {
        case (let activity?):
            if case .distribute = activity {
                self.distributeActivityView.removeTrackingArea()
            }
            
            let activityView = self.activityViews[activity]
            activityView?.toolTip = NSLocalizedString("windmill.toolTip.success.\(activity.rawValue)", comment: "")
            activityView?.stopLightsAnimation()
        default:
            os_log("Warning: `activity` wasn't set in the notification.", log:.default, type: .debug)
        }
    }    
}
