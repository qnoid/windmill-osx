//
//  ArtefactView.swift
//  windmill
//
//  Created by Markos Charatzas on 24/1/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import AppKit

@IBDesignable class StageIndicatorView: NSView {
    
    override func makeBackingLayer() -> CALayer {
        let backingLayer = CALayer()
        backingLayer.masksToBounds = true
        backingLayer.cornerRadius = 2.0
        
        return backingLayer
    }
}

@IBDesignable
class ArtefactView: NSView {
    
    @IBOutlet weak var headerLabel: NSTextField!
    @IBOutlet weak var stageIndicator: NSView! {
        didSet{
            stageIndicator.wantsLayer = true
            stageIndicator.alphaValue = 0.25
        }
    }

    @IBOutlet weak var imageView: NSImageView! {
        didSet{
            imageView.layer = CALayer()
            imageView.wantsLayer = true
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
            self.stageIndicator.layer?.backgroundColor = color?.cgColor
        }
    }

    @IBInspectable var url: String?
    
    @IBInspectable var step: String? {
        didSet{
            
            guard let step = step else {
                return
            }
            
            var attributes: [NSAttributedStringKey : Any] = [.foregroundColor: NSColor.white, .font : stepsLabel.font as Any]
            if let url = url {
                attributes[.link] = url
            }
            
            let attributedString = NSAttributedString(string: step, attributes: attributes)            
            self.stepsLabel.attributedString = attributedString
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.toolTip = NSLocalizedString("artefact.toolTip", comment: "")
        wml_addSubview(view: wml_load(view: ArtefactView.self)!, layout: .centered)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.toolTip = NSLocalizedString("artefact.toolTip", comment: "")
        wml_addSubview(view: wml_load(view: ArtefactView.self)!, layout: .centered)
    }
    
    func startStageAnimation() {
        self.stageIndicator.startAnimation(animation:CAAnimation.Windmill.opacityAnimation(), key: "opacityAnimation")
    }
    
    func stopStageAnimation() {
        self.stageIndicator.stopAnimation(key: "opacityAnimation")
    }
}

