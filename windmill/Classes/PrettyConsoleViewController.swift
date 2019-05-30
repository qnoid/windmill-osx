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
    
    var locations: Windmill.Locations? {
        return windmill?.locations
    }
    
    weak var windmill: Windmill? {
        didSet{
            self.defaultCenter.addObserver(self, selector: #selector(willRun(_:)), name: Windmill.Notifications.willRun, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(didRun(_:)), name: Windmill.Notifications.didRun, object: windmill)
        }
    }

    lazy var compileFormatter: RegularExpressionMatchesFormatter<NSAttributedString> = {
        guard let locations = self.windmill?.locations else {
            return RegularExpressionMatchesFormatter<NSAttributedString>.makeCompile(descender: descender)
        }
        
        let baseDirectoryURL = locations.repository.URL.appendingPathComponent("/")
        return RegularExpressionMatchesFormatter<NSAttributedString>.makeCompile(descender: descender, baseDirectoryURL: baseDirectoryURL)
    }()
    
    lazy var cpHeaderFormatter: RegularExpressionMatchesFormatter<NSAttributedString> = {
        guard let locations = self.windmill?.locations else {
            return RegularExpressionMatchesFormatter<NSAttributedString>.makeCpHeader(descender: descender)
        }
        
        let baseDirectoryURL = locations.repository.URL.appendingPathComponent("/")
        return RegularExpressionMatchesFormatter<NSAttributedString>.makeCpHeader(descender: descender, baseDirectoryURL: baseDirectoryURL)
    }()


    var dispatchSourceRead: DispatchSourceRead? {
        didSet {
            oldValue?.activate() //this is to ensure the DispatchSource has been activated minimum one time before calling cancel; An unbalanced call causes a EXC_BAD_EXCEPTION
            oldValue?.cancel()
        }
    }
    
    let queue = DispatchQueue(label: "io.windmil.console.distilled", qos: .utility, attributes: [])
    
    lazy var standardOutFormattedReader: StandardOutFormattedReader = {
        let standardOutFormattedReader = StandardOutFormattedReader.make(standardOutFormatter: StandardOutPrettyFormatter(descender: descender, compileFormatter: compileFormatter, cpHeaderFormatter: cpHeaderFormatter), queue: self.queue)
        standardOutFormattedReader.delegate = self
        return standardOutFormattedReader
    }()
    
    deinit {
        dispatchSourceRead?.activate() //this is to ensure the DispatchSource has been activated minimum one time before calling cancel; An unbalanced call causes a EXC_BAD_EXCEPTION
        dispatchSourceRead?.cancel()
    }
    
    override func viewDidLoad() {
        self.dispatchSourceRead?.activate()
    }

    @objc func willRun(_ aNotification: Notification) {
        self.textView?.string = ""
        self.textView?.isSelectable = false
        self.textView?.allowScrollToEndOfDocument = true
    }
    
    @objc func didRun(_ aNotification: Notification) {
        
        if let logfile = locations?.logfile, let fileHandleForReading = try? FileHandle(forReadingFrom: logfile) {
            self.dispatchSourceRead = self.standardOutFormattedReader.read(fileHandleForReading: fileHandleForReading, completion: self.queue)
        }
        
        if isViewLoaded {
            self.dispatchSourceRead?.activate()
        }
    }
    
    func append(_ textView: TextView?, line: NSAttributedString) {
        textView?.textStorage?.append(line)
        textView?.scrollToEndOfDocumentPlease()
    }
    
    func standardOut(line: NSAttributedString) {
        DispatchQueue.main.async {
            self.append(self.textView, line: line)
        }
    }
    
    func toggle(isHidden: Bool) {
        self.textView?.isHidden = isHidden
        self.textView?.scrollToEndOfDocumentPlease()
        self.textView?.isSelectable = true
    }
}
