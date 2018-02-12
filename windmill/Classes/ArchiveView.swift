//
//  ArchiveView.swift
//  windmill
//
//  Created by Markos Charatzas on 14/08/2017.
//  Copyright © 2017 qnoid.com. All rights reserved.
//

import AppKit
import os

@IBDesignable
class ArchiveView: NSView {
    
    @IBOutlet weak var headerTextField: LinkLabel! {
        didSet{
            let attributedString = NSAttributedString(string: headerTextField.string, attributes: [
                .link : "http://help.apple.com/xcode/mac/9.0/#/dev442d7f2ca",
                .font : headerTextField.font as Any])
            headerTextField.attributedString = attributedString
        }
    }
    
    @IBOutlet weak var stageIndicatorView: StageIndicatorView! {
        didSet  {
            self.stageIndicatorView.wantsLayer = true
            self.stageIndicatorView.layer?.backgroundColor = NSColor.Windmill.orange().cgColor
        }
    }
    
    @IBOutlet weak var archiveImageView: FileImageView!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var versionTextField: NSTextField!
    @IBOutlet weak var dateTextField: NSTextField!
    
    var archive: Archive! {
        didSet{
            self.archiveImageView.url = archive.url
            self.archiveImageView.dragImage = #imageLiteral(resourceName: "archive")
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
        wml_addSubview(view: wml_load(view: ArchiveView.self)!, layout: .centered)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wml_addSubview(view: wml_load(view: ArchiveView.self)!, layout: .centered)
    }
    
    @IBAction func didSelect(_ sender: NSPopUpButton) {
        
        switch sender.indexOfSelectedItem {
        case 1:
            let savePanel = NSSavePanel()
            
            savePanel.nameFieldStringValue = archive.name(dateFormatter: fullDateFormatter)
            savePanel.beginSheetModal(for: self.window!) { response in
                
                guard response == NSApplication.ModalResponse.OK else {
                    return
                }

                do {
                    let url = savePanel.url
                    try FileManager.default.copyItem(at: self.archive.url, to: url!)
                }
                catch let error as NSError {
                    os_log("failed %{public}@", log: .default, type: .error, error)
                }
            }
        case 2:
            do {
                let xcodeArchivesURL = archive.xcodeArchivesURL(dateFormatter: self.dateFormatter)
                
                try FileManager.default.copyItem(
                    at: archive.url,
                    to: xcodeArchivesURL.appendingPathComponent(archive.name(dateFormatter: fullDateFormatter)))
            }
            catch let error as NSError {
                os_log("failed %{public}@", log: .default, type: .error, error)
            }
        default:
            os_log("Index of selected item for NSPopUpButton does not have a corresponding action associated.", log: .default, type: .debug)
        }
    }
}
