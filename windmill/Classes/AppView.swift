//
//  AppView.swift
//  windmill
//
//  Created by Markos Charatzas on 10/3/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation

import AppKit
import os

@IBDesignable
class AppView: NSView {
    
    @IBOutlet weak var headerTextField: LinkLabel!{
        didSet{
            let attributedString = NSAttributedString(string: headerTextField.string, attributes: [
                .link : "https://help.apple.com/simulator/mac/9.0/#/deve2c6f33cc",
                .font : headerTextField.font as Any])
            headerTextField.attributedString = attributedString
        }
    }
    
    @IBOutlet weak var stageIndicatorView: StageIndicatorView! {
        didSet  {
            self.stageIndicatorView.wantsLayer = true
            self.stageIndicatorView.layer?.backgroundColor = NSColor.Windmill.blue().cgColor
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
            self.applicationImageView.image?.size = NSSize(width: 48, height: 48)
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


