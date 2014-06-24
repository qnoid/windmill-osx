//
//  FooView.swift
//  windmill
//
//  Created by Markos Charatzas on 10/06/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import Cocoa

class FooView: NSView
{
    init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        self.registerForDraggedTypes([NSFilenamesPboardType])
    }
    
    override func drawRect(dirtyRect: NSRect)
    {
        let image = NSImage(named:"windmill")
        image.drawAtPoint(NSMakePoint(0, 0), fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1.0)
    }
    
    override func draggingEntered(sender: NSDraggingInfo!) -> NSDragOperation
    {
        println("Drag Enter");
        return .Copy;
    }

    override func draggingUpdated(sender: NSDraggingInfo!) -> NSDragOperation
    {
        return .Copy;
        
    }

    override func draggingExited(sender: NSDraggingInfo!)
    {
        println("Drag Exit");
        
    }

    override func prepareForDragOperation(sender: NSDraggingInfo!) -> Bool
    {
        println(__FUNCTION__);
        return true;
        
    }

    override func performDragOperation(sender: NSDraggingInfo!) -> Bool
    {
        println(__FUNCTION__);
        let pboard = sender.draggingPasteboard()
        
        if (pboard.availableTypeFromArray(["NSFilenamesPboardType"])) {
            let files : AnyObject! = pboard.propertyListForType(NSFilenamesPboardType)

            println(files)
            
            let folder = files.firstObject as String
            
            let task = NSTask()
            task.launchPath = NSBundle.mainBundle().pathForResource("scripts/checkout", ofType: "sh")
            task.arguments = [folder]
            task.launch()
            
            // Perform operation using the list of files
        }

        return true;
        
    }
}