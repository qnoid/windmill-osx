//
//  InfoViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 4/3/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import AppKit

class InfoViewController: NSViewController {

    @IBOutlet weak var scrollView: NSScrollView! {
        didSet{
        }
    }
    @IBOutlet var textView: NSTextView! {
        didSet{
            textView.textColor = NSColor.gray
            textView.layerContentsPlacement = .left
            textView.layerContentsRedrawPolicy = .onSetNeedsDisplay
            textView.layoutManager?.allowsNonContiguousLayout = true
            textView.isEditable = false
            textView.isRichText = true
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
    
    var textStorage: NSTextStorage?
    
    let applicationCachesDirectory = Directory.Windmill.ApplicationCachesDirectory()
    
    var errorSummary: ResultBundle.ErrorSummary? {
        didSet{
            guard let textDocumentLocation = errorSummary?.textDocumentLocation, let documentURL = textDocumentLocation.documentURL else {
                return
            }
                        
            guard let data = try? Data(contentsOf: documentURL), let source = String(data: data, encoding: .utf8) else {
                return
            }
            
            guard let textView = self.textView else {
                return
            }
            
            textView.string = source
            
            guard let textStorage = textView.textStorage else {
                return
            }

            if let file = textDocumentLocation.documentURL?.lastPathComponent {
                textView.toolTip = "In Xcode, \"Jump Line In “\(file)“... ⌘L\" \(textDocumentLocation.startingLineNumber)"
            }
            textStorage.addAttributes([NSAttributedStringKey.underlineColor : NSColor.red, NSAttributedStringKey.underlineStyle: NSUnderlineStyle.patternSolid.rawValue | NSUnderlineStyle.styleSingle.rawValue], range: NSRange(location: textDocumentLocation.characterRangeLoc - 1, length: textDocumentLocation.characterRangeLen + 1))
            
            let lineRange = (textStorage.string as NSString).lineRange(for: NSRange(location: textDocumentLocation.characterRangeLoc, length: 0))
            
            textStorage.addAttributes([NSAttributedStringKey.backgroundColor : NSColor.Windmill.errorLine()], range: lineRange)
            
            textView.scrollRangeToVisible(lineRange)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
    }
}
