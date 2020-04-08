//
//  ActivityArchive.swift
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

struct ActivityArchive {
    
    let locations: Windmill.Locations

    weak var processManager: ProcessManager?
    weak var delegate: ActivityDelegate?
    
    let logfile: URL
    
    init(locations: Windmill.Locations, processManager: ProcessManager, logfile: URL) {
        self.locations = locations
        self.processManager = processManager
        self.logfile = logfile
    }
    
    func success(projectAt: Project.Location, project: Project, configuration: Project.Configuration, build: Configuration) -> SuccessfulActivity {
        
        return SuccessfulActivity { next in
            
            return { context in
                
                let derivedData = self.locations.derivedData
                let resultBundle = self.locations.archiveResultBundle
                
                let scheme = configuration.detectScheme(name: project.scheme)
                let archive = self.locations.home.archive(name: scheme)
                
                let makeArchive = Process.makeArchive(projectAt: projectAt, project: project, scheme: scheme, derivedData: derivedData, archive: archive, configuration: build, resultBundle: resultBundle, log: self.logfile)

                let userInfo: [AnyHashable : Any] = ["activity" : ActivityType.archive, "artefact": ArtefactType.archiveBundle, "archive": archive, "resultBundle": resultBundle]
                self.delegate?.willLaunch(activity: .archive, userInfo: userInfo)
                self.processManager?.launch(process: makeArchive, userInfo: userInfo, wasSuccesful: { userInfo in
                    
                    self.delegate?.didExitSuccesfully(activity: .archive, userInfo: userInfo)
                    
                    self.delegate?.notify(notification: Windmill.Notifications.didArchiveProject, userInfo: ["project":project, "archive": archive])
                    
                    next?(["archive":archive])
                })
                self.delegate?.didLaunch(activity: .archive, userInfo: userInfo)
            }
        }
    }
}
