//
//  Activity.swift
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

protocol ActivityManagerDelegate: class {
    func will(_ manager: ActivityManager, launch activity: ActivityType, userInfo: [AnyHashable : Any]?)
    func did(_ manager: ActivityManager, launch activity: ActivityType, userInfo: [AnyHashable : Any]?)
    func did(_ manager: ActivityManager, exitSuccesfully activity: ActivityType, userInfo: [AnyHashable : Any]?)
    func did(_ manager: ActivityManager, terminate activity: ActivityType, error: Error, userInfo: [AnyHashable : Any]?)
}

extension ActivityManagerDelegate {
    
    func will(_ manager: ActivityManager, launch activity: ActivityType, userInfo: [AnyHashable : Any]?) {
        
    }
    
    func did(_ manager: ActivityManager, launch activity: ActivityType, userInfo: [AnyHashable : Any]?) {
        
    }
    
    func did(_ manager: ActivityManager, exitSuccesfully activity: ActivityType, userInfo: [AnyHashable : Any]?) {
        
    }
    
    func did(_ manager: ActivityManager, terminate activity: ActivityType, error: Error, userInfo: [AnyHashable : Any]?) {
        
    }
}

infix operator -->: AssignmentPrecedence

typealias ActivityContext = [AnyHashable : Any]
typealias Activity = (_ context:ActivityContext) -> Swift.Void

struct SuccessfulActivity {
    let success: (_ next: Activity?) -> Activity
    
    func call(_ next: Activity?) -> Activity {
        return success(next)
    }
}

extension SuccessfulActivity {
    static func --> (success: SuccessfulActivity, next: @escaping Activity) -> Activity {
        return success.call(next)
    }
}

protocol ActivityDelegate: class {
    
    func willLaunch(activity: ActivityType, userInfo: [AnyHashable : Any]?)
    func didLaunch(activity: ActivityType, userInfo: [AnyHashable : Any]?)
    func didExitSuccesfully(activity: ActivityType, userInfo: [AnyHashable : Any]?)
    func did(terminate activity: ActivityType, error: Error, userInfo: [AnyHashable : Any]?)
    func notify(notification name: Notification.Name, userInfo: [AnyHashable : Any]?)
}

class ActivityManager: ProcessMonitor, ActivityDelegate {
    
    let log = OSLog(subsystem: "io.windmill.windmill", category: "activity")
    let notificationCenter = NotificationCenter.default
    
    let processManager: ProcessManager
    unowned var subscriptionManager: SubscriptionManager

    let queue = DispatchQueue(label: "io.windmill.activity.queue")
    let activitiesGroup = DispatchGroup()
    
