//
//  ExportView.swift
//  windmill
//
//  Created by Markos Charatzas on 24/1/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation

import AppKit
import os

@IBDesignable
class ExportView: NSView {
    
    @IBOutlet weak var headerTextField: LinkLabel! {
        didSet{
            let attributedString = NSAttributedString(string: headerTextField.string, attributes: [
                .link : "http://help.apple.com/xcode/mac/current/#/dev7ccaf4d3c",
                .font : headerTextField.font as Any])
            headerTextField.attributedString = attributedString
        }
    }

    @IBOutlet weak var stageIndicatorView: StageIndicatorView! {
        didSet  {
            self.stageIndicatorView.wantsLayer = true
            self.stageIndicatorView.layer?.backgroundColor = NSColor.Windmill.cyan().cgColor
        }
    }
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var versionTextField: NSTextField!
    @IBOutlet weak var deploymentTargetTextField: NSTextField!
    
    var metadata: Metadata? {
        didSet {
            let deployment:[String: String]? = metadata?["deployment"]
            
            self.deploymentTargetTextField.stringValue = deployment?["target"] ?? ""
        }
    }

    var export: Export? {
        didSet {
            self.versionTextField.stringValue = export?.manifest.bundleVersion ?? ""
            self.titleTextField.stringValue = export?.manifest.title ?? ""
        }
    }
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        return dateFormatter
    }()
    
    lazy var fullDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-YYYY, HH.mm"
        
        return dateFormatter
    }()
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wml_addSubview(view: wml_load(view: ExportView.self)!, layout: .centered)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wml_addSubview(view: wml_load(view: ExportView.self)!, layout: .centered)
    }
    
    @IBAction func didSelect(_ sender: NSButton) {
        
        guard let export = export else {
            os_log("export is nil. Did you set it?", log: .default, type: .error)
            return
        }

        let savePanel = NSSavePanel()
            
        savePanel.nameFieldStringValue = export.name
        savePanel.beginSheetModal(for: self.window!) { response in
            
            guard response == NSApplication.ModalResponse.OK else {
                return
            }
            
            do {
                guard let url = savePanel.url else {
                    os_log("destination url is nil", log: .default, type: .error)
                return
                }
                
                try FileManager.default.copyItem(at: export.url, to: url)
            }
            catch let error as NSError {
                os_log("failed %{public}@", log: .default, type: .error, error)
            }
        }
    }

}

