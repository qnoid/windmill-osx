//
//  ExportView.swift
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
    
    @IBOutlet weak var stageIndicatorView: StageIndicatorView! {
        didSet  {
            self.stageIndicatorView.color = NSColor(named:"export")
        }
    }
    @IBOutlet weak var ipaImageView: FileImageView!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var versionTextField: NSTextField!
    @IBOutlet weak var minimumOSVersionTextField: NSTextField!
    
    var appBundle: AppBundle? {
        didSet{
            self.minimumOSVersionTextField.stringValue = appBundle?.info.minimumOSVersion ?? ""
            
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
            
        savePanel.nameFieldStringValue = export.filename
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

