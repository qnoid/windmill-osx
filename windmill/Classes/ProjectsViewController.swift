//
//  ProjectsViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 10/01/2016.
//  Copyright © 2016 qnoid.com. All rights reserved.
//

import AppKit

public class ProjectsViewController: NSViewController, WindmillDelegate
{
    static let logger : ConsoleLog = ConsoleLog()
    
    @IBOutlet public weak var outlineView: NSOutlineView!
    
    var windmill: Windmill! {
        didSet{
            self.windmill.delegate = self
            self.outlineView.setDataSource(self.outlineViewDataSource)
            self.outlineView.setDelegate(self.outlineViewdelegate)
            self.outlineView.registerForDraggedTypes([NSFilenamesPboardType])            
        }
    }
    
    let outlineViewdelegate = ProjectsOutlineViewDelegate()
    lazy var outlineViewDataSource : ProjectsDataSource = {
        let outlineViewDataSource = ProjectsDataSource()
            outlineViewDataSource.projectsViewController = self
            outlineViewDataSource.projects = self.windmill.projects
        return outlineViewDataSource
    }()
    
    weak var projectDetailViewController: ProjectDetailViewController!
    
    public override func viewDidLoad() {
        
    }
    /**
     
     Causes the #outlineview to refresh
     
     */
    func reloadData() {
        
        self.outlineView.reloadData()
    }
    
    /// callback from #outlineViewDatasource when a drag operation is performed by the user
    func performDragOperation(info: NSDraggingInfo) -> Bool
    {
        print(__FUNCTION__);
        
        guard let folder = info.draggingPasteboard().firstFilename() else {
            return false
        }
        
        ProjectsViewController.logger.log(.INFO, folder)
        let result = Windmill.parse(fullPathOfLocalGitRepo: folder)
        
        switch result
        {
        case .Success(let project):
            return self.windmill.create(project)
        case .Failure(let error):
            alert(error, window: self.view.window!)
            return false
        }
    }
    
    func windmill(windmill: Windmill, projects: Array<Project>, addedProject project: Project) {
        self.outlineViewDataSource.projects = projects
    }
    
    func windmill(windmill: Windmill, willDeployProject project: Project) {
        self.projectDetailViewController.windmill(windmill, willDeployProject:project)
    }
}