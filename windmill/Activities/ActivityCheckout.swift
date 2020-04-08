//
//  ActivityCheckout.swift
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
