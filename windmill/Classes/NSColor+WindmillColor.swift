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

        static func blue() -> NSColor {
            return NSColor(red: 64/255, green: 137/255, blue: 197/255, alpha: 1.0)
        }

        static func green() -> NSColor {
            return NSColor(red: 0/255, green: 250/255, blue: 146/255, alpha: 1.0)
        }

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

        static func red() -> NSColor {
            return NSColor(red: 226/255, green: 20/255, blue: 20/255, alpha: 1.0)
        }
        
        static func gitCyan() -> NSColor {
            return NSColor(red: 0/255, green: 166/255, blue: 178/255, alpha: 1.0)
        }

        static func gitYellow() -> NSColor {
            return NSColor(red: 153/255, green: 153/255, blue: 0/255, alpha: 1.0)
        }
        
        static func gitGreen() -> NSColor {
            return NSColor(red: 0/255, green: 166/255, blue: 0/255, alpha: 1.0)
        }
    }
}
