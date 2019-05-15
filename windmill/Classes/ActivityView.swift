//
//  ActivityView.swift
//  windmill
//
//  Created by Markos Charatzas on 01/05/2016.
//  Copyright © 2016 qnoid.com. All rights reserved.
//

import AppKit

@IBDesignable
class ActivityView: NSView {

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var imageView: NSImageView! {
        didSet{
            imageView.alphaValue = 0.1
        }
    }
    
    @IBInspectable var title: String? {
        didSet{
            self.titleLabel.stringValue = title!
        }
    }

    @IBInspectable var image: NSImage? {
        didSet{
            self.imageView.image = image!
        }
    }

    override var intrinsicContentSize: NSSize {
        return NSSize(width: 120, height: 80)
    }

    override var acceptsFirstResponder: Bool {
        return trackingArea != nil
    }
    
    weak var trackingArea: NSTrackingArea?
    var action: String?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wml_addSubview(view: wml_load(view: ActivityView.self)!, layout: .centered)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wml_addSubview(view: wml_load(view: ActivityView.self)!, layout: .centered)
    }
    
    func animations(activityType: ActivityType) -> [NSImage] {
        let type = String(describing: activityType.rawValue)
        
        return [NSImage(named: "lights-\(type)-animation-key-1")!, NSImage(named: "lights-\(type)-animation-key-2")!, NSImage(named: "lights-\(type)-animation-key-3")!]
    }

    func startLightsAnimation(activityType: ActivityType) {
        if let _ = self.imageView.layer?.sublayers?[0].animation(forKey: "lights") {
            self.stopAnimation()
        }
        
        let animations = self.animations(activityType: activityType)
        
        self.imageView.layer?.sublayers?[0].add(CAAnimation.Windmill.lightsAnimation(size: self.imageView.bounds.size, animations: animations), forKey: "lights")
    }
    
    func stopLightsAnimation() {
        self.imageView.layer?.sublayers?[0].removeAnimation(forKey: "lights")
    }
    
    func addTrackingArea(action: String) {
        let trackingArea = NSTrackingArea(rect: self.imageView.bounds, options: [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow, .cursorUpdate], owner: self, userInfo: nil)
        self.trackingArea = trackingArea
        self.addTrackingArea(trackingArea)
        self.action = action
    }
    
    func removeTrackingArea() {
        if let trackingArea = trackingArea {
            self.removeTrackingArea(trackingArea)
        }
    }

    override func cursorUpdate(with event: NSEvent) {
        guard trackingArea != nil else {
            super.cursorUpdate(with: event)
            return
        }
        
        NSCursor.pointingHand.set()
    }
    
    override func mouseEntered(with event: NSEvent) {
        guard trackingArea != nil else {
            return
        }

        self.imageView.alphaValue = 1.0
    }
    
    override func mouseMoved(with event: NSEvent) {
        guard trackingArea != nil else {
            return
        }

    }
    
    override func mouseExited(with event: NSEvent) {
        guard trackingArea != nil else {
            return
        }

        self.imageView.alphaValue = 0.1
    }
    
    override func mouseDown(with event: NSEvent) {        
        guard trackingArea != nil else {
            return
        }

        if let action = action {
            NSApplication.shared.sendAction(Selector((action)), to: nil, from: self)
        }
    }
}
