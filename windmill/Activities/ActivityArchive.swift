//
//  ActivityArchive.swift
//  windmill
//
//  Created by Markos Charatzas on 08/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

struct ActivityArchive {
    
    let locations: Windmill.Locations

    weak var processManager: ProcessManager?
    weak var delegate: ActivityDelegate?
    
    let logfile: URL
    
    init(locations: Windmill.Locations, processManager: ProcessManager, logfile: URL) {
        self.locations = locations
        self.processManager = processManager
        self.logfile = logfile
    }
    
    func success(projectAt: Project.Location, project: Project, configuration: Project.Configuration, build: Configuration) -> SuccessfulActivity {
        
        return SuccessfulActivity { next in
            
            return { context in
                
                let derivedData = self.locations.derivedData
                let resultBundle = self.locations.archiveResultBundle
                
                let scheme = configuration.detectScheme(name: project.scheme)
                let archive = self.locations.home.archive(name: scheme)
                
                let makeArchive = Process.makeArchive(projectAt: projectAt, project: project, scheme: scheme, derivedData: derivedData, archive: archive, configuration: build, resultBundle: resultBundle, log: self.logfile)

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
