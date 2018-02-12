//
//  DeployView.swift
//  windmill
//
//  Created by Markos Charatzas on 24/1/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation

import AppKit
import os

@IBDesignable
class DeployView: NSView {
    
    @IBOutlet weak var stageIndicatorView: StageIndicatorView! {
        didSet  {
            self.stageIndicatorView.wantsLayer = true
            self.stageIndicatorView.layer?.backgroundColor = NSColor.Windmill.purple().cgColor
        }
    }
    
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var versionTextField: NSTextField!
    @IBOutlet weak var deploymentTargetTextField: NSTextField!

    @IBOutlet weak var infoImageView: NSImageView! {
        didSet{
            infoImageView.image?.backgroundColor = NSColor.white
        }
    }
    
    var buildSettings: BuildSettings? {
        didSet {
            self.deploymentTargetTextField.stringValue = buildSettings?.deployment.target?.description ?? ""
        }
    }
    
    var export: Export? {
        didSet {
            guard let export = export else {
                return
            }
            
            self.versionTextField.stringValue = export.manifest.bundleVersion
            self.titleTextField.stringValue = export.manifest.title
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wml_addSubview(view: wml_load(view: DeployView.self)!, layout: .centered)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wml_addSubview(view: wml_load(view: DeployView.self)!, layout: .centered)
    }    
}

