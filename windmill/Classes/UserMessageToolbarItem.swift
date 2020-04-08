//
//  UserMessageView.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 3/3/18.
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
import CloudKit

class UserMessageViewTextField: NSTextField {
    
    override var alignmentRectInsets: NSEdgeInsets {
        return NSEdgeInsetsMake(-2, 0, 0, 0)
    }
    
}

class WindmillImageView: NSImageView {
    var contents: NSImage? = NSImage(named: "windmill-activity-indicator") {
        didSet {
            self.needsDisplay = true
        }
    }
    
    override var wantsUpdateLayer: Bool {
        return true
    }
    
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
    
    override func updateLayer() {
        guard let layer = self.layer else {
            return
        }
        
        CALayer.Windmill.positionAnchorPoint(layer)
        let scale: CGFloat = window?.backingScaleFactor ?? 2.0
        var rect = layer.bounds
        layer.contents = self.contents?.cgImage(forProposedRect: &rect,
                                                context: nil,
                                                hints: [ NSImageRep.HintKey.ctm : AffineTransform(scale: scale )]) as CGImage?
    }
}

class UserMessageView: NSButton {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        self.setButtonType(NSButton.ButtonType.momentaryPushIn)
        self.bezelStyle = .texturedRounded
        self.title = ""
        self.isEnabled = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setButtonType(NSButton.ButtonType.momentaryPushIn)
        self.bezelStyle = .texturedRounded
        self.title = ""
        self.isEnabled = false
    }
    
    override func mouseDown(with event: NSEvent) {
        
    }
}

class UserMessageToolbarItem: NSToolbarItem, CALayerDelegate {

    
    @IBOutlet weak var windmillImageView: WindmillImageView! {
        didSet{
            windmillImageView.toolTip = NSLocalizedString("windmill.toolTip", comment: "")
        }
    }
    
    @IBOutlet weak var activityTextfield: NSTextField! {
        didSet {
            activityTextfield.stringValue = NSLocalizedString("windmill.ui.activityTextfield.idle", comment: "")
        }
    }
    @IBOutlet weak var targetNameTextField: NSTextField!
    @IBOutlet weak var prettyLogTextField: NSTextField!
    @IBOutlet weak var warningButton: NSButton! {
        didSet{
            warningButton.isHidden = true
        }
    }
    @IBOutlet weak var errorButton: NSButton! {
        didSet{
            errorButton.attributedTitle = NSAttributedString(string: errorButton.stringValue, attributes: [ .foregroundColor : NSColor.textColor])
            errorButton.isHidden = true
        }
    }
    
    override init(itemIdentifier: NSToolbarItem.Identifier) {
        super.init(itemIdentifier: itemIdentifier)
        
        let view = UserMessageView(frame: NSRect.zero)
        view.wml_addSubview(view: wml_load(name: String(describing: UserMessageToolbarItem.self))!, layout: .centered)
        self.view = view
        
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActive(notification:)), name: SubscriptionManager.SubscriptionActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionFailed(notification:)), name: SubscriptionManager.SubscriptionFailed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(noUserAccount(notification:)), name: Windmill.Notifications.NoUserAccount, object: nil)
    }
    
    func didSet(windmill: Windmill?, notificationCenter: NotificationCenter = NotificationCenter.default) {
        notificationCenter.addObserver(self, selector: #selector(willRun(_:)), name: Windmill.Notifications.willRun, object: windmill)
        notificationCenter.addObserver(self, selector: #selector(isMonitoring(_:)), name: Windmill.Notifications.isMonitoring, object: windmill)
        notificationCenter.addObserver(self, selector: #selector(activityDidLaunch(_:)), name: Windmill.Notifications.activityDidLaunch, object: windmill)
        notificationCenter.addObserver(self, selector: #selector(activityError(_:)), name: Windmill.Notifications.didError, object: windmill)
    }
    
    @objc func willRun(_ aNotification: Notification) {
        self.windmillImageView.startAnimation()
        self.toolTip = NSLocalizedString("windmill.toolTip.active", comment: "")
        
        self.prettyLogTextField.stringValue = ""
        self.errorButton.title = String(0)
        self.errorButton.isHidden = true
        self.warningButton.isHidden = true
    }

    @objc func isMonitoring(_ aNotification: Notification) {
        
        
        self.windmillImageView.contents = NSImage(named: "windmill-activity-indicator")
        self.toolTip = NSLocalizedString("windmill.toolTip.active.monitor", comment: "")
        let description = NSLocalizedString("windmill.activity.monitor.description", comment: "")
        if let branch = aNotification.userInfo?["branch"] as? String {
            self.activityTextfield.stringValue = String(format: "\(description) '%@' branch", branch)
        } else {
            self.activityTextfield.stringValue = description
        }
    }
    
    @objc func activityDidLaunch(_ aNotification: Notification) {
        
        let type = aNotification.userInfo?["activity"] as? ActivityType
        
        switch type {
        case .none:
            return
        case .distribute?:
            self.warningButton.isHidden = true
            return
        case let activity?:
            self.windmillImageView.contents = NSImage(named: activity.imageName)
            self.toolTip = NSLocalizedString("windmill.toolTip.active.\(activity.rawValue)", comment: "")
            self.activityTextfield.stringValue = activity.description
        }
    }
    
    @objc func activityError(_ aNotification: Notification) {
        
        let error = aNotification.userInfo?["error"] as? NSError
        let activity = aNotification.userInfo?["activity"] as? ActivityType
        
        switch (error, activity) {
        case (let error as WindmillError, _) where error.isRecoverable:
            return
        case (let error?, let activity?):
            self.toolTip = error.localizedFailureReason ?? error.localizedRecoverySuggestion
            self.prettyLogTextField.stringValue = error.localizedDescription
            self.windmillImageView.contents = NSImage(named: activity.imageName)
        default:
            os_log("Warning: neither `error` nor `activity` were set for the `didError` notification.", log:.default, type: .debug)
        }
        
        self.windmillImageView.stopAnimation()
        self.activityTextfield.stringValue = NSLocalizedString("windmill.ui.message.view.stopped", comment: "")

        if let errorCount = aNotification.userInfo?["errorCount"] as? Int, errorCount != 0 {
            self.errorButton.title = String(errorCount)
            self.errorButton.isHidden = false
        }
    }
    
    @objc func subscriptionActive(notification: NSNotification) {
        self.warningButton.isHidden = true        
    }
    
    @objc func subscriptionFailed(notification: NSNotification) {
        self.warningButton.isHidden = false
    }
    
    @objc func noUserAccount(notification: NSNotification) {
        self.warningButton.isHidden = false
    }
}
