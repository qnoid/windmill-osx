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

class FileImageView: NSImageView, NSDraggingSource {
    
    var url: URL!
    var dragImage: NSImage?
    
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
            return NSDragOperation.copy
    }
    
    override func mouseDown(with event: NSEvent) {
        
        let draggingItem = NSDraggingItem(pasteboardWriter: self.url as NSURL)
        
        if let dragImage = dragImage {
            draggingItem.setDraggingFrame(self.bounds, contents: dragImage)
        }
        
        self.beginDraggingSession(with: [draggingItem], event: event, source: self)
        
    }
}

@IBDesignable
class ExportView: NSView {
    
    @IBOutlet weak var headerTextField: LinkLabel! {
        didSet{
            let attributedString = NSAttributedString(string: headerTextField.string, attributes: [
                .link : "https://help.apple.com/xcode/mac/9.0/#/devade83d1d7?sub=dev103e8473e",
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
    @IBOutlet weak var ipaImageView: FileImageView!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var versionTextField: NSTextField!
    @IBOutlet weak var deploymentTargetTextField: NSTextField!
    
    var buildSettings: BuildSettings? {
        didSet {
            self.deploymentTargetTextField.stringValue = buildSettings?.deployment.target?.description ?? ""
        }
    }

    var appBundle: AppBundle? {
        didSet{
            guard let iconURL = appBundle?.iconURL(), let dragImage = NSImage(contentsOf: iconURL) else {
                self.ipaImageView.dragImage = #imageLiteral(resourceName: "ipa")
                
                return
            }
            
            self.ipaImageView.dragImage = dragImage
        }
    }
    var export: Export? {
        didSet {
            self.ipaImageView.url = export?.url
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

