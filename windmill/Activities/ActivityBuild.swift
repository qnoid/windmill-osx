//
//  ActivityBuild.swift
//  windmill
//
//  Created by Markos Charatzas on 08/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

struct ActivityBuild {
    
    let locations: Windmill.Locations
    
    weak var processManager: ProcessManager?
    weak var delegate: ActivityDelegate?
    
    let logfile: URL
    
    init(locations: Windmill.Locations, processManager: ProcessManager, logfile: URL) {
        self.locations = locations
        self.processManager = processManager
        self.logfile = logfile
    }

    private func wasSuccesful(userInfo: [AnyHashable : Any]?, derivedAppBundle: AppBundle, appBundle: AppBundle, project: Project, destination: Devices.Destination, next: Activity? = nil) -> ProcessSuccess {
        return { userInfo in

            self.delegate?.didExitSuccesfully(activity: .build, userInfo: userInfo)
            
            try? FileManager.default.copyItem(at: derivedAppBundle.url, to: appBundle.url)
            
            self.delegate?.notify(notification: Windmill.Notifications.didBuildProject, userInfo: ["project":project, "appBundle": appBundle, "destination": destination])
            
            next?(userInfo)
        }
    }
    
    func success(projectAt: Project.Location, project: Project, appBundle: AppBundle, configuration: Project.Configuration, home: ProjectDirectory, buildSettings: BuildSettings) -> SuccessfulActivity {
        
        return SuccessfulActivity { next in
            
            return { context in
                
                let derivedData = self.locations.derivedData
                let resultBundle = self.locations.buildResultBundle

                try? FileManager.default.removeItem(at: appBundle.url)
                let derivedAppBundle = derivedData.derivedAppBundle(name: buildSettings.product?.name ?? project.name)
                
                guard let destination = context["destination"] as? Devices.Destination else {
                    preconditionFailure("ActivityBuild expects a `Devices.Destination` under the context[\"destination\"] for a succesful callback")
                }
                
                let scheme = configuration.detectScheme(name: project.scheme)
                
                let buildForTesting = Process.makeBuildForTesting(projectAt: projectAt, project:project, scheme: scheme, destination: destination, derivedData: derivedData, resultBundle: resultBundle, log: self.logfile)
                
                let userInfo: [AnyHashable : Any] = ["activity" : ActivityType.build, "resultBundle" : resultBundle, "artefact" : ArtefactType.appBundle]
                
                let recover = RecoverableProcess.recover(terminationStatus: 66) { process in
                    
                    let build = Process.makeBuild(projectAt: projectAt, project:project, scheme: scheme, destination: destination, derivedData: derivedData, resultBundle: resultBundle, log: self.logfile)
                    
                    let wasSuccesful = self.wasSuccesful(userInfo: [WindmillStringKey.test: WindmillStringKey.Test.nothing], derivedAppBundle: derivedAppBundle, appBundle: appBundle, project: project, destination: destination, next: next)
                    
                    self.delegate?.willLaunch(activity: .build, userInfo: userInfo)
                    self.processManager?.launch(process: build, userInfo: ["activity" : ActivityType.build, "resultBundle": resultBundle, "artefact": ArtefactType.appBundle, WindmillStringKey.test: WindmillStringKey.Test.nothing], wasSuccesful: wasSuccesful)
                    self.delegate?.didLaunch(activity: .build, userInfo: userInfo)
                }
                
                let wasSuccesful = self.wasSuccesful(userInfo: [:], derivedAppBundle: derivedAppBundle, appBundle: appBundle, project: project, destination: destination, next: next)
                self.delegate?.willLaunch(activity: .build, userInfo: userInfo)
                self.processManager?.launch(process: buildForTesting, recover: recover, userInfo: userInfo, wasSuccesful: wasSuccesful)
                self.delegate?.didLaunch(activity: .build, userInfo: userInfo)
            }
        }
    }
}
