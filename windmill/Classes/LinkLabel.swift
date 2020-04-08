//
//  LinkLabel.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 28/1/18.
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

import Cocoa

/**
 
 ```
 Unfortunately, the previous behavior (attributed string ranges with NSLinkAttributeName rendering in a custom color) was not explicitly supported. It happened to work because NSTextField was only rendering the link when the field editor was present; without the field editor, we fall back to the color specified by NSForegroundColorAttributeName.
 
 Version 10.12 updated NSLayoutManager and NSTextField to render links using the default link appearance, similar to iOS. (see AppKit release notes for 10.12.)
 
 To promote consistency, the intended behavior is for ranges that represent links (specified via NSLinkAttributeName) to be drawn using the default link appearance. So the current behavior is the expected behavior.
 ```
 ref: https://stackoverflow.com/questions/39926951/color-attribute-is-ignored-in-nsattributedstring-with-nslinkattributename
 
 */
@IBDesignable
class LinkLabel: NSTextView {
    
    @IBInspectable var foregroundColor: NSColor = NSColor.linkColor
    @IBInspectable var underlineColor: NSColor = NSColor.linkColor
    
    var attributedString: NSAttributedString? {
        didSet{
            guard let attributedString = attributedString else {
                return
            }
            
            self.textStorage?.setAttributedString(attributedString)
        }
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        return super.hitTest(point)
    }
    
    override func layout() {
        super.layout()
        self.textContainerInset = .zero
        self.linkTextAttributes = [.foregroundColor: self.foregroundColor,
                                   .underlineColor : self.underlineColor,
                                   .underlineStyle: 1, //NSUnderlineStyle cases don't seem to work as of Xcode 9.2
                                   .cursor: NSCursor.pointingHand]
    }
}
