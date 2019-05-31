//
//  ActivityExport.swift
//  windmill
//
//  Created by Markos Charatzas on 08/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

struct ActivityExport {
    
    let locations: Windmill.Locations
    
    weak var processManager: ProcessManager?
    weak var delegate: ActivityDelegate?

    let logfile: URL
    
    init(locations: Windmill.Locations, processManager: ProcessManager, logfile: URL) {
        self.locations = locations
        self.processManager = processManager
        self.logfile = logfile
    }

    func success(projectAt: Project.Location, project: Project, appBundle: AppBundle, configuration: Project.Configuration, build: Configuration, exportDirectoryURL: URL) -> SuccessfulActivity {
        
        return SuccessfulActivity { next in
            
            return { [home = self.locations.home] context in
            
                let resultBundle = self.locations.exportResultBundle
                
                guard let archive = context["archive"] as? Archive else {
                    preconditionFailure("ActivityExport expects a `Archive` under the context[\"archive\"] for a succesful callback")
                }
                let makeExport = Process.makeExport(projectAt: projectAt, archive: archive, exportDirectoryURL: exportDirectoryURL, resultBundle: resultBundle, log: self.logfile)

                let scheme = configuration.detectScheme(name: project.scheme)
                let export = home.export(name: scheme)

                let userInfo: [AnyHashable : Any] = ["activity" : ActivityType.export, "project":project, "artefact": ArtefactType.ipaFile, "export": export, "appBundle": appBundle, "resultBundle": resultBundle]
                self.delegate?.willLaunch(activity: .export, userInfo: userInfo)
                self.processManager?.launch(process: makeExport, userInfo: userInfo, wasSuccesful: { userInfo in
                    
                    self.delegate?.didExitSuccesfully(activity: .export, userInfo: userInfo)
                    
                    let archivedAppBundle = home.archivedAppBundle(archive: archive, name: export.distributionSummary.name)
                    
                    let metadata = home.metadata(project: project, projectAt: projectAt, configuration: build, applicationProperties: archivedAppBundle.info)
                    
                    let userInfo = userInfo.merging(["export": export, "metadata": metadata, "appBundle": archivedAppBundle], uniquingKeysWith: { (_, new) -> Any in
                        return new //shouldn't it be the new one? if not the appBundle doesn't make a difference.
                    })
                    
                    self.delegate?.notify(notification: Windmill.Notifications.didExportProject, userInfo: userInfo)
                    
                    next?(userInfo)
                })
                self.delegate?.didLaunch(activity: .export, userInfo: userInfo)
            }
        }
    }
}
