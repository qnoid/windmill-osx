//
//  UserMessageView.swift
//  windmill
//
//  Created by Markos Charatzas on 3/3/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import AppKit
import os

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
    }
    
    func didSet(windmill: Windmill?, notificationCenter: NotificationCenter = NotificationCenter.default) {
        notificationCenter.addObserver(self, selector: #selector(willStartProject(_:)), name: Windmill.Notifications.willStartProject, object: windmill)
        notificationCenter.addObserver(self, selector: #selector(isMonitoring(_:)), name: Windmill.Notifications.isMonitoring, object: windmill)
        notificationCenter.addObserver(self, selector: #selector(activityDidLaunch(_:)), name: Windmill.Notifications.activityDidLaunch, object: windmill)
        notificationCenter.addObserver(self, selector: #selector(activityError(_:)), name: Windmill.Notifications.didError, object: windmill)
    }
    
    @objc func willStartProject(_ aNotification: Notification) {
        self.windmillImageView.startAnimation()
        self.toolTip = NSLocalizedString("windmill.toolTip.active", comment: "")
        
        self.prettyLogTextField.stringValue = ""
        self.errorButton.title = String(0)
        self.errorButton.isHidden = true
    }

    @objc func isMonitoring(_ aNotification: Notification) {
        self.windmillImageView.contents = NSImage(named: "windmill-activity-indicator")
        self.toolTip = NSLocalizedString("windmill.toolTip.active.monitor", comment: "")
        self.activityTextfield.stringValue = NSLocalizedString("windmill.activity.monitor.description", comment: "")
    }
    
    @objc func activityDidLaunch(_ aNotification: Notification) {
        
        guard let activity = aNotification.userInfo?["activity"] as? ActivityType, activity != .distribute else {
            return
        }
        
        self.windmillImageView.contents = NSImage(named: activity.imageName)
        self.toolTip = NSLocalizedString("windmill.toolTip.active.\(activity.rawValue)", comment: "")
        self.activityTextfield.stringValue = activity.description
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
        self.activityTextfield.stringValue = NSLocalizedString("windmill.ui.activityTextfield.stopped", comment: "")

        if let errorCount = aNotification.userInfo?["errorCount"] as? Int, errorCount != 0 {
            self.errorButton.title = String(errorCount)
            self.errorButton.isHidden = false
        }
    }
}
