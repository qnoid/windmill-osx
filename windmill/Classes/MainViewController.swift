//
//  MainViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 10/01/2016.
//  Copyright © 2016 qnoid.com. All rights reserved.
//

import AppKit

class MainViewController: NSSplitViewController {

    var projectsViewController: ProjectsViewController {
        let projectsViewController = self.splitViewItems[0].viewController as! ProjectsViewController
        projectsViewController.projectDetailViewController = self.projectDetailViewController
        return projectsViewController
    }

    var projectDetailViewController: ProjectDetailViewController {
        return self.splitViewItems[1].viewController as! ProjectDetailViewController
    }

    func performDragOperation(info: NSDraggingInfo) -> Bool {
        return self.projectsViewController.performDragOperation(info)
    }    
}