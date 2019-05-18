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
    var group = DispatchGroup()

    var queue: DispatchQueue {
        return self.dispatch_queue_serial
    }

    var fileHandleForReading: FileHandle? {
        guard let configuration = self.configuration else {
            return nil
        }
        
        return try? FileHandle(forReadingFrom: configuration.projectLogURL)
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
    
    var configuration: Windmill.Configuration? {
        return windmill?.configuration
    }

    weak var windmill: Windmill? {
        didSet{
            self.defaultCenter.addObserver(self, selector: #selector(willRun(_:)), name: Windmill.Notifications.willRun, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(didRun(_:)), name: Windmill.Notifications.didRun, object: windmill)
        }
    }
    
    var dispatchSourceRead: DispatchSourceRead? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    static func make() -> ConsoleViewController {
        let mainStoryboard = NSStoryboard(name: "Main", bundle: Bundle(for: ConsoleViewController.self))
        
        return mainStoryboard.instantiateController(withIdentifier: String(describing: ConsoleViewController.self)) as! ConsoleViewController
    }
    
    deinit {
        dispatchSourceRead?.cancel()
    }
    
    override func viewDidLoad() {
        self.group.leave()
    }

    @objc func willRun(_ aNotification: Notification) {
        textView?.string = ""
        textView?.isSelectable = false
        textView?.allowScrollToEndOfDocument = true
    }
    
    @objc func didRun(_ aNotification: Notification) {
        
        if !isViewLoaded {
            self.group.enter()
        }
        
        self.dispatchSourceRead = self.read(completion: self.queue)
        self.dispatchSourceRead?.activate()
    }

    /**
     - Precondition: the textview holds any of the existing log
     */
    func append(_ textView: TextView?, output: NSAttributedString, count: Int) {
        textView?.textStorage?.append(output)
        textView?.scrollToEndOfDocumentPlease()
    }
    
    func output(part: String, count: Int) {
        self.group.wait()
        
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
