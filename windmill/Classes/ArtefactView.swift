//
//  ArtefactView.swift
//  windmill
//
//  Created by Markos Charatzas on 24/1/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import AppKit

@IBDesignable class StageIndicatorView: NSView {
    
    var color: NSColor? {
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
        self.layer?.masksToBounds = true
        self.layer?.cornerRadius = 2.0
        self.layer?.backgroundColor = self.color?.cgColor
    }
}

@IBDesignable
class ArtefactView: NSView {
    
    @IBOutlet weak var headerTextField: LinkLabel! {
        didSet{
            let attributedString = NSAttributedString(string: headerTextField.string, attributes: [
                .foregroundColor: NSColor.textColor,
                .font : headerTextField.font as Any])
            headerTextField.attributedString = attributedString
        }
    }
    
    @IBOutlet weak var leadingLabel: NSTextField!
    @IBOutlet weak var stageIndicator: StageIndicatorView! {
        didSet{
            stageIndicator.alphaValue = 0.25
        }
    }

    @IBOutlet weak var imageView: NSImageView! {
        didSet{
            imageView.alphaValue = 0.25
        }
    }
    @IBOutlet weak var stepsLabel: LinkLabel!
    
    @IBInspectable var image: NSImage? {
        didSet{
            self.imageView.image = image
        }
    }
    
    @IBInspectable var color: NSColor? {
        didSet{
            self.stageIndicator.color = color
        }
    }

    @IBInspectable var url: String?
    
    @IBInspectable var step: String? {
        didSet{
            
            guard let step = step else {
                return
            }
            
            var attributes: [NSAttributedString.Key : Any] = [.foregroundColor: NSColor.textColor, .font : stepsLabel.font as Any]
            if let url = url {
                attributes[.link] = url
                self.stepsLabel.isSelectable = true
            }
            
            let attributedString = NSAttributedString(string: step, attributes: attributes)
            self.stepsLabel.attributedString = attributedString
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wml_addSubview(view: wml_load(view: ArtefactView.self)!, layout: .centered)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wml_addSubview(view: wml_load(view: ArtefactView.self)!, layout: .centered)
    }
    
    func startStageAnimation() {
        self.stageIndicator.startAnimation(animation:CAAnimation.Windmill.opacityAnimation(), key: "opacityAnimation")
    }
    
    func stopStageAnimation() {
        self.stageIndicator.stopAnimation(key: "opacityAnimation")
    }
}

