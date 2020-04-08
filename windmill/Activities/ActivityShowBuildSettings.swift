//
//  ActivityShowBuildSettings.swift
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

struct ActivityShowBuildSettings {
    
    weak var processManager: ProcessManager?
    weak var delegate: ActivityDelegate?
    
    init(processManager: ProcessManager) {
        self.processManager = processManager
    }
    
    func success(project: Project, projectAt: Project.Location, configuration: Project.Configuration, buildSettings: BuildSettings) -> SuccessfulActivity {
        
        return SuccessfulActivity { next in

            return { context in

                let scheme = configuration.detectScheme(name: project.scheme)
                let readBuildSettings = Process.makeShowBuildSettings(project: project, scheme: scheme, buildSettings: buildSettings, projectAt: projectAt)
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
