//
//  ActivityCheckout.swift
//  windmill
//
//  Created by Markos Charatzas on 08/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation
import os

struct ActivityCheckout {
    
    let log = OSLog(subsystem: "io.windmill.windmill", category: "activity")

    weak var processManager: ProcessManager?
    weak var delegate: ActivityDelegate?
    
    let projectLogURL: URL
    
    init(processManager: ProcessManager, projectLogURL: URL) {
        self.processManager = processManager
        self.projectLogURL = projectLogURL
    }
    
    func success(repositoryLocalURL: RepositoryDirectory, project: Project) -> SuccessfulActivity {
        
        return SuccessfulActivity { next in
            
            return { context in
                
                let checkout = Process.makeCheckout(sourceDirectory: repositoryLocalURL, project: project, log: self.projectLogURL)
                
                let userInfo: [AnyHashable : Any] = ["activity" : ActivityType.checkout]
                self.delegate?.willLaunch(activity: .checkout, userInfo: userInfo)
                self.processManager?.launch(process:checkout, userInfo: userInfo, wasSuccesful: { userInfo in
                    self.delegate?.didExitSuccesfully(activity: .checkout, userInfo: userInfo)

                    os_log("Checked out source under: '%{public}@'", log: self.log, type: .debug, repositoryLocalURL.URL.path)
                    
                    next?(["repositoryDirectory": repositoryLocalURL])
                })
                
                self.delegate?.didLaunch(activity: .checkout, userInfo: userInfo)
            }
        }
    }
}
