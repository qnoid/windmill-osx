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
    weak var delegate: ActivityDelegate?
    
    let projectLogURL: URL
    
    init(applicationCachesDirectory: ApplicationCachesDirectory, applicationSupportDirectory: ApplicationSupportDirectory, processManager: ProcessManager, projectLogURL: URL) {
        self.applicationCachesDirectory = applicationCachesDirectory
        self.applicationSupportDirectory = applicationSupportDirectory
        self.processManager = processManager
        self.projectLogURL = projectLogURL
    }
    
    func success(location: Project.Location, project: Project, scheme: String, archive: Archive, configuration: Configuration) -> SuccessfulActivity {
        
        let derivedData = self.applicationCachesDirectory.derivedData(at: project.name)
        let resultBundle = self.applicationSupportDirectory.archiveResultBundle(at: project.name)

        return SuccessfulActivity { next in
            
            return { context in
                
                let makeArchive = Process.makeArchive(location: location, project: project, scheme: scheme, derivedData: derivedData, archive: archive, configuration: configuration, resultBundle: resultBundle, log: self.projectLogURL)

                let userInfo: [AnyHashable : Any] = ["activity" : ActivityType.archive, "artefact": ArtefactType.archiveBundle, "archive": archive, "resultBundle": resultBundle]
                self.delegate?.willLaunch(activity: .archive, userInfo: userInfo)
                self.processManager?.launch(process: makeArchive, userInfo: userInfo, wasSuccesful: { userInfo in
                    
                    self.delegate?.didExitSuccesfully(activity: .archive, userInfo: userInfo)
                    
                    self.delegate?.notify(notification: Windmill.Notifications.didArchiveProject, userInfo: ["project":project, "archive": archive])
                    
                    next?(["archive":archive])
                })
                self.delegate?.didLaunch(activity: .archive, userInfo: userInfo)
            }
        }
    }
}
