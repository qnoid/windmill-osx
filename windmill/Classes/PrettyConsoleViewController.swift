//
//  PrettyConsoleViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 12/4/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Cocoa
import os

class PrettyConsoleViewController: NSViewController, StandardOutFormattedReaderDelegate {

    @IBOutlet weak var scrollView: NSScrollView! {
        didSet {
            scrollView.wantsLayer = true
        }
    }

    @IBOutlet weak var textView: TextView! {
        didSet {
            textView.layerContentsPlacement = .left
            textView.layerContentsRedrawPolicy = .onSetNeedsDisplay
            textView.layoutManager?.allowsNonContiguousLayout = true
            textView.isEditable = false
            textView.isRichText = false
            textView.allowsUndo = false
            textView.isContinuousSpellCheckingEnabled = false
            textView.isAutomaticSpellingCorrectionEnabled = false
            textView.isAutomaticQuoteSubstitutionEnabled = false
            textView.isAutomaticDashSubstitutionEnabled = false
            textView.isAutomaticTextReplacementEnabled = false
            textView.smartInsertDeleteEnabled = false
            textView.usesFontPanel = false
            textView.usesFindPanel = false
            textView.usesRuler = false
        }
    }
    
    var descender: CGFloat {
        return self.textView?.font?.descender ?? 0.0
    }

    let defaultCenter = NotificationCenter.default
    
    var configuration: Windmill.Configuration? {
        return windmill?.configuration
    }
    
    weak var windmill: Windmill? {
        didSet{
            self.defaultCenter.addObserver(self, selector: #selector(willStartProject(_:)), name: Windmill.Notifications.willStartProject, object: windmill)
        }
    }

    lazy var compileFormatter: RegularExpressionMatchesFormatter<NSAttributedString> = {
        guard let configuration = self.windmill?.configuration else {
            return RegularExpressionMatchesFormatter<NSAttributedString>.makeCompile(descender: descender)
        }
        
        let baseDirectoryURL = configuration.projectRepositoryDirectory.URL.appendingPathComponent("/")
        return RegularExpressionMatchesFormatter<NSAttributedString>.makeCompile(descender: descender, baseDirectoryURL: baseDirectoryURL)
    }()
    
    lazy var cpHeaderFormatter: RegularExpressionMatchesFormatter<NSAttributedString> = {
        guard let configuration = self.windmill?.configuration else {
            return RegularExpressionMatchesFormatter<NSAttributedString>.makeCpHeader(descender: descender)
        }
        
        let baseDirectoryURL = configuration.projectRepositoryDirectory.URL.appendingPathComponent("/")
        return RegularExpressionMatchesFormatter<NSAttributedString>.makeCpHeader(descender: descender, baseDirectoryURL: baseDirectoryURL)
    }()


    var dispatchSourceRead: DispatchSourceRead? {
        didSet {
            oldValue?.cancel()
        }
    }

    lazy var standardOutFormattedReader: StandardOutFormattedReader = {
        let standardOutFormattedReader = StandardOutFormattedReader.make(standardOutFormatter: StandardOutPrettyFormatter(descender: descender, compileFormatter: compileFormatter, cpHeaderFormatter: cpHeaderFormatter), fileURL: self.configuration?.projectLogURL)
        standardOutFormattedReader.delegate = self
        return standardOutFormattedReader
    }()
    
    deinit {
        dispatchSourceRead?.cancel()
    }

    @objc func willStartProject(_ aNotification: Notification) {
        
        if let textView = textView {
            textView.string = ""
            textView.isSelectable = false
            textView.allowScrollToEndOfDocument = true
        }
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        self.textView.string = ""
        self.dispatchSourceRead = self.standardOutFormattedReader.activate()
    }
    
    func append(_ textView: TextView?, line: NSAttributedString) {
        textView?.textStorage?.append(line)
        textView?.scrollToEndOfDocumentPlease()
    }
    
    func standardOut(line: NSAttributedString) {
        guard isViewLoaded else {
            return
        }
        
        self.append(self.textView, line: line)
    }

    
    func toggle(isHidden: Bool) {
        guard isViewLoaded else {
            return
        }
        
        self.textView.isHidden = isHidden
        self.textView?.scrollToEndOfDocumentPlease()
        self.textView.isSelectable = true
    }
}
