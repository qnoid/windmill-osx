//
//  ActivityFindProject.swift
//  windmill
//
//  Created by Markos Charatzas on 08/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation
import os

struct ActivityFindProject {
    
    let log = OSLog(subsystem: "io.windmill.windmill", category: "activity")
    let applicationCachesDirectory: ApplicationCachesDirectory

    weak var processManager: ProcessManager?
    weak var activityManager: ActivityManager?

    func success(project: Project, location: Project.Location) -> ActivitySuccess {
     
        return { next in
            
            return { context in
                
                guard let repositoryDirectory = context["repositoryDirectory"] as? RepositoryDirectory else {
                    preconditionFailure("ActivityFindProject expects a `ProjectRepositoryDirectory` under the context[\"repositoryDirectory\"] for a succesful callback")
                }

                let findProject = Process.makeFind(project: project, repositoryLocalURL: repositoryDirectory.URL)
                
                self.processManager?.launch(process: findProject) { projectDirectory in
                 
                    if let projectDirectory = projectDirectory.value {
                        location.url = URL(fileURLWithPath: projectDirectory)
                    }
                    
                    os_log("Project found under: '%{public}@'", log: self.log, type: .debug, location.url.path)

                    guard let commit = location.commit else {
                        preconditionFailure("ActivityFindProject expects the project to be located in a git repo")
                    }

                    
                    DispatchQueue.main.async {
                        self.activityManager?.notify(notification: Windmill.Notifications.didCheckoutProject, userInfo: ["commit": commit])
                    }

                    next?(["location":location])
                }
            }
        }
    }
}
