//
//  Windmill.swift
//  windmill
//
//  Created by Markos Charatzas on 13/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation
import ObjectiveGit
import os


typealias WindmillProvider = () -> Windmill

/// domain is WindmillErrorDomain. code: WindmillErrorCode(s), has its userInfo set with NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey and NSUnderlyingErrorKey set

let WindmillErrorDomain : String = "io.windmill"
let XcodeBuildErrorDomain : String = "com.xcode.xcodebuild"

public struct WindmillStringKey : RawRepresentable, Equatable, Hashable {

    enum Test: String {
        case nothing
    }
    
    public static let test: WindmillStringKey = WindmillStringKey(rawValue: "io.windmill.windmill.key.test")!
    
    public static func ==(lhs: WindmillStringKey, rhs: WindmillStringKey) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    public typealias RawValue = String
    
    public var hashValue: Int {
        return self.rawValue.hashValue
    }
    
    public var rawValue: String
    
    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
}

/**
 
 In case on an error, Windmill will post a `Notifications.didError` notification with userInfo: ["error": error, "activity": activity])
 
 - SeeAlso: Windmill.Notifications
 - SeeAlso: ActivityType
 - SeeAlso: NSError+WindmillError
 */
class Windmill
/* final */
{
    class func make(project: Project, accountResource: AccountResource = AccountResource(), processManager: ProcessManager = ProcessManager()) -> Windmill {

        let configuration = Windmill.Configuration.make(project: project)
        let windmill = Windmill(configuration: configuration)
        
        let activityManager = ActivityManager(accountResource: accountResource, processManager: processManager)
        windmill.activityManager = activityManager
        
        return windmill
    }
    
    public struct Configuration {

        static func make(project: Project) -> Configuration {
            
            let applicationCachesDirectory = Directory.Windmill.ApplicationCachesDirectory()
            let applicationSupportDirectory = Directory.Windmill.ApplicationSupportDirectory()

            let projectDirectory: ProjectDirectory = FileManager.default.windmillDirectory.directory(for: project)
            let projectLogURL: URL = projectDirectory.log(name: "raw")
            let projectRepositoryDirectory: RepositoryDirectory = applicationCachesDirectory.respositoryDirectory(at: project.name)
            let derivedData: DerivedDataDirectory = applicationCachesDirectory.derivedData(at: project.name)
            
            return Configuration(applicationCachesDirectory: applicationCachesDirectory, applicationSupportDirectory: applicationSupportDirectory,projectDirectory: projectDirectory, projectLogURL: projectLogURL, projectRepositoryDirectory: projectRepositoryDirectory, derivedData: derivedData)
        }
        
        let applicationCachesDirectory: ApplicationCachesDirectory
        let applicationSupportDirectory: ApplicationSupportDirectory
        
        let projectDirectory: ProjectDirectory
        let projectLogURL: URL
        let projectRepositoryDirectory: RepositoryDirectory
        
        let derivedData: DerivedDataDirectory
    }
    
    struct Notifications {
        static let willStartProject = Notification.Name("will.start")
        static let didCheckoutProject = Notification.Name("io.windmill.windmill.activity.did.checkout")
        static let didBuildProject = Notification.Name("io.windmill.windmill.activity.did.build")
        static let didTestProject = Notification.Name("io.windmill.windmill.activity.did.test")
        static let didArchiveProject = Notification.Name("io.windmill.windmill.activity.did.archive")
        static let didExportProject = Notification.Name("io.windmill.windmill.activity.did.export")
        static let didPublishProject = Notification.Name("io.windmill.windmill.activity.did.publish")
        static let willMonitorProject = Notification.Name("io.windmill.windmill.activity.will.monitor")
        
        static let didError = Notification.Name("io.windmill.windmill.activity.did.error")
        
        static let activityDidLaunch = Notification.Name("io.windmill.windmill.activity..did.launch")
        static let activityDidExitSuccesfully = Notification.Name("io.windmill.windmill.activity..did.exit.succesfully")
        
    }
    
    let log = OSLog(subsystem: "io.windmill.windmill", category: "windmill")
    
    let configuration: Configuration
    var activityManager: ActivityManager? {
        didSet {
            activityManager?.windmill = self
        }
    }

    // MARK: init
    init(configuration: Configuration) {

        self.configuration = configuration
        NotificationCenter.default.addObserver(self, selector: #selector(devicesListed(_:)), name: ActivityManager.Notifications.DevicesListed, object: nil) //activity manager
    }
    
    @objc func devicesListed(_ notification: Notification) {
        if let destination = notification.userInfo?["destination"] as? Devices.Destination {
            Process.makeBoot(destination: destination).launch()
        }
    }
    
    // MARK: public
    func removeDerivedData() -> Bool {
        return self.configuration.derivedData.remove()
    }
    
    func isRepositoryDirectoryPresent() -> Bool {
        return self.configuration.projectRepositoryDirectory.exists()
    }
    
    func removeRepositoryDirectory() -> Bool {
        return self.configuration.projectRepositoryDirectory.remove()
    }
    
    func run(_ project: Project, skipCheckout: Bool = false, user: String? = try? Keychain.defaultKeychain().findWindmillUser()) {
        
        guard let activityManager = self.activityManager else {
            preconditionFailure("ActivityManager hasn't been set on Windmill. Did you call the setter?")
        }
        
        let activityBuiler = activityManager.builder(configuration: self.configuration, project: project)
        
        let activity: Activity

        if let user = user {
            activity = activityBuiler.repeatablePublish(activityManager: activityManager, user: user, skipCheckout: skipCheckout)
        }
        else {
            activity = activityBuiler.repeatableExport(activityManager: activityManager, skipCheckout: skipCheckout)
        }

        activity([:])
    }
}
