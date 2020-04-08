//
//  ActivityReadProjectConfiguration.swift
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
