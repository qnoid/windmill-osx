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
            self.defaultCenter.addObserver(self, selector: #selector(willStartProject(_:)), name: Windmill.Notifications.willStartProject, object: windmill)
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
    
    /**
     - Postcondition: the textview will have its string set to the any existing standardOutput
     */
    override func viewWillAppear() {
        super.viewWillAppear()
        self.textView.string = ""
        self.dispatchSourceRead = self.read()
        self.dispatchSourceRead?.activate()
    }
    
    @objc func willStartProject(_ aNotification: Notification) {
        if let textView = textView {
            textView.string = ""
            textView.isSelectable = false
        }
    }
    
    /**
     - Precondition: the textview holds any of the existing log
     */
    func append(_ textView: TextView?, output: String, count: Int) {
        textView?.string.append(output)
        textView?.scrollToEndOfDocumentPlease()
    }
    
    func output(part: String, count: Int) {
        guard isViewLoaded else {
            return
        }

        self.append(self.textView, output: part, count: count)
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
