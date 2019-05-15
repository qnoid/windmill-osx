//
//  ActivityBuild.swift
//  windmill
//
//  Created by Markos Charatzas on 08/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

struct ActivityBuild {
    
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

    private func wasSuccesful(userInfo: [AnyHashable : Any]?, appBundleBuilt: AppBundle, appBundle: AppBundle, project: Project, destination: Devices.Destination, next: Activity? = nil) -> ProcessSuccess {
        return { userInfo in

            self.delegate?.didExitSuccesfully(activity: .build, userInfo: userInfo)
            
            try? FileManager.default.copyItem(at: appBundleBuilt.url, to: appBundle.url)
            
            self.delegate?.notify(notification: Windmill.Notifications.didBuildProject, userInfo: ["project":project, "appBundle": appBundle, "destination": destination])
            
            next?(userInfo)
        }
    }
    
    func success(location: Project.Location, project: Project, appBundle: AppBundle, scheme: String, projectDirectory: ProjectDirectory, buildSettings: BuildSettings, derivedData: DerivedDataDirectory, resultBundle: ResultBundle) -> SuccessfulActivity {
        
        try? FileManager.default.removeItem(at: appBundle.url)
        
        let appBundleBuilt = projectDirectory.appBundle(derivedData: derivedData, name: buildSettings.product?.name ?? project.name)
        
        return SuccessfulActivity { next in
            
            return { context in
                
                guard let destination = context["destination"] as? Devices.Destination else {
                    preconditionFailure("ActivityBuild expects a `Devices.Destination` under the context[\"destination\"] for a succesful callback")
                }
                
                let buildForTesting = Process.makeBuildForTesting(location: location, project:project, scheme: scheme, destination: destination, derivedData: derivedData, resultBundle: resultBundle, log: self.projectLogURL)
                
                let userInfo: [AnyHashable : Any] = ["activity" : ActivityType.build, "resultBundle" : resultBundle, "artefact" : ArtefactType.appBundle]
                
                let recover = RecoverableProcess.recover(terminationStatus: 66) { process in
                    
                    let build = Process.makeBuild(location: location, project:project, scheme: scheme, destination: destination, derivedData: derivedData, resultBundle: resultBundle, log: self.projectLogURL)
                    
                    let wasSuccesful = self.wasSuccesful(userInfo: [WindmillStringKey.test: WindmillStringKey.Test.nothing], appBundleBuilt: appBundleBuilt, appBundle: appBundle, project: project, destination: destination, next: next)
                    
                    self.delegate?.willLaunch(activity: .build, userInfo: userInfo)
                    self.processManager?.launch(process: build, userInfo: ["activity" : ActivityType.build, "resultBundle": resultBundle, "artefact": ArtefactType.appBundle, WindmillStringKey.test: WindmillStringKey.Test.nothing], wasSuccesful: wasSuccesful)
                    self.delegate?.didLaunch(activity: .build, userInfo: userInfo)
                }
                
                let wasSuccesful = self.wasSuccesful(userInfo: [:], appBundleBuilt: appBundleBuilt, appBundle: appBundle, project: project, destination: destination, next: next)
                self.delegate?.willLaunch(activity: .build, userInfo: userInfo)
                self.processManager?.launch(process: buildForTesting, recover: recover, userInfo: userInfo, wasSuccesful: wasSuccesful)
                self.delegate?.didLaunch(activity: .build, userInfo: userInfo)
            }
        }
    }
    
    func success(location: Project.Location, project: Project, appBundle: AppBundle, scheme: String, projectDirectory: ProjectDirectory, buildSettings: BuildSettings) -> SuccessfulActivity {
        
        let derivedData = self.applicationCachesDirectory.derivedData(at: project.name)
        let resultBundle = self.applicationSupportDirectory.buildResultBundle(at: project.name)

        return success(location: location, project: project, appBundle: appBundle, scheme: scheme, projectDirectory: projectDirectory, buildSettings: buildSettings, derivedData: derivedData, resultBundle: resultBundle)
    }
}
