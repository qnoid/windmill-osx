//
//  NSPasteboard.swift
//  windmill
//
//  Created by Markos Charatzas on 07/09/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import AppKit
import Foundation

extension NSPasteboard
{
    func firstFilename() -> String?
    {
        if (self.availableType(from: ["NSFilenamesPboardType"]) == nil) {
            return nil
        }
        
        let files = self.propertyList(forType: NSFilenamesPboardType) as! NSArray
        let folder = files.firstObject as! String

    return folder
    }
}
