//
//  ActivityTest.swift
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

struct ActivityTest {

    let locations: Windmill.Locations

    weak var processManager: ProcessManager?
    weak var delegate: ActivityDelegate?
    
    let logfile: URL
    
    init(locations: Windmill.Locations, processManager: ProcessManager, logfile: URL) {
        self.locations = locations
        self.processManager = processManager
        self.logfile = logfile
    }

    func success(projectAt: Project.Location, project: Project, devices: Devices, configuration: Project.Configuration) -> SuccessfulActivity {
        
        return SuccessfulActivity { next in
            
            return { context in
             
                let derivedData = self.locations.derivedData
                let resultBundle = self.locations.testResultBundle
                
                guard let destination = devices.destination else {
                    preconditionFailure("Destination must not be nil to proceeed. Did you use `ActivityDevices` to read the list of devices?")
                }
                
                let test: Process
                let userInfo: [AnyHashable: Any]
                let scheme = configuration.detectScheme(name: project.scheme)
                
                if WindmillStringKey.Test.nothing == (context[WindmillStringKey.test] as? WindmillStringKey.Test) {
                    test = Process.makeSuccess() //no need to go through the process manager now, simply fire the notification for when an activity succeeds
                    userInfo = ["activity" : ActivityType.test, "resultBundle": resultBundle]
                } else {
                    userInfo = ["activity" : ActivityType.test, "artefact": ArtefactType.testReport, "devices": devices, "destination": destination, "resultBundle": resultBundle]
                    test = Process.makeTestWithoutBuilding(projectAt: projectAt, project: project, scheme: scheme, destination: destination, derivedData: derivedData, resultBundle: resultBundle, log: self.logfile)
                }
                
                self.delegate?.willLaunch(activity: .test, userInfo: userInfo)
                self.processManager?.launch(process: test, userInfo: userInfo, wasSuccesful: { userInfo in
                    
                    self.delegate?.didExitSuccesfully(activity: .test, userInfo: userInfo)
                    
                    if let testsCount = resultBundle.info.testsCount, testsCount >= 0 {
                        self.delegate?.notify(notification: Windmill.Notifications.didTestProject, userInfo: ["project":project, "devices": devices, "destination": destination, "testsCount": testsCount, "testableSummaries": resultBundle.testSummaries?.testableSummaries ?? []])
                    }

                    next?([:])
                })
                self.delegate?.didLaunch(activity: .test, userInfo: userInfo)
            }
        }
    }
}
