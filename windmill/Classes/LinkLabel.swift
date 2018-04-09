//
//  LinkLabel.swift
//  windmill
//
//  Created by Markos Charatzas on 28/1/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
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
    
    @IBInspectable var foregroundColor: NSColor = NSColor.white
    @IBInspectable var underlineColor: NSColor = NSColor.white
    
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
