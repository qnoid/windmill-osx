//
//  ActivityExport.swift
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

struct ActivityExport {
    
    let locations: Windmill.Locations
    
    weak var processManager: ProcessManager?
    weak var delegate: ActivityDelegate?

    let logfile: URL
    
    init(locations: Windmill.Locations, processManager: ProcessManager, logfile: URL) {
        self.locations = locations
        self.processManager = processManager
        self.logfile = logfile
    }

    func success(projectAt: Project.Location, project: Project, appBundle: AppBundle, configuration: Project.Configuration, build: Configuration, exportDirectoryURL: URL) -> SuccessfulActivity {
        
        return SuccessfulActivity { next in
            
            return { [home = self.locations.home] context in
            
                let resultBundle = self.locations.exportResultBundle
                
                guard let archive = context["archive"] as? Archive else {
                    preconditionFailure("ActivityExport expects a `Archive` under the context[\"archive\"] for a succesful callback")
                }
                let makeExport = Process.makeExport(projectAt: projectAt, archive: archive, exportDirectoryURL: exportDirectoryURL, resultBundle: resultBundle, log: self.logfile)

                let scheme = configuration.detectScheme(name: project.scheme)
                let export = home.export(name: scheme)

                let userInfo: [AnyHashable : Any] = ["activity" : ActivityType.export, "project":project, "artefact": ArtefactType.ipaFile, "export": export, "appBundle": appBundle, "resultBundle": resultBundle]
                self.delegate?.willLaunch(activity: .export, userInfo: userInfo)
                self.processManager?.launch(process: makeExport, userInfo: userInfo, wasSuccesful: { userInfo in
                    
                    self.delegate?.didExitSuccesfully(activity: .export, userInfo: userInfo)
                    
                    let metadata = home.metadata(project: project, projectAt: projectAt, configuration: build, applicationProperties: appBundle.info)
                    
                    self.delegate?.notify(notification: Windmill.Notifications.didExportProject, userInfo: ["export": export, "metadata": metadata, "appBundle": appBundle])
                    
                    next?(userInfo)
                })
                self.delegate?.didLaunch(activity: .export, userInfo: userInfo)
            }
        }
    }
}
