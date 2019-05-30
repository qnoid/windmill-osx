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
    
    let logfile: URL
    
    init(processManager: ProcessManager, logfile: URL) {
        self.processManager = processManager
        self.logfile = logfile
    }
    
    func success(repository: RepositoryDirectory, project: Project, branch: String = "master") -> SuccessfulActivity {
        
        return SuccessfulActivity { next in
            
            return { context in
                
                let checkout = Process.makeCheckout(sourceDirectory: repository, project: project, branch: branch, log: self.logfile)
                
                let userInfo: [AnyHashable : Any] = ["activity" : ActivityType.checkout]
                self.delegate?.willLaunch(activity: .checkout, userInfo: userInfo)
                self.processManager?.launch(process:checkout, userInfo: userInfo, wasSuccesful: { userInfo in
                    self.delegate?.didExitSuccesfully(activity: .checkout, userInfo: userInfo)

                    os_log("Checked out source under: '%{public}@'", log: self.log, type: .debug, repository.URL.path)
                    
                    next?(["repository": repository])
                })
                
                self.delegate?.didLaunch(activity: .checkout, userInfo: userInfo)
            }
        }
    }
}
