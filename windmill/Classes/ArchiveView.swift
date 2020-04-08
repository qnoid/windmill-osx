//
//  ArchiveView.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 14/08/2017.
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

import AppKit
import os

@IBDesignable
class ArchiveView: NSView {
    
    @IBOutlet weak var stageIndicatorView: StageIndicatorView! {
        didSet  {
            self.stageIndicatorView.color = NSColor(named:"archive")
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
