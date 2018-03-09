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
    struct Windmill {
        
        static func orange() -> NSColor {
            return NSColor(red: 255/255, green: 147/255, blue: 0/255, alpha: 1.0)
        }
        
        static func cyan() -> NSColor {
            return NSColor(red: 118/255, green: 214/255, blue: 255/255, alpha: 1.0)
        }
        
        static func purple() -> NSColor {
            return NSColor(red: 255/255, green: 47/255, blue: 146/255, alpha: 1.0)
        }
        
        static func currentLine() -> NSColor {
            return NSColor(red: 232/255, green: 242/255, blue: 255/255, alpha: 1.0)
        }
        
        static func errorLine() -> NSColor {
            return NSColor(red: 254/255, green: 239/255, blue: 234/255, alpha: 1.0)
        }
        
        static func gray() -> NSColor {
            return NSColor(red: 72/255, green: 72/255, blue: 72/255, alpha: 1.0)
        }
    }
    
    class func greenBranchColor() -> NSColor {
        return NSColor(calibratedRed:0.231, green:0.733, blue:0.200, alpha:1.00)
    }
    
    class func yellowCommitColor() -> NSColor {
        return NSColor(calibratedRed:0.682, green:0.675, blue:0.200, alpha:1.00)
    }
}
