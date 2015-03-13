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
public class MainWindowController : NSWindowController
{
    
    public class func mainWindowController() -> MainWindowController
    {
        let mainWindowController = MainWindowController(windowNibName: "MainWindow")
        mainWindowController.outlineViewdelegate = ProjectsOutlineViewDelegate()
        
        return mainWindowController
    }
    
    var outlineViewDatasource : ProjectsDataSource?{
        didSet{
            self.outlineViewDatasource?.mainWindowController = self
        }
    }

    var outlineViewdelegate : ProjectsOutlineViewDelegate?

    @IBOutlet public weak var outlineView: NSOutlineView!
    
    /**
    Causes the #outlineview to refresh
    
    */
    func reloadData()
    {
        self.outlineView.reloadData()
    }
    
    override public func windowDidLoad()
    {
        println(__FUNCTION__)
        self.outlineView.setDataSource(self.outlineViewDatasource)
        self.outlineView.setDelegate(self.outlineViewdelegate)
    }
}