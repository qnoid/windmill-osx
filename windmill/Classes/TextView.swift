//
//  TextView.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 20/4/18.
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

extension NSTextAttachment {
    
    struct Windmill {

        static let buildInProgressImageAttachment = make(image: NSImage(imageLiteralResourceName: "Status-BuildInProgress"))
        static let failedTestImageAttachment = make(image: NSImage(imageLiteralResourceName: "test-failure"))
        static let failureImageAttachment = make(image: NSImage(imageLiteralResourceName: "error"))
        static let successImageAttachment = make(image: NSImage(imageLiteralResourceName: "Success"))
        static let warningImageAttachment = make(image: NSImage(imageLiteralResourceName: "WarningTriangle"))

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
