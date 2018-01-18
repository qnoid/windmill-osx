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

class ConsoleViewController: NSViewController, WindmillDelegate {

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
    
    var outputBuffer = OutputBuffer()

    static func make() -> ConsoleViewController {
        let mainStoryboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: Bundle(for: ConsoleViewController.self))
        
        return mainStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: String(describing: ConsoleViewController.self))) as! ConsoleViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.defaultCenter.addObserver(self, selector: #selector(MainViewController.windmillWillDeployProject(_:)), name: Windmill.Notifications.willDeployProject, object: nil)
        self.defaultCenter.addObserver(self, selector: #selector(MainViewController.activityError(_:)), name: Process.Notifications.activityError, object: nil)
    }
    
    @objc func windmillWillDeployProject(_ aNotification: Notification) {
        self.outputBuffer = OutputBuffer()
        self.textView.string = ""
        self.textView.isSelectable = false
    }
    
    @objc func activityError(_ aNotification: Notification) {
        self.outputBuffer.flush(to: self.textView.textStorage)
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
    
    func windmill(_ windmill: Windmill, standardOutput: String, count: Int) {
        self.append(self.textView, output: standardOutput, count: count)
    }
    
    func windmill(_ windmill: Windmill, standardError: String, count: Int) {
        self.append(self.textView, output: standardError, count: count)
    }
    
    func toggle(isHidden: Bool) {
        guard isViewLoaded else {
            return
        }
        
        self.textView.isHidden = isHidden
        self.textView.isSelectable = true
        self.outputBuffer.flush(to: self.textView.textStorage)
        let range = NSRange(location:self.outputBuffer.count,length:0)
        textView.scrollRangeToVisible(range)
    }
}
