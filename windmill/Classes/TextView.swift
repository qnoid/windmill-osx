//
//  TextView.swift
//  windmill
//
//  Created by Markos Charatzas on 20/4/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import AppKit

extension NSTextAttachment {
    
    struct Windmill {
        
        static func make(image: NSImage) -> NSTextAttachment {
            let textAttachmentCell = NSTextAttachmentCell(imageCell: image)
            let textAttachment = NSTextAttachment(data: image.tiffRepresentation, ofType: kUTTypeTIFF as String)
            textAttachment.attachmentCell = textAttachmentCell
            
            return textAttachment
        }
    }
}

class TextView: NSTextView {
    
    var allowScrollToEndOfDocument: Bool = true
    
    func scrollToEndOfDocumentPlease() {
        guard allowScrollToEndOfDocument else {
            return
        }
        
        self.scrollToEndOfDocument(self)
    }
    
    override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)
        
        
        let documentVisibleY = self.enclosingScrollView!.documentVisibleRect.minY
        
        /* Scrolling to the bottom or top of the document view
         https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/NSScrollViewGuide/Articles/Scrolling.html
         let
         */
        let isAtEndOfDocument = documentVisibleY >= (self.frame.maxY - self.enclosingScrollView!.contentView.bounds.height)
        self.allowScrollToEndOfDocument = isAtEndOfDocument
    }
}
