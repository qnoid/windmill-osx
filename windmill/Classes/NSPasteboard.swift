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
        guard self.availableType(from: [PasteboardType.fileURL]) != nil else {
            return nil
        }
        
        guard let files = self.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? [String] else {
            return nil
        }
        
    return files.first
    }
}
