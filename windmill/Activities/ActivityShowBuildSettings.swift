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
    weak var activityManager: ActivityManager?
    
    func make(project: Project, location: Project.Location, scheme: String, buildSettings: BuildSettings) -> ActivitySuccess {
        
        return { next in

            return { context in

                let readBuildSettings = Process.makeShowBuildSettings(project: project, scheme: scheme, buildSettings: buildSettings, location: location)
                let userInfo: [AnyHashable : Any] = ["activity" : ActivityType.showBuildSettings]
                self.processManager?.launch(process: readBuildSettings, userInfo: userInfo, wasSuccesful: { userInfo in
                    
                    self.activityManager?.didExitSuccesfully(activity: ActivityType.showBuildSettings, userInfo: userInfo)
                    
                    let buildSettings = buildSettings.for(project: project.name)
                    
                    next?(["buildSettings": buildSettings])
                })
                self.activityManager?.didLaunch(activity: ActivityType.showBuildSettings, userInfo: userInfo)
            }
        }
    }
}
