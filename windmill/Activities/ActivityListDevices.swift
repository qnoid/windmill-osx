//
//  ActivityListDevices.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 07/03/2019.
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

struct ActivityListDevices {
 
    weak var processManager: ProcessManager?
    weak var delegate: ActivityDelegate?
    
    init(processManager: ProcessManager) {
        self.processManager = processManager
    }

    private func wasSuccesful(devices: Devices, next: Activity? = nil) -> ProcessSuccess {
        return { userInfo in
            
            self.delegate?.didExitSuccesfully(activity: ActivityType.devices, userInfo: userInfo)
            
            guard let destination = devices.destination else {
                self.delegate?.notify(notification: Windmill.Notifications.didError, userInfo: ["error": WindmillError.fatal(activityType: ActivityType.devices), "activity": ActivityType.devices])
                
                return
            }
            
            self.delegate?.notify(notification: Windmill.Notifications.DevicesListed, userInfo: ["destination" : destination])
            next?(["destination" : destination])
        }
    }

    func success(devices: Devices) -> SuccessfulActivity {

        return SuccessfulActivity { next in

            return { context in
        
                guard let buildSettings = context["buildSettings"] as? BuildSettings else {
                    preconditionFailure("ActivityDevices expects a `BuildSettings` under the context[\"buildSettings\"] for a succesful callback")
                }

                let deployment = buildSettings.deployment
                
                let readDevices = Process.makeList(devices: devices, for: deployment)
                let wasSuccesful = self.wasSuccesful(devices: devices, next: next)

                let userInfo: [AnyHashable : Any] = ["activity" : ActivityType.devices, "devices": devices]
                self.delegate?.willLaunch(activity: .devices, userInfo: userInfo)
                self.processManager?.launch(process: readDevices, recover: RecoverableProcess.recover(terminationStatus: 1, recover: { process in
                    
                    let readDevices = Process.makeList(devices: devices, for: deployment, xcode: .XCODE_10_1)
                    self.processManager?.launch(process: readDevices, userInfo: userInfo, wasSuccesful: wasSuccesful)
                    self.delegate?.didLaunch(activity: .devices, userInfo: userInfo)
                }), userInfo: userInfo, wasSuccesful: wasSuccesful)
                self.delegate?.didLaunch(activity: .devices, userInfo: userInfo)
            }
        }
    }
}
