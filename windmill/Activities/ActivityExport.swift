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
    weak var activityManager: ActivityManager?

    let log: URL
    
    func success(location: Project.Location, project: Project, projectDirectory: ProjectDirectory, appBundle: AppBundle, export: Export, configuration: Configuration, exportDirectoryURL: URL) -> ActivitySuccess {
        
        let resultBundle = self.applicationSupportDirectory.exportResultBundle(at: project.name)

        return { next in
            
            return { context in
            
                guard let archive = context["archive"] as? Archive else {
                    preconditionFailure("ActivityExport expects a `Archive` under the context[\"archive\"] for a succesful callback")
                }
                let makeExport = Process.makeExport(location: location, archive: archive, exportDirectoryURL: exportDirectoryURL, resultBundle: resultBundle, log: self.log)

                let userInfo: [AnyHashable : Any] = ["activity" : ActivityType.export, "project":project, "artefact": ArtefactType.ipaFile, "export": export, "appBundle": appBundle, "resultBundle": resultBundle]
                self.activityManager?.willLaunch(activity: .export, userInfo: userInfo)
                self.processManager?.launch(process: makeExport, userInfo: userInfo, wasSuccesful: { userInfo in
                    
                    self.activityManager?.didExitSuccesfully(activity: .export, userInfo: userInfo)
                    
                    let appBundle = projectDirectory.appBundle(archive: archive, name: export.distributionSummary.name)

                    let metadata = projectDirectory.metadata(project: project, location: location, configuration: configuration)
                    
                    let userInfo = userInfo.merging(["export": export, "metadata": metadata, "appBundle": appBundle], uniquingKeysWith: { (_, new) -> Any in
                        return new //shouldn't it be the new one? if not the appBundle doesn't make a difference.
                    })
                    
                    self.activityManager?.notify(notification: Windmill.Notifications.didExportProject, userInfo: userInfo)
                    
                    next?(userInfo)
                })
                self.activityManager?.didLaunch(activity: .export, userInfo: userInfo)
            }
        }
    }
}
