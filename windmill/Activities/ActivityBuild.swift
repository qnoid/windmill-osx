//
//  ActivityBuild.swift
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
