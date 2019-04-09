//
//  ActivityArchive.swift
//  windmill
//
//  Created by Markos Charatzas on 08/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

struct ActivityArchive {
    
    let applicationCachesDirectory: ApplicationCachesDirectory
    let applicationSupportDirectory: ApplicationSupportDirectory

    weak var processManager: ProcessManager?
    weak var activityManager: ActivityManager?
    
    let log: URL
    
    func success(location: Project.Location, project: Project, scheme: String, archive: Archive) -> ActivitySuccess {
        
        let derivedData = self.applicationCachesDirectory.derivedData(at: project.name)
        let resultBundle = self.applicationSupportDirectory.archiveResultBundle(at: project.name)

        return { next in
            
            return { context in
                
                let makeArchive = Process.makeArchive(location: location, project: project, scheme: scheme, derivedData: derivedData, archive: archive, resultBundle: resultBundle, log: self.log)

                let userInfo: [AnyHashable : Any] = ["activity" : ActivityType.archive, "artefact": ArtefactType.archiveBundle, "archive": archive, "resultBundle": resultBundle]
                self.activityManager?.willLaunch(activity: .archive, userInfo: userInfo)
                self.processManager?.launch(process: makeArchive, userInfo: userInfo, wasSuccesful: { userInfo in
                    
                    self.activityManager?.didExitSuccesfully(activity: .archive, userInfo: userInfo)
                    
                    self.activityManager?.notify(notification: Windmill.Notifications.didArchiveProject, userInfo: ["project":project, "archive": archive])
                    
                    next?(["archive":archive])
                })
                self.activityManager?.didLaunch(activity: .archive, userInfo: userInfo)
            }
        }
    }
}
