 //
//  TextViewRuler.swift
//  windmill
//
//  Created by Markos Charatzas on 19/3/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
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
        NSColor.white.set()
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
    
    func textAttributes() -> [NSAttributedStringKey: AnyObject] {
        return [
            NSAttributedStringKey.font: NSFont.labelFont(ofSize: NSFont.systemFontSize(for: .mini)),
            NSAttributedStringKey.foregroundColor: NSColor(calibratedWhite: 0.42, alpha: 1),
        ]
    }
}
