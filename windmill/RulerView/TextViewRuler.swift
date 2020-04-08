 //
//  TextViewRuler.swift
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

class TextViewRuler<ClientView:NSView>: NSRulerView where ClientView: LineEnumerator {
    
    override init(scrollView: NSScrollView?, orientation: NSRulerView.Orientation) {
        super.init(scrollView: scrollView, orientation: orientation)
        NotificationCenter.default.addObserver(self, selector: #selector(boundsDidChange(_:)), name: NSView.boundsDidChangeNotification, object: scrollView)
        self.canDrawConcurrently = false
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        NotificationCenter.default.addObserver(self, selector: #selector(boundsDidChange(_:)), name: NSView.boundsDidChangeNotification, object: scrollView)
        self.canDrawConcurrently = false
    }
    
    @objc
    func boundsDidChange(_ notification: Notification) {
        needsDisplay = true
    }
    
    var _clientView: ClientView {
        return self.clientView as! ClientView
    }
    
    func draw(lineNumber: Int, lineRect: NSRect) {
        let lineNumberLabel = String(format: "%ld", lineNumber)
        lineNumberLabel.draw(in: lineRect, withAttributes: textAttributes())
    }
    
    override func drawHashMarksAndLabels(in rect: NSRect) {
        NSColor.textBackgroundColor.set()
        NSRect(x: 0, y: rect.minY, width: rect.width, height: rect.height).fill()
        
        let origin = self.convert(NSPoint.zero, from:_clientView)
        self._clientView.enumerate { (lineNumber, lineRect) in
            
            var lineRect = lineRect
            
            let y = origin.y + lineRect.minY
            lineRect.origin.y = y
            lineRect.origin.x += self.ruleThickness / 2
            
            self.draw(lineNumber: lineNumber, lineRect: lineRect)
        }
    }
    
    func textAttributes() -> [NSAttributedString.Key: AnyObject] {
        return [
            .font: NSFont.labelFont(ofSize: NSFont.systemFontSize(for: .mini)),
            .foregroundColor: NSColor(calibratedWhite: 0.42, alpha: 1),
        ]
    }
}
