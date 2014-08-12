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
    
    var statusItem: NSStatusItem?
    
    required init(coder: NSCoder) {
        super.init(coder: coder);
    }
    
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        self.registerForDraggedTypes([NSFilenamesPboardType])
    }
    
    func rectCenteredInside(rect: CGRect ,contentSize: CGSize) -> CGRect {
    
    return CGRectMake( CGRectGetMinX(rect) + round((CGRectGetWidth(rect) - contentSize.width) / 2),
        CGRectGetMinY(rect) + round((CGRectGetHeight(rect) - contentSize.height) / 2),
        contentSize.width,
        contentSize.height)
    }
    
    func pathForDir(name: String!) -> String! {
        return NSBundle.mainBundle().pathForResource(name, ofType:nil);
    }
    
    override func mouseDown(theEvent: NSEvent!){
        dispatch_async(dispatch_get_main_queue()){
            
            if let statusItem = self.statusItem {
                statusItem.popUpStatusItemMenu(statusItem.menu)
            }
        }
    }
    
    override func drawRect(rect: NSRect)
    {
        let image = NSImage(named:"windmill")
        
        let srcRect = NSMakeRect(0, 0, image.size.width, image.size.height);

        let canvasRect = NSRectToCGRect(rect);
        let imageSize = NSSizeToCGSize(srcRect.size);
        let dstRect = self.rectCenteredInside(canvasRect, contentSize: imageSize)

        image.drawInRect(NSRectFromCGRect(dstRect), fromRect: srcRect, operation: .CompositeSourceOver, fraction: 1.0)
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
        
        if (pboard.availableTypeFromArray(["NSFilenamesPboardType"]) != nil) {
            let files : AnyObject! = pboard.propertyListForType(NSFilenamesPboardType)

            println(files)
            
            let folder = files.firstObject as String
            
            let task = NSTask()
            task.launchPath = NSBundle.mainBundle().pathForResource("scripts/checkout", ofType: "sh")
            task.arguments = [folder, self.pathForDir("scripts"), self.pathForDir("resources")]
            task.launch()
            
            // Perform operation using the list of files
        }

        return true;
    }
}