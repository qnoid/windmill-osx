//
//  NSOutlineView+WindmillOutlineView.swift
//  windmill
//
//  Created by Markos Charatzas on 12/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import AppKit

extension NSOutlineView
{
    func makeViewWithIdentifier(identifier: String) -> NSTableCellView {
        return self.makeViewWithIdentifier(identifier, owner: nil) as! NSTableCellView
    }
}