    weak var windmill: Windmill? {
        didSet {
            NotificationCenter.default.addObserver(self, selector: #selector(willRun(_:)), name: Windmill.Notifications.willRun, object: windmill)
            NotificationCenter.default.addObserver(self, selector: #selector(didExportProject(_:)), name: Windmill.Notifications.didExportProject, object: windmill)
        }
    }
    
    weak var delegate: ActivityManagerDelegate?

    init(subscriptionManager: SubscriptionManager, processManager: ProcessManager = ProcessManager()) {
        self.subscriptionManager = subscriptionManager
        self.processManager = processManager
        self.processManager.monitor = self
    }
    
    @objc func willRun(_ aNotification: Notification) {
        self.activitiesGroup.enter()
    }
    
    @objc func didExportProject(_ aNotification: Notification) {
        activitiesGroup.leave()
    }
    
    func willLaunch(activity: ActivityType, userInfo: [AnyHashable : Any]?) {
        if activity == .distribute {
            self.activitiesGroup.wait()
        }

        os_log("activity will launch `%{public}@`", log: log, type: .debug, activity.rawValue)
        
        self.delegate?.will(self, launch: activity, userInfo: userInfo)
    }
    
    func didLaunch(activity: ActivityType, userInfo: [AnyHashable : Any]?) {
        os_log("activity did launch `%{public}@`", log: log, type: .debug, activity.rawValue)
        self.activitiesGroup.enter()

        self.delegate?.did(self, launch: activity, userInfo: userInfo)
    }

    func didExitSuccesfully(activity: ActivityType, userInfo: [AnyHashable : Any]?) {
        os_log("activity did exit success `%{public}@`", log: log, type: .debug, activity.rawValue)
        self.activitiesGroup.leave()
        
        self.delegate?.did(self, exitSuccesfully: activity, userInfo: userInfo)
    }

    func did(terminate activity: ActivityType, error: Error, userInfo: [AnyHashable : Any]?) {
        self.delegate?.did(self, terminate: activity, error: error, userInfo: userInfo)
    }

    func notify(notification name: Notification.Name, userInfo: [AnyHashable : Any]? = nil) {
        self.windmill?.notify(notification: name, userInfo: userInfo)
    }

    func didTerminate(manager: ProcessManager, process: Process, status: Int32, userInfo: [AnyHashable : Any]?) {
        
        guard let activity = userInfo?["activity"] as? ActivityType else {
            return
        }
        
        let error: NSError = NSError.errorTermination(process: process, for: activity, status: status)
        
        os_log("activity '%{public}@' did error: %{public}@", log: log, type: .error, error)
        
        guard let resultBundle = userInfo?["resultBundle"] as? ResultBundle, FileManager.default.fileExists(atPath: resultBundle.url.path) else {
            self.did(terminate: activity, error: error, userInfo: userInfo?.merging(["error": error, "activity": activity], uniquingKeysWith:  { (userInfo, _) -> Any in
                return userInfo
            }))
            return
        }
        
        let info = resultBundle.info
        
        if info.errorCount == 0, info.testsFailedCount == 0 {
            self.did(terminate: activity, error: error, userInfo: userInfo?.merging(["error": error, "activity": activity], uniquingKeysWith:  { (userInfo, _) -> Any in
                return userInfo
            }))
            return
        }
        
        if info.errorCount > 0 {
            let error = NSError.activityError(underlyingError: error, for: activity, status: process.terminationStatus, info: info)

            self.did(terminate: activity, error: error, userInfo: userInfo?.merging(["error": error, "activity": activity, "errorCount":info.errorCount, "errorSummaries": info.errorSummaries], uniquingKeysWith: { (userInfo, _) -> Any in
                return userInfo
            }))
        }
        
        if let testsFailedCount = info.testsFailedCount, testsFailedCount > 0 {
            let error = NSError.testError(underlyingError: error, status: process.terminationStatus, info: info)
            let testableSummaries = resultBundle.testSummaries?.testableSummaries
            self.did(terminate: activity, error: error, userInfo: userInfo?.merging(["error": error, "activity": activity, "testsFailedCount":testsFailedCount, "testFailureSummaries": info.testFailureSummaries, "testableSummaries": testableSummaries ?? []], uniquingKeysWith: { (userInfo, _) -> Any in
                return userInfo
            }))
        }
    }
    
    // MARK: public
    func builder(configuration: Windmill.Configuration, locations: Windmill.Locations) -> ActivityBuiler {
        return ActivityBuiler(configuration: configuration, locations: locations, subscriptionManager: self.subscriptionManager, processManager: self.processManager)
    }
    
    func distribute(configuration: Windmill.Configuration, locations: Windmill.Locations, standardOutFormattedWriter: StandardOutFormattedWriter, account: Account, authorizationToken: SubscriptionAuthorizationToken) {
        let activityBuiler = self.builder(configuration: configuration, locations: locations)
        let activityDistribute = activityBuiler.distributeActivity(standardOutFormattedWriter: standardOutFormattedWriter)
        activityDistribute.delegate = self
        
        let distribute = activityDistribute.make(queue: self.queue, account: account, authorizationToken: authorizationToken)
        distribute(ActivityDistribute.Context.make(locations: locations, configuration: configuration))
    }
}
