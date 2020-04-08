//
//  NSTextView+LineEnumerator.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 19/3/18.
//  Copyright © 2014-2020 qnoid.com. All rights reserved.
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation is required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.
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
