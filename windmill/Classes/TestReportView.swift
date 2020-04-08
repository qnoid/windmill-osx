//
//  TestReportView.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 15/3/18.
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


class TestReportButton: NSButton {
    
    var _title: String = "" {
        didSet {
            self.attributedTitle = NSAttributedString(string: self._title,
                                                      attributes: [
                                                        .foregroundColor : NSColor.textColor,
                                                        .font : self.font as Any ])
        }
    }

    var testReport: TestReport = .success(testsCount: 0) {
        didSet {
            self._title = testReport.description
            self.image = testReport.status.image
        }
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        
        if case .success = self.testReport {
            return nil
        }
        
        return super.hitTest(point)
    }
}

@IBDesignable
class TestReportView: NSView {
    
    @IBOutlet weak var headerTextField: LinkLabel! {
        didSet{
            let attributedString = NSAttributedString(string: headerTextField.string, attributes: [
                .foregroundColor: NSColor.labelColor,
                .font : headerTextField.font as Any])
            headerTextField.attributedString = attributedString
        }
    }
    
    @IBOutlet weak var stageIndicatorView: StageIndicatorView! {
        didSet  {
            self.stageIndicatorView.color = NSColor(named:"test")
        }
    }
    @IBOutlet weak var testButton: TestReportButton! {
        didSet{
            self.testButton._title = testButton.title
        }
    }
    @IBOutlet weak var openButton: NSButton!
    
    var testReport: TestReport = .success(testsCount: 0) {
        didSet {
            self.testButton.testReport = testReport
        }
    }

    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wml_addSubview(view: wml_load(view: TestReportView.self)!, layout: .centered)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wml_addSubview(view: wml_load(view: TestReportView.self)!, layout: .centered)
    }
}



