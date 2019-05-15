//
//  ActivityExport.swift
//  windmill
//
//  Created by Markos Charatzas on 08/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

struct ActivityExport {
    
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

    func success(location: Project.Location, project: Project, projectDirectory: ProjectDirectory, appBundle: AppBundle, export: Export, configuration: Configuration, exportDirectoryURL: URL) -> SuccessfulActivity {
        
        let resultBundle = self.applicationSupportDirectory.exportResultBundle(at: project.name)

        return SuccessfulActivity { next in
            
            return { context in
            
                guard let archive = context["archive"] as? Archive else {
                    preconditionFailure("ActivityExport expects a `Archive` under the context[\"archive\"] for a succesful callback")
                }
                let makeExport = Process.makeExport(location: location, archive: archive, exportDirectoryURL: exportDirectoryURL, resultBundle: resultBundle, log: self.projectLogURL)

                let userInfo: [AnyHashable : Any] = ["activity" : ActivityType.export, "project":project, "artefact": ArtefactType.ipaFile, "export": export, "appBundle": appBundle, "resultBundle": resultBundle]
                self.delegate?.willLaunch(activity: .export, userInfo: userInfo)
                self.processManager?.launch(process: makeExport, userInfo: userInfo, wasSuccesful: { userInfo in
                    
                    self.delegate?.didExitSuccesfully(activity: .export, userInfo: userInfo)
                    
                    let appBundle = projectDirectory.appBundle(archive: archive, name: export.distributionSummary.name)
                    
                    let metadata = projectDirectory.metadata(project: project, location: location, configuration: configuration, applicationProperties: appBundle.info)
                    
                    let userInfo = userInfo.merging(["export": export, "metadata": metadata, "appBundle": appBundle], uniquingKeysWith: { (_, new) -> Any in
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
