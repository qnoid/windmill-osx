//
//  TestReportView.swift
//  windmill
//
//  Created by Markos Charatzas on 15/3/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
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



