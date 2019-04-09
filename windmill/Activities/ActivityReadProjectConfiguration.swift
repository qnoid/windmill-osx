//
//  ActivityReadProjectConfiguration.swift
//  windmill
//
//  Created by Markos Charatzas on 08/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

struct ActivityReadProjectConfiguration {
    
    weak var processManager: ProcessManager?
    weak var activityManager: ActivityManager?

    func success(project: Project, configuration: Project.Configuration) -> ActivitySuccess {
     
        return { next in

            return { context in

                guard let location = context["location"] as? Project.Location else {
                    preconditionFailure("ActivityReadProjectConfiguration expects a `Project.Location` under the context[\"location\"] for a succesful callback")
                }

                let readProjectConfiguration = Process.makeListConfiguration(project: project, configuration: configuration, location: location)
                
                let userInfo: [AnyHashable : Any] = ["activity": ActivityType.readProjectConfiguration, "configuration": configuration]
                self.activityManager?.willLaunch(activity: .readProjectConfiguration, userInfo: userInfo)
                self.processManager?.launch(process: readProjectConfiguration, userInfo: userInfo, wasSuccesful: { userInfo in
                    
                    let scheme = configuration.detectScheme(name: project.scheme)
                    
                    self.activityManager?.didExitSuccesfully(activity: .readProjectConfiguration, userInfo: userInfo.merging(["scheme" : scheme], uniquingKeysWith: { (_, new) in new } ))
                    next?([:])
                })
                
                self.activityManager?.didLaunch(activity: .readProjectConfiguration, userInfo: userInfo)
            }
        }
    }
}
