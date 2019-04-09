//
//  DistributeView.swift
//  windmill
//
//  Created by Markos Charatzas on 24/1/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation

import AppKit
import os

@IBDesignable
class DistributeView: NSView {
    
    @IBOutlet weak var stageIndicatorView: StageIndicatorView! {
        didSet  {
            self.stageIndicatorView.color = NSColor(named:"distribute")
        }
    }
    
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var versionTextField: NSTextField!
    @IBOutlet weak var deploymentTargetTextField: NSTextField!

    @IBOutlet weak var infoImageView: NSImageView! {
        didSet{
            infoImageView.image?.backgroundColor = NSColor.controlBackgroundColor
        }
    }
    
    var appBundle: AppBundle? {
        didSet {
            self.deploymentTargetTextField.stringValue = appBundle?.info.minimumOSVersion ?? ""
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
        wml_addSubview(view: wml_load(view: DistributeView.self)!, layout: .centered)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wml_addSubview(view: wml_load(view: DistributeView.self)!, layout: .centered)
    }    
}

