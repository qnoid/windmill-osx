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
public class MainWindowController : NSWindowController, WindmillDelegate
{
    static let logger : ConsoleLog = ConsoleLog()

    public class func mainWindowController(windmill: Windmill) -> MainWindowController
    {
        let mainWindowController = MainWindowController(windowNibName: "MainWindow")
        mainWindowController.windmill = windmill
        
        return mainWindowController
    }
    
    lazy var outlineViewDataSource : ProjectsDataSource = {
            let outlineViewDataSource = ProjectsDataSource.projectsDataSource()
            outlineViewDataSource.mainWindowController = self
        return outlineViewDataSource
    }()

    var outlineViewdelegate = ProjectsOutlineViewDelegate()
    var windmill: Windmill! {
        didSet{
            self.windmill.delegate = self
        }
    }
    
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
        self.outlineView.setDataSource(self.outlineViewDataSource)
        self.outlineView.setDelegate(self.outlineViewdelegate)
        self.outlineView.registerForDraggedTypes([NSFilenamesPboardType])
    }
    
    /// callback from #outlineViewDatasource when a drag operation is performed by the user
    func performDragOperation(info: NSDraggingInfo) -> Bool
    {
        println(__FUNCTION__);
        
        if let folder = info.draggingPasteboard().firstFilename()
        {
            MainWindowController.logger.log(.INFO, folder)
            self.windmill.add(folder)
            
            return true
        }
        
        return false
    }
    
    func created(windmill: Windmill, projects: Array<Project>, project: Project) {
        self.outlineViewDataSource.projects = projects
    }
    
    func failed(windmill: Windmill, error: NSError)
    {
        let alert = NSAlert()
        alert.messageText = error.localizedDescription
        alert.informativeText = error.localizedFailureReason
        alert.alertStyle = .CriticalAlertStyle
        alert.beginSheetModalForWindow(self.window!, completionHandler: nil)
    }
}