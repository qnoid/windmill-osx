//
//  ActivityFindProject.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 08/03/2019.
//  Copyright © 2014-2020 qnoid.com. All rights reserved.
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation is required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.
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
