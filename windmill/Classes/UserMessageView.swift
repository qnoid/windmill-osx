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

class UserMessageViewBox: NSBox {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        NotificationCenter.default.addObserver(self, selector: #selector(accessibilityDisplayShouldIncreaseContrast(_:)), name: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification, object: NSWorkspace.shared)
        self.updateFillColor()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        NotificationCenter.default.addObserver(self, selector: #selector(accessibilityDisplayShouldIncreaseContrast(_:)), name: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification, object: NSWorkspace.shared)
        self.updateFillColor()
    }
    
    func updateFillColor(workspace: NSWorkspace = NSWorkspace.shared) {
        self.fillColor = workspace.accessibilityDisplayShouldIncreaseContrast ? NSColor.windowFrameColor : NSColor.windowBackgroundColor

    }
    
    @objc func accessibilityDisplayShouldIncreaseContrast(_ aNotification: NSNotification) {
        guard let workspace = aNotification.object as? NSWorkspace else {
            return
        }

        self.updateFillColor(workspace: workspace)
    }
}

class UserMessageView: NSToolbarItem, CALayerDelegate {

    
    @IBOutlet weak var box: UserMessageViewBox!
    
    @IBOutlet weak var windmillImageView: NSImageView! {
        didSet{
            let layer = CALayer()
            layer.contentsScale = 2.0
            layer.contentsGravity = "aspectFit"
            layer.contents = #imageLiteral(resourceName: "windmill-activity-indicator")
            windmillImageView.layer = layer
            windmillImageView.wantsLayer = true
            windmillImageView.layerContentsRedrawPolicy = .onSetNeedsDisplay
            windmillImageView.toolTip = NSLocalizedString("windmill.toolTip", comment: "")
            windmillImageView.layer?.delegate = self
            windmillImageView.needsDisplay = true
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
            errorButton.attributedTitle = NSAttributedString(string: errorButton.stringValue, attributes: [ NSAttributedStringKey.backgroundColor: NSColor.windowBackgroundColor, NSAttributedStringKey.foregroundColor : NSColor.white])
            errorButton.isHidden = true
        }
    }
    
    override init(itemIdentifier: NSToolbarItem.Identifier) {
        super.init(itemIdentifier: itemIdentifier)
        
        self.view = wml_load(name: NSNib.Name(rawValue: String(describing: UserMessageView.self)))!
    }
    
    func display(_ layer: CALayer) {
        CALayer.Windmill.positionAnchorPoint(layer)
    }
    
    func didSet(notificationCenter: NotificationCenter = NotificationCenter.default, windmill: Windmill) {
        notificationCenter.addObserver(self, selector: #selector(willStartProject(_:)), name: Windmill.Notifications.willStartProject, object: windmill)
        notificationCenter.addObserver(self, selector: #selector(windmillMonitoringProject(_:)), name: Windmill.Notifications.willMonitorProject, object: windmill)
        notificationCenter.addObserver(self, selector: #selector(activityDidLaunch(_:)), name: Windmill.Notifications.activityDidLaunch, object: windmill)
        notificationCenter.addObserver(self, selector: #selector(activityError(_:)), name: Windmill.Notifications.activityError, object: windmill)
    }
    
    @objc func willStartProject(_ aNotification: Notification) {
        self.windmillImageView.startAnimation()
        self.toolTip = NSLocalizedString("windmill.toolTip.active", comment: "")
        
        self.prettyLogTextField.stringValue = ""
        self.errorButton.title = String(0)
        self.errorButton.isHidden = true
    }

    @objc func windmillMonitoringProject(_ aNotification: Notification) {
        self.windmillImageView.layer?.contents = #imageLiteral(resourceName: "windmill-activity-indicator")
        self.toolTip = NSLocalizedString("windmill.toolTip.active.monitor", comment: "")
        self.activityTextfield.stringValue = NSLocalizedString("windmill.activity.monitor.description", comment: "")
    }
    
    @objc func activityDidLaunch(_ aNotification: Notification) {
        guard let activity = aNotification.userInfo?["activity"] as? ActivityType else {
            return
        }
        
        self.windmillImageView.layer?.contents = NSImage(named: NSImage.Name(rawValue: activity.imageName))
        self.toolTip = NSLocalizedString("windmill.toolTip.active.\(activity.rawValue)", comment: "")
        self.activityTextfield.stringValue = activity.description
    }
    
    @objc func activityError(_ aNotification: Notification) {
        
        self.windmillImageView.stopAnimation()
        self.activityTextfield.stringValue = NSLocalizedString("windmill.ui.activityTextfield.stopped", comment: "")

        if let errorCount = aNotification.userInfo?["errorCount"] as? Int, errorCount != 0 {
            self.errorButton.title = String(errorCount)
            self.errorButton.isHidden = false
        }

        if let error = aNotification.userInfo?["error"] as? NSError {
            self.toolTip = error.localizedFailureReason
            self.prettyLogTextField.stringValue = error.localizedDescription
        }
        
        if let activity = aNotification.userInfo?["activity"] as? ActivityType {
            self.windmillImageView.layer?.contents = NSImage(named: NSImage.Name(rawValue: activity.imageName))
        } else {
            os_log("Warning: `activity` wasn't set in the notification.", log:.default, type: .debug)
        }
    }
}
