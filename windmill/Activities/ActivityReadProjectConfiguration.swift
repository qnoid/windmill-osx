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
    weak var delegate: ActivityDelegate?

    init(processManager: ProcessManager) {
        self.processManager = processManager
    }
    
    func success(project: Project, configuration: Project.Configuration) -> SuccessfulActivity {
     
        return SuccessfulActivity { next in

            return { context in

                guard let projectAt = context["projectAt"] as? Project.Location else {
                    preconditionFailure("ActivityReadProjectConfiguration expects a `Project.Location` under the context[\"projectAt\"] for a succesful callback")
                }

                let readProjectConfiguration = Process.makeListConfiguration(project: project, configuration: configuration, projectAt: projectAt)
                
                let userInfo: [AnyHashable : Any] = ["activity": ActivityType.readProjectConfiguration]
                self.delegate?.willLaunch(activity: .readProjectConfiguration, userInfo: userInfo)
                self.processManager?.launch(process: readProjectConfiguration, userInfo: userInfo, wasSuccesful: { userInfo in
                    
                    let scheme = configuration.detectScheme(name: project.scheme)
                    
                    let userInfo: [AnyHashable : Any] = ["activity": ActivityType.readProjectConfiguration, "configuration": configuration, "scheme" : scheme]
                    self.delegate?.didExitSuccesfully(activity: .readProjectConfiguration, userInfo: userInfo)
                    next?([:])
                })
                
                self.delegate?.didLaunch(activity: .readProjectConfiguration, userInfo: userInfo)
            }
        }
    }
}
