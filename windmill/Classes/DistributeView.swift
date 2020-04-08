//
//  DistributeView.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 24/1/18.
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
    @IBOutlet weak var commitTextField: NSTextField!
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

    var metadata: Export.Metadata? {
        didSet {
            guard let commit = metadata?.commit else {
                return
            }
            
            self.commitTextField.stringValue = "(\(commit.shortSha))"
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

