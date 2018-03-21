//
//  NSTextView+LineEnumerator.swift
//  windmill
//
//  Created by Markos Charatzas on 19/3/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import AppKit

extension String {
    
    func count(separator: Element = "\n", length: Int) -> Int {
        return self.prefix(length).split(separator: separator, omittingEmptySubsequences: false).count
    }
}

extension NSTextView: LineEnumerator {
    
    func glyphRange(for boundingRect: NSRect) -> NSRange {
        return self.layoutManager!.glyphRange(forBoundingRect: boundingRect, in: self.textContainer!)
    }
    
    func line(of string: String, at location: Int) -> Int {
        return string.count(length: location)
    }
    
    func line(at glyphIndex: Int) -> Int {
        let index = self.layoutManager!.characterIndexForGlyph(at: glyphIndex)
        
        return self.line(of: self.string, at: index)
    }
    
    func range(for glyphIndex: Int, lineNumber: Int, _ callback: (_ lineNumber: Int, _ lineRect: NSRect) -> Void) -> NSRange {
        
        let index = self.layoutManager!.characterIndexForGlyph(at: glyphIndex)
        let lineRange = (self.string as NSString).lineRange(for: NSRange(location: index, length: 0))
        
        let range = self.layoutManager!.glyphRange(forCharacterRange: lineRange, actualCharacterRange:nil)
        
        var effectiveRange = NSMakeRange(0, 0)
        
        let lineRect = self.layoutManager!.lineFragmentRect(forGlyphAt: index, effectiveRange: &effectiveRange, withoutAdditionalLayout: true)
        
        callback(lineNumber, lineRect)
        
        return range
    }

    func enumerate(callback: (_ lineNumber: Int, _ lineRect: NSRect) -> Void) {
        
        let range = self.glyphRange(for: self.visibleRect)
        var index = range.location
        var number = self.line(at: index)
        
        while (index < NSMaxRange(range)) {
            
            let range = self.range(for: index, lineNumber: number, callback)
            index = NSMaxRange(range)
            number += 1
        }
    }
}
