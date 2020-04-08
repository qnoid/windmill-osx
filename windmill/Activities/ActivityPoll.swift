//
//  ActivityPoll.swift
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
