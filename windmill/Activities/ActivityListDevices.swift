//
//  ActivityListDevices.swift
//  windmill
//
//  Created by Markos Charatzas on 07/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

struct ActivityListDevices {
 
    weak var processManager: ProcessManager?
    weak var activityManager: ActivityManager?
    
    private func wasSuccesful(devices: Devices, next: Activity? = nil) -> ProcessSuccess {
        return { userInfo in
            
            self.activityManager?.didExitSuccesfully(activity: ActivityType.devices, userInfo: userInfo)
            
            guard let destination = devices.destination else {
                self.activityManager?.notify(notification: Windmill.Notifications.didError, userInfo: ["error": WindmillError.fatal(activityType: ActivityType.devices), "activity": ActivityType.devices])
                
                return
            }
            
            self.activityManager?.notify(notification: Windmill.Notifications.DevicesListed, userInfo: ["destination" : destination])
            next?(["destination" : destination])
        }
    }

    func success(devices: Devices) -> ActivitySuccess {

        return { next in

            return { context in
        
                guard let buildSettings = context["buildSettings"] as? BuildSettings else {
                    preconditionFailure("ActivityDevices expects a `BuildSettings` under the context[\"buildSettings\"] for a succesful callback")
                }

                let deployment = buildSettings.deployment
                
                let readDevices = Process.makeList(devices: devices, for: deployment)
                let wasSuccesful = self.wasSuccesful(devices: devices, next: next)

                let userInfo: [AnyHashable : Any] = ["activity" : ActivityType.devices, "devices": devices]
                self.activityManager?.willLaunch(activity: .devices, userInfo: userInfo)
                self.processManager?.launch(process: readDevices, recover: RecoverableProcess.recover(terminationStatus: 1, recover: { process in
                    
                    let readDevices = Process.makeList(devices: devices, for: deployment, xcode: .XCODE_10_1)
                    self.processManager?.launch(process: readDevices, userInfo: userInfo, wasSuccesful: wasSuccesful)
                    self.activityManager?.didLaunch(activity: .devices, userInfo: userInfo)
                }), userInfo: userInfo, wasSuccesful: wasSuccesful)
                self.activityManager?.didLaunch(activity: .devices, userInfo: userInfo)
            }
        }
    }
}
