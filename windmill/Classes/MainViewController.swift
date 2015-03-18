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

    @IBOutlet public weak var outlineView: NSOutlineView!
    var windmill: Windmill! {
        didSet{
            self.windmill.delegate = self
        }
    }

    var outlineViewdelegate = ProjectsOutlineViewDelegate()
    lazy var outlineViewDataSource : ProjectsDataSource = {
        let outlineViewDataSource = ProjectsDataSource()
        outlineViewDataSource.mainWindowController = self
        outlineViewDataSource.projects = self.windmill.projects
        
        return outlineViewDataSource
        }()

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
            let result = parse(fullPathOfLocalGitRepo: folder)
            
            switch result
            {
                case .Success(let project):
                    self.windmill.deployGitRepo(folder, project: project.unbox)
                    return true
                case .Failure(let error):
                    alert(error.unbox)(window: self.window!)
                    return false
            }
        }
        
        return false
    }
    
    func created(windmill: Windmill, projects: Array<Project>, project: Project) {
        self.outlineViewDataSource.projects = projects
    }
}