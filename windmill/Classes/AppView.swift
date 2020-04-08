//
//  AppView.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 10/3/18.
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
class AppView: NSView {
    
    @IBOutlet weak var stageIndicatorView: StageIndicatorView! {
        didSet  {
            self.stageIndicatorView.color = NSColor(named:"build")
        }
    }
    @IBOutlet weak var applicationImageView: FileImageView!
    @IBOutlet weak var bundleTextField: NSTextField!
    @IBOutlet weak var commitTextField: NSTextField!
    @IBOutlet weak var minimumOSVersionTextField: NSTextField!
    
    var commit: Repository.Commit? {
        didSet {
            self.commitTextField.stringValue = commit?.shortSha ?? ""
        }
    }
    
    var appBundle: AppBundle? {
        didSet{
            self.bundleTextField.stringValue = appBundle?.info.bundleIdentifier ?? ""
            self.minimumOSVersionTextField.stringValue = appBundle?.info.minimumOSVersion ?? ""
            self.applicationImageView.url = appBundle?.url
            
            guard let iconURL = appBundle?.iconURL(), let iconImage = NSImage(contentsOf: iconURL) else {
                self.applicationImageView.dragImage = #imageLiteral(resourceName: "application-icon")
                self.applicationImageView.image = #imageLiteral(resourceName: "application-icon")
                return
            }

            self.applicationImageView.image = iconImage
            self.applicationImageView.image?.size = NSSize(width: 42, height: 42)
            self.applicationImageView.dragImage = iconImage
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wml_addSubview(view: wml_load(view: AppView.self)!, layout: .centered)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wml_addSubview(view: wml_load(view: AppView.self)!, layout: .centered)
    }
    
    @IBAction func didSelect(_ sender: NSButton) {
        
        guard let appBundle = appBundle else {
            os_log("appBundle is nil. Did you set it?", log: .default, type: .error)
            return
        }
        
        let savePanel = NSSavePanel()
        
        savePanel.nameFieldStringValue = "\(appBundle.url.lastPathComponent)"
        savePanel.beginSheetModal(for: self.window!) { response in
            
            guard response == NSApplication.ModalResponse.OK else {
                return
            }
            
            do {
                guard let url = savePanel.url else {
                    os_log("destination url is nil", log: .default, type: .error)
                    return
                }
                
                try FileManager.default.copyItem(at: appBundle.url, to: url)
            }
            catch let error as NSError {
                os_log("failed %{public}@", log: .default, type: .error, error)
            }
        }
    }
    
}


