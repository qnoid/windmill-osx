//
//  NSColor+WindmillColor.swift
//  windmill
//
//  Created by Markos Charatzas on 19/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import AppKit

extension NSColor
{
    class func greenBranchColor() -> NSColor {
        return NSColor(calibratedRed:0.231, green:0.733, blue:0.200, alpha:1.00)
    }
    
    class func yellowCommitColor() -> NSColor {
        return NSColor(calibratedRed:0.682, green:0.675, blue:0.200, alpha:1.00)
    }
}