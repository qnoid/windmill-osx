//
//  SummaryViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 4/3/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import AppKit

extension NSTextView {
    
    func lineRange(for textDocumentLocation: TextDocumentLocation) -> NSRange? {
        
        guard textDocumentLocation.characterRangeLoc >= 0 else {
            return nil
        }
        
        let string = (self.string as NSString)
        
        return string.lineRange(for: NSRange(location: textDocumentLocation.characterRangeLoc, length: 0))
    }

    /**
 
     - parameter line: 0 based.
    */
    func lineRange(startingLineNumber: Int) -> NSRange {
        
        guard let layoutManager = self.layoutManager else {
            return NSRange()
        }
        
        var effectiveRange = NSRange()
        
        var numberOfLines = 0
        var indexOfGlyph = 0
        
        while (indexOfGlyph < layoutManager.numberOfGlyphs && numberOfLines < startingLineNumber + 1) {
            layoutManager.lineFragmentRect(forGlyphAt: indexOfGlyph, effectiveRange: &effectiveRange)
            indexOfGlyph = NSMaxRange(effectiveRange)
            numberOfLines += 1
        }
        
        return effectiveRange
    }
}

class SummaryViewController: NSViewController {

    @IBOutlet weak var scrollView: NSScrollView! {
        didSet{
        }
    }
    @IBOutlet var textView: NSTextView! {
        didSet{
            let rulerView = TextViewRuler<NSTextView>(scrollView: textView.enclosingScrollView, orientation: .verticalRuler)
            rulerView.clientView = textView
            rulerView.ruleThickness = 36
            rulerView.accessoryView = nil
            
            textView.usesRuler = true
            textView.isRulerVisible = true
            textView.enclosingScrollView?.horizontalRulerView = nil
            textView.enclosingScrollView?.verticalRulerView = rulerView

            textView.textColor = NSColor.black
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
        }
    }
    
    var textStorage: NSTextStorage?
    
    let applicationCachesDirectory = Directory.Windmill.ApplicationCachesDirectory()
    
    var summary: Summary? {
        didSet{
            guard let textDocumentLocation = summary?.textDocumentLocation, let documentURL = textDocumentLocation.documentURL else {
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
                textView.toolTip = "In Xcode, \"Jump Line In “\(file)“... ⌘L\" \(textDocumentLocation.startingLineNumber + 1)"
            }
            
            if let characterRange = textDocumentLocation.characterRange {
                textStorage.addAttributes([NSAttributedStringKey.underlineColor : NSColor.red, NSAttributedStringKey.underlineStyle: NSUnderlineStyle.patternSolid.rawValue | NSUnderlineStyle.styleSingle.rawValue], range: characterRange)
            }
            
            let lineRange: NSRange
            
            if let range = textView.lineRange(for: textDocumentLocation) {
                lineRange = range
            } else {
                lineRange = textView.lineRange(startingLineNumber: textDocumentLocation.startingLineNumber)
            }
            
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
