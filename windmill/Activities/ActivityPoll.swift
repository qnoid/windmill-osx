//
//  ActivityPoll.swift
//  windmill
//
//  Created by Markos Charatzas on 08/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

struct ActivityPoll {
    
    weak var processManager: ProcessManager?
    weak var activityManager: ActivityManager?
    
    func make(project: Project, branch: String, repository: RepositoryDirectory, pollDirectoryURL: URL, do: DispatchWorkItem) -> Activity {
        
        return { context in
            
            #if DEBUG
            let delayInSeconds:Int = 5
            #else
            let delayInSeconds:Int = 30
            #endif
            
            self.processManager?.repeat(process: { return Process.makePoll(repositoryLocalURL: repository.URL, pollDirectoryURL: pollDirectoryURL, branch: branch) } , every: .seconds(delayInSeconds), untilTerminationStatus: 1, then: DispatchWorkItem {
                `do`.perform()
            })
            
            self.activityManager?.notify(notification: Windmill.Notifications.isMonitoring, userInfo: ["project":project, "branch":branch])
        }
    }
}
