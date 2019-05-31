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
    
    weak var processManager: ProcessManager?
    weak var delegate: ActivityDelegate?

    init(processManager: ProcessManager) {
        self.processManager = processManager
    }

    func success(project: Project, projectAt: Project.Location) -> SuccessfulActivity {
     
        return SuccessfulActivity { next in
            
            return { context in
                
                guard let repository = context["repository"] as? RepositoryDirectory else {
                    preconditionFailure("ActivityFindProject expects a `ProjectRepositoryDirectory` under the context[\"repository\"] for a succesful callback")
                }

                let findProject = Process.makeFind(project: project, repositoryLocalURL: repository.URL)
                
                self.processManager?.launch(process: findProject) { projectDirectory in
                 
                    if let projectDirectory = projectDirectory.value {
                        projectAt.url = URL(fileURLWithPath: projectDirectory)
                    }
                    
                    os_log("Project found under: '%{public}@'", log: self.log, type: .debug, projectAt.url.path)

                    guard let commit = projectAt.commit else {
                        let error = NSError.errorNoRepo(projectAt.url.path)
                        self.delegate?.did(terminate: .readProjectConfiguration, error: WindmillError.recoverable(activityType: .readProjectConfiguration, error: error), userInfo: nil)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.delegate?.notify(notification: Windmill.Notifications.didCheckoutProject, userInfo: ["commit": commit])
                    }

                    next?(["projectAt":projectAt])
                }
            }
        }
    }
}
