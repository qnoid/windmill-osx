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
    @IBOutlet weak var buildProgressIndicator: NSProgressIndicator!
    @IBOutlet public weak var buildTextField: NSTextField!
    
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
        print(__FUNCTION__)
        self.outlineView.setDataSource(self.outlineViewDataSource)
        self.outlineView.setDelegate(self.outlineViewdelegate)
        self.outlineView.registerForDraggedTypes([NSFilenamesPboardType])
    }
    
    /// callback from #outlineViewDatasource when a drag operation is performed by the user
    func performDragOperation(info: NSDraggingInfo) -> Bool
    {
        print(__FUNCTION__);
        
        guard let folder = info.draggingPasteboard().firstFilename() else {
            return false
        }
        
        MainWindowController.logger.log(.INFO, folder)
        let result = parse(fullPathOfLocalGitRepo: folder)
        
        switch result
        {
            case .Success(let project):
                let wasDeployed = self.windmill.deploy(project)
                
                if(wasDeployed) {
                    self.buildProgressIndicator.startAnimation(self)
                
                    let commitNumber = "8076c32"
                    self.buildTextField.attributedStringValue = NSAttributedString.commitBuildString(commitNumber, branchName: "master")
                }

                return true
            case .Failure(let error):
                alert(error)(window: self.window!)
                return false
        }
    }
    
    func created(windmill: Windmill, projects: Array<Project>, project: Project) {
        self.outlineViewDataSource.projects = projects
    }
}