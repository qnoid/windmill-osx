//
//  ConsoleViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 16/1/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Cocoa

class ConsoleViewController: NSViewController, DispatchSourceReadProvider {
    
    let dispatch_queue_serial = DispatchQueue(label: "io.windmil.console.raw", qos: .utility, attributes: [])

    var queue: DispatchQueue {
        return self.dispatch_queue_serial
    }

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
    
    var dispatchSourceRead: DispatchSourceRead? {
        didSet {
            oldValue?.activate() //this is to ensure the DispatchSource has been activated minimum one time before calling cancel; An unbalanced call causes a EXC_BAD_EXCEPTION
            oldValue?.cancel()
        }
    }

    static func make() -> ConsoleViewController {
        let mainStoryboard = NSStoryboard(name: "Main", bundle: Bundle(for: ConsoleViewController.self))
        
        return mainStoryboard.instantiateController(withIdentifier: String(describing: ConsoleViewController.self)) as! ConsoleViewController
    }
    
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
            self.dispatchSourceRead = self.makeReadSource(fileHandleForReading: fileHandleForReading, completion: self.queue)
        }
        
        if isViewLoaded {
            self.dispatchSourceRead?.activate()
        }
    }

    /**
     - Precondition: the textview holds any of the existing log
     */
    func append(_ textView: TextView?, output: NSAttributedString, count: Int) {
        textView?.textStorage?.append(output)
        textView?.scrollToEndOfDocumentPlease()
    }
    
    func output(part: String, count: Int) {
        DispatchQueue.main.async {
            self.append(self.textView, output: NSAttributedString(string: part, attributes: [.foregroundColor : NSColor.textColor]), count: count)
        }
    }
    
    func toggle(isHidden: Bool) {
        self.textView?.isHidden = isHidden
        self.textView?.scrollToEndOfDocumentPlease()
        self.textView?.isSelectable = true
    }
}
