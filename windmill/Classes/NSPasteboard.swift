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
    func fileURL() -> URL?
    {
        guard self.availableType(from: [PasteboardType.fileURL]) != nil else {
            return nil
        }
        
    return NSURL(from: self) as URL?
    }
}
