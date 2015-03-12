//
//  MainWindowController.swift
//  windmill
//
//  Created by Markos Charatzas on 13/02/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import AppKit

/**


*/
class MainWindowController : NSWindowController, NSOutlineViewDelegate
{
    
    class func mainWindowController() -> MainWindowController
    {
        let mainWindowController = MainWindowController(windowNibName: "MainWindow")
        
        return mainWindowController
    }
    
    var datasource : ProjectsDataSource?{
        didSet{
            self.datasource?.mainWindowController = self
        }
    }
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    func reloadData()
    {
        self.outlineView.reloadData()
    }
    
    override func windowDidLoad()
    {
        println(__FUNCTION__)
        self.outlineView.setDataSource(self.datasource)
    }
    
    //NSOutlineViewDelegate
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView?
    {
        if let project = item as? Project
        {
            var v = outlineView.makeViewWithIdentifier("DataCell", owner: self) as! NSTableCellView
            if let tf = v.textField {
                tf.stringValue = project.name
            }
            
            return v
        }

        var v = outlineView.makeViewWithIdentifier("HeaderCell", owner: self) as! NSTableCellView
        if let tf = v.textField {
            tf.stringValue = "Projects"
        }
        
        return v
    }
}