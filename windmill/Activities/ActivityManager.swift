//
//  Activity.swift
//  windmill
//
//  Created by Markos Charatzas on 08/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
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

typealias ActivityContext = [AnyHashable : Any]
typealias ActivitySuccess = (_ next: Activity?) -> Activity
typealias Activity = (_ context:ActivityContext) -> Swift.Void 

class ActivityManager: ProcessMonitor {
    
    let log = OSLog(subsystem: "io.windmill.windmill", category: "activity")
    let notificationCenter = NotificationCenter.default
    
    let processManager: ProcessManager
    unowned var subscriptionManager: SubscriptionManager

    weak var windmill: Windmill?
    weak var delegate: ActivityManagerDelegate?

    init(subscriptionManager: SubscriptionManager, processManager: ProcessManager) {
        self.subscriptionManager = subscriptionManager
        self.processManager = processManager
        self.processManager.monitor = self
    }
    
    func willLaunch(activity: ActivityType, userInfo: [AnyHashable : Any]? = nil) {
        os_log("activity will launch `%{public}@`", log: log, type: .debug, activity.rawValue)
        self.delegate?.will(self, launch: activity, userInfo: userInfo)
    }
    
    func didLaunch(activity: ActivityType, userInfo: [AnyHashable : Any]? = nil) {
        os_log("activity did launch `%{public}@`", log: log, type: .debug, activity.rawValue)
    
        self.delegate?.did(self, launch: activity, userInfo: userInfo)
    }

    func didExitSuccesfully(activity: ActivityType, userInfo: [AnyHashable : Any]? = nil) {
        os_log("activity did exit success `%{public}@`", log: log, type: .debug, activity.rawValue)

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
    func builder(configuration: Windmill.Configuration) -> ActivityBuiler {
        return ActivityBuiler(configuration: configuration, subscriptionManager: self.subscriptionManager, processManager: self.processManager)
    }
}
