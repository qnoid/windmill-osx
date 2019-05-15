//
//  ActivityShowBuildSettings.swift
//  windmill
//
//  Created by Markos Charatzas on 08/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

struct ActivityShowBuildSettings {
    
    weak var processManager: ProcessManager?
    weak var delegate: ActivityDelegate?
    
    init(processManager: ProcessManager) {
        self.processManager = processManager
    }
    
    func success(project: Project, location: Project.Location, scheme: String, buildSettings: BuildSettings) -> SuccessfulActivity {
        
        return SuccessfulActivity { next in

            return { context in

                let readBuildSettings = Process.makeShowBuildSettings(project: project, scheme: scheme, buildSettings: buildSettings, location: location)
                let userInfo: [AnyHashable : Any] = ["activity" : ActivityType.showBuildSettings]
                self.delegate?.willLaunch(activity: .showBuildSettings, userInfo: userInfo)
                self.processManager?.launch(process: readBuildSettings, userInfo: userInfo, wasSuccesful: { userInfo in
                    
                    self.delegate?.didExitSuccesfully(activity: .showBuildSettings, userInfo: userInfo)
                    
                    let buildSettings = buildSettings.for(project: project.name)
                    
                    next?(["buildSettings": buildSettings])
                })
                self.delegate?.didLaunch(activity: .showBuildSettings, userInfo: userInfo)
            }
        }
    }
}
