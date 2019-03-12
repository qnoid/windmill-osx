//
//  Activity.swift
//  windmill
//
//  Created by Markos Charatzas on 08/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation
import os


typealias ActivityContext = [AnyHashable : Any]
typealias ActivitySuccess = (_ next: Activity?) -> Activity
typealias Activity = (_ context:ActivityContext) -> Swift.Void 

class ActivityManager: ProcessMonitor {
    
    struct Notifications {
        static let DevicesListed = Notification.Name("io.windmill.windmill.activity.devices.listed")
    }

    let log = OSLog(subsystem: "io.windmill.windmill", category: "activity")
    let notificationCenter = NotificationCenter.default

    let accountResource: AccountResource
    let processManager: ProcessManager

    weak var windmill: Windmill?

    init(accountResource: AccountResource, processManager: ProcessManager) {
        self.accountResource = accountResource
        self.processManager = processManager
        self.processManager.monitor = self
    }
    
    func didLaunch(activity: ActivityType, userInfo: [AnyHashable : Any]? = nil) {
        os_log("activity did launch `%{public}@`", log: log, type: .debug, activity.rawValue)
    
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Windmill.Notifications.activityDidLaunch, object: self.windmill, userInfo: userInfo)
        }
    }

    func didExitSuccesfully(activity: ActivityType, userInfo: [AnyHashable : Any]? = nil) {
        os_log("activity did exit success `%{public}@`", log: log, type: .debug, activity.rawValue)

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Windmill.Notifications.activityDidExitSuccesfully, object: self.windmill, userInfo: userInfo)
        }
    }

    func post(notification name: Notification.Name, object anObject: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: name, object: anObject ?? self.windmill, userInfo: userInfo)
        }
    }
    
    func didTerminate(manager: ProcessManager, process: Process, status: Int32, userInfo: [AnyHashable : Any]?) {
        
        guard let activity = userInfo?["activity"] as? ActivityType else {
            return
        }
        
        let error: NSError = NSError.errorTermination(process: process, for: activity, status: status)
        
        os_log("activity '%{public}@' did error: %{public}@", log: log, type: .error, error)
        
        guard let resultBundle = userInfo?["resultBundle"] as? ResultBundle, FileManager.default.fileExists(atPath: resultBundle.url.path) else {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Windmill.Notifications.didError, object: self.windmill, userInfo: userInfo?.merging(["error": error, "activity": activity], uniquingKeysWith:  { (userInfo, _) -> Any in
                    return userInfo
                }))
            }
            return
        }
        
        let info = resultBundle.info
        
        if info.errorCount == 0, info.testsFailedCount == 0 {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Windmill.Notifications.didError, object: self.windmill, userInfo: userInfo?.merging(["error": error, "activity": activity], uniquingKeysWith:  { (userInfo, _) -> Any in
                    return userInfo
                }))
            }
            return
        }
        
        if info.errorCount > 0 {
            DispatchQueue.main.async { [errorCount = info.errorCount] in
                
                let error = NSError.activityError(underlyingError: error, for: activity, status: process.terminationStatus, info: info)
                
                NotificationCenter.default.post(name: Windmill.Notifications.didError, object: self.windmill, userInfo: userInfo?.merging(["error": error, "activity": activity, "errorCount":errorCount, "errorSummaries": info.errorSummaries], uniquingKeysWith: { (userInfo, _) -> Any in
                    return userInfo
                }))
            }
        }
        
        if let testsFailedCount = info.testsFailedCount, testsFailedCount > 0 {
            DispatchQueue.main.async { [testableSummaries = resultBundle.testSummaries?.testableSummaries] in
                let error = NSError.testError(underlyingError: error, status: process.terminationStatus, info: info)
                
                NotificationCenter.default.post(name: Windmill.Notifications.didError, object: self.windmill, userInfo: userInfo?.merging(["error": error, "activity": activity, "testsFailedCount":testsFailedCount, "testFailureSummaries": info.testFailureSummaries, "testableSummaries": testableSummaries ?? []], uniquingKeysWith: { (userInfo, _) -> Any in
                    return userInfo
                }))
            }
        }
    }
    
    // MARK: public
    func builder(configuration: Windmill.Configuration, project: Project) -> ActivityBuiler {
        return ActivityBuiler(configuration: configuration, project: project, accountResource: self.accountResource, processManager: self.processManager)
    }
}
