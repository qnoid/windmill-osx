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
    weak var activityManager: ActivityManager?
    
    let projectLogURL: URL
    
    func success(repositoryLocalURL: RepositoryDirectory, project: Project) -> ActivitySuccess {
        
        return { next in
            
            return { context in
                
                let checkout = Process.makeCheckout(sourceDirectory: repositoryLocalURL, project: project, log: self.projectLogURL)
                
                let userInfo: [AnyHashable : Any] = ["activity" : ActivityType.checkout]
                self.activityManager?.willLaunch(activity: .checkout, userInfo: userInfo)
                self.processManager?.launch(process:checkout, userInfo: userInfo, wasSuccesful: { userInfo in
                    self.activityManager?.didExitSuccesfully(activity: .checkout, userInfo: userInfo)

                    os_log("Checked out source under: '%{public}@'", log: self.log, type: .debug, repositoryLocalURL.URL.path)
                    
                    next?(["repositoryDirectory": repositoryLocalURL])
                })
                
                self.activityManager?.didLaunch(activity: .checkout, userInfo: userInfo)
            }
        }
    }
}
