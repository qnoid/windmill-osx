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

    lazy var loadView: () -> Void = { [unowned self] in
        var topLevelObjects: NSArray?
        Bundle(for: type(of: self)).loadNibNamed("ActivityView", owner: self, topLevelObjects: &topLevelObjects)
        
        for object in topLevelObjects! {
            if let containerView = object as? NSView {
                self.addSubview(containerView)
            }
        }
    }
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    
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
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.loadView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadView()
    }
}
