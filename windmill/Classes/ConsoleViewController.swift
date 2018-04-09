//
//  ConsoleViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 16/1/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Cocoa

struct OutputBuffer {
    
    private(set) var count: Int = 0
    private var buffer: String? = ""
    
    mutating public func record(count: Int) {
        self.count = self.count + count
    }

    mutating public func write(output: String) {
        self.buffer?.append(output)
    }
    
    mutating func flush(to string: NSMutableAttributedString?, attributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .bold), NSAttributedStringKey.kern : 0.4]) {
        guard let buffer = self.buffer else {
            return
        }
        self.append(to: string, output: buffer)
        self.buffer = nil
    }
    
    func append(to string: NSMutableAttributedString?, output: String, attributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .bold), NSAttributedStringKey.kern : 0.4]) {
        string?.append(NSAttributedString(string: output, attributes: attributes))
    }
}

class ConsoleViewController: NSViewController, ProcessManagerDelegate {

    @IBOutlet weak var scrollView: NSScrollView! {
        didSet {
            scrollView.wantsLayer = true
        }
    }
    @IBOutlet weak var textView: NSTextView! {
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
    
    weak var windmill: Windmill? {
        didSet{
            self.defaultCenter.addObserver(self, selector: #selector(willStartProject(_:)), name: Windmill.Notifications.willStartProject, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(activityError(_:)), name: Windmill.Notifications.activityError, object: windmill)
        }
    }
    var outputBuffer = OutputBuffer()

    static func make() -> ConsoleViewController {
        let mainStoryboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: Bundle(for: ConsoleViewController.self))
        
        return mainStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: String(describing: ConsoleViewController.self))) as! ConsoleViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func willStartProject(_ aNotification: Notification) {
        self.outputBuffer = OutputBuffer()
        
        if let textView = textView {
            textView.string = ""
            textView.isSelectable = false
        }
    }
    
    @objc func activityError(_ aNotification: Notification) {
        if let error = aNotification.userInfo?["error"] as? NSError {
            self.outputBuffer.record(count: error.localizedDescription.count)
            self.outputBuffer.record(count: "\n".count)
            self.outputBuffer.record(count: error.localizedFailureReason?.count ?? 0)
        }
        
        guard let textView = textView else {
            
            if let error = aNotification.userInfo?["error"] as? NSError {
                self.outputBuffer.write(output: error.localizedDescription)
            }
            return
        }
        
        self.outputBuffer.flush(to: textView.textStorage)

        if let error = aNotification.userInfo?["error"] as? NSError {
            self.outputBuffer.append(to: textView.textStorage, output: error.localizedDescription)
            self.outputBuffer.append(to: textView.textStorage, output: "\n")
            self.outputBuffer.append(to: textView.textStorage, output: error.localizedFailureReason ?? "")
        }
        
        let range = NSRange(location:self.outputBuffer.count,length:0)
        self.textView.scrollRangeToVisible(range)
        self.textView.isSelectable = true
    }

    func append(_ textView: NSTextView?, output: String, count: Int) {
        self.outputBuffer.record(count: count)
        
        guard let textView = textView else {
            self.outputBuffer.write(output: output)
            return
        }        
        
        self.outputBuffer.flush(to: textView.textStorage)
        self.outputBuffer.append(to: textView.textStorage, output: output)
        let range = NSRange(location:self.outputBuffer.count,length:0)
        textView.scrollRangeToVisible(range)
    }
    
    func standardOutput(manager: ProcessManager, process: Process, part: String, count: Int) {
        self.append(self.textView, output: part, count: count)
    }
    
    func standardError(manager: ProcessManager, process: Process, part: String, count: Int) {
        self.append(self.textView, output: part, count: count)
    }
    
    func toggle(isHidden: Bool) {
        guard isViewLoaded else {
            return
        }
        
        self.textView.isHidden = isHidden
        
        self.outputBuffer.flush(to: self.textView.textStorage)
        let range = NSRange(location:self.outputBuffer.count,length:0)
        self.textView.scrollRangeToVisible(range)
        self.textView.isSelectable = true
    }
}
