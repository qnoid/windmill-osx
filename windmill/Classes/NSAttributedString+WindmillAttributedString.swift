//
//  NSAttributedString+WindmillAttributedString.swift
//  windmill
//
//  Created by Markos Charatzas on 19/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import AppKit

extension NSAttributedString
{
    class func commitBuildString(commitNumber: String, branchName: String) -> NSAttributedString
    {
        let commitString = NSAttributedString(string: "\(commitNumber) ", attributes: [NSForegroundColorAttributeName: NSColor.yellowCommitColor()])
        
        
        let branchString = NSAttributedString(string: branchName, attributes: [NSForegroundColorAttributeName: NSColor.greenBranchColor()])
        
        let buildString = NSMutableAttributedString(string: "* ")
        buildString.appendAttributedString(commitString)
        buildString.appendAttributedString(NSAttributedString(string: "(", attributes: [NSForegroundColorAttributeName: NSColor.yellowCommitColor()]))
        buildString.appendAttributedString(branchString)
        buildString.appendAttributedString(NSAttributedString(string: ")", attributes: [NSForegroundColorAttributeName: NSColor.yellowCommitColor()]))
        
        return buildString
    }
}
