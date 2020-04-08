//
//  Windmill.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 13/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import AppKit
import ObjectiveGit
import os
import CloudKit


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

extension AppBundle {
    static func make(home: ProjectDirectory, project: Project) -> AppBundle {
        return home.appBundle(name: project.name)
    }

    static func make(home: ProjectDirectory, archive: Archive, distributionSummary: DistributionSummary) -> AppBundle {
        return home.archivedAppBundle(archive: archive, name: distributionSummary.name)
    }
}

extension Archive {
    
    static func make(home: ProjectDirectory, configuration: Windmill.Configuration) -> Archive {
        let scheme = home.configuration().detectScheme(name: configuration.project.scheme)
        return home.archive(name: scheme)
    }
}

extension Export {
    
    static func make(home: ProjectDirectory, configuration: Windmill.Configuration) -> Export {
        let scheme = home.configuration().detectScheme(name: configuration.project.scheme)
        return home.export(name: scheme)
    }
}

extension Export.Metadata {
    
    static func make(home: ProjectDirectory, projectAt: Project.Location, configuration: Windmill.Configuration, applicationProperties: AppBundle.Info) -> Export.Metadata {
        return home.metadata(project: configuration.project, projectAt: projectAt, configuration: .release, applicationProperties: applicationProperties)
    }
}

extension Set where Element == Windmill.Configuration {
    
    @discardableResult mutating func write(_ configuration: Windmill.Configuration) -> Bool {
        let inserted = self.insert(configuration).inserted
        
        if inserted {
            Windmill.Configuration.write(self)
        }
        
        return inserted
    }
    
    mutating func delete(_ configuration: Windmill.Configuration) {
        self.remove(configuration)
        Windmill.Configuration.write(self)
    }
    
    func contains(_ project: Project, branch: String) -> Bool {
        return self.contains(where: { configuration in
            return configuration.project == project && configuration.branch == branch
        })
    }
}

/**
 
 A Windmill instance shouldn't be reused.
 When an error occurs, the instance of Windmill must be discarded.
 
 In case on an error, Windmill will post a `Notifications.didError` notification with userInfo: ["error": error, "activity": activity])
 
 - SeeAlso: Windmill.Notifications
 - SeeAlso: ActivityType
 - SeeAlso: NSError+WindmillError
 */
class Windmill: ActivityManagerDelegate, ActivityDelegate
/* final */
{
    class func make(project: Project, subscriptionManager: SubscriptionManager = SubscriptionManager(), processManager: ProcessManager = ProcessManager()) -> Windmill {

        let configuration = Windmill.Configuration.make(project: project)
        let locations = Windmill.Locations.make(project: project)
        let windmill = Windmill(configuration: configuration, locations: locations, subscriptionManager: subscriptionManager)
        
        let activityManager = ActivityManager(subscriptionManager: subscriptionManager, processManager: processManager)
        windmill.activityManager = activityManager
        
        return windmill
    }
    
    class func make(configuration: Configuration, subscriptionManager: SubscriptionManager = SubscriptionManager(), processManager: ProcessManager = ProcessManager()) -> Windmill {
    
        let locations: Locations
        if configuration.branch == "master" {
            locations = Windmill.Locations.make(project: configuration.project)
        } else {
            locations = Windmill.Locations.make(project: configuration.project, branch: configuration.branch)
        }
        
        let windmill = Windmill(configuration: configuration, locations: locations, subscriptionManager: subscriptionManager)
        
        let activityManager = ActivityManager(subscriptionManager: subscriptionManager, processManager: processManager)
        windmill.activityManager = activityManager
        
        return windmill
    }
    
    public struct Locations {
        
        static func make(project: Project) -> Locations {
            
            let windmill = FileManager.default.windmillDirectory
            let caches = Directory.Windmill.ApplicationCachesDirectory()
            let support = Directory.Windmill.ApplicationSupportDirectory()
            
            let home = windmill.directory(for: project)
            
            let sources = caches.sources()
            let repository = caches.respositoryDirectory(at: sources, pathComponent: project.name)
            
            let derivedData = caches.derivedData(pathComponent: project.name)
            
            let resultBundleDirectory = support.resultBundleDirectory()
            let logfile = home.log(name: "raw")
            
            return Locations(project: project, home: home, repository: repository, sources: sources, derivedData: derivedData, resultBundleDirectory: resultBundleDirectory, logfile: logfile)
        }
        
        static func make(project: Project, branch: String) -> Locations {
            
            precondition(branch != "master")
            
            let windmill = FileManager.default.windmillDirectory
            let caches = Directory.Windmill.ApplicationCachesDirectory()
            let support = Directory.Windmill.ApplicationSupportDirectory()
            
            let home = windmill.directory(for: project).builds().directory(at: branch)
            
            let sources = caches.sources(at: caches.builds()).directory(for: project).directory(at: branch)
            let repository = caches.respositoryDirectory(at: sources, pathComponent: project.name)
            
            let derivedData = caches.derivedData(at: caches.builds()).directory(for: project).directory(at: branch)
            
            let resultBundleDirectory = support.resultBundleDirectory(at: support.builds())
            let logfile = home.log(name: "raw")

            return Locations(project: project, home: home, repository: repository, sources: sources, derivedData: derivedData, resultBundleDirectory: resultBundleDirectory, logfile: logfile)
        }

        private let project: Project
        
        let home: ProjectDirectory
        
        let repository: RepositoryDirectory
        var projectAt: Project.Location { return self.repository.location(project: self.project) }

        let sources: Directory
        let derivedData: DerivedDataDirectory
        
        let resultBundleDirectory: ResultBundleDirectory
        var buildResultBundle: ResultBundle { return self.resultBundleDirectory.buildResultBundle(at: self.project.name) }
        var testResultBundle: ResultBundle { return self.resultBundleDirectory.testResultBundle(at: self.project.name) }
        var archiveResultBundle: ResultBundle { return self.resultBundleDirectory.archiveResultBundle(at: self.project.name) }
        var exportResultBundle: ResultBundle {  return self.resultBundleDirectory.exportResultBundle(at: self.project.name) }

        let logfile: URL
    }
    
    public struct Configuration: Codable, Equatable, Hashable {

        static func make(project: Project) -> Configuration {
            return make(project: project, branch: "master", activities: [.checkout, .build, .test, .archive, .export, .distribute])
        }

        static func make(project: Project, branch: String, activities: [ActivityType]) -> Configuration {
            return Configuration(project: project, branch: branch, activities: activities)
        }
        
        static func read(url: URL = Directory.Windmill.ApplicationSupportDirectory().file("configurations.json").URL) -> Set<Configuration>
        {
            do
            {
                let decoder = JSONDecoder()
                let data = try Data(contentsOf: url)
                return try decoder.decode(Set<Configuration>.self, from: data)
            } catch let error as NSError {
                os_log("%{public}@", log: .default, type: .error, error)
                return []
            }
        }

        static func write(_ projects: Set<Configuration>, url: URL = Directory.Windmill.ApplicationSupportDirectory().file("configurations.json").URL)
        {
            let encoder = JSONEncoder()
            
            do {
                let data = try encoder.encode(projects)
                try data.write(to: url, options: .atomic)
            } catch {
                os_log("%{errorno}@", log: .default, type: .error, error.localizedDescription)
            }
        }
        
        static var shared : Set<Windmill.Configuration> = Windmill.Configuration.read()

        let project: Project
        let branch: String
        let activities: [ActivityType]
        
        init(project: Project, branch: String, activities: [ActivityType]) {
            self.project = project
            self.branch = branch
            self.activities = activities
        }
    }
    
    struct Notifications {
        static let willRun = Notification.Name("io.windmill.windmill.will.run")
        static let didRun = Notification.Name("io.windmill.windmill.did.run")
        static let didCheckoutProject = Notification.Name("io.windmill.windmill.activity.did.checkout")
        static let didBuildProject = Notification.Name("io.windmill.windmill.activity.did.build")
        static let didTestProject = Notification.Name("io.windmill.windmill.activity.did.test")
        static let didArchiveProject = Notification.Name("io.windmill.windmill.activity.did.archive")
        static let didExportProject = Notification.Name("io.windmill.windmill.activity.did.export")
        static let didDistributeProject = Notification.Name("io.windmill.windmill.activity.did.distribute")
        static let isMonitoring = Notification.Name("io.windmill.windmill.activity.monitoring")
        static let SourceCodeChanged = Notification.Name("io.windmill.windmill.subscription.commit")
        
        static let DevicesListed = Notification.Name("io.windmill.windmill.activity.devices.listed")

        static let didError = Notification.Name("io.windmill.windmill.activity.did.error")
        
        static let activityDidLaunch = Notification.Name("io.windmill.windmill.activity.did.launch")
        static let activityDidExitSuccesfully = Notification.Name("io.windmill.windmill.activity.did.exit.succesfully")
        static let NoUserAccount = Notification.Name("io.windmill.windmill.user.none")

    }
    
    let log = OSLog(subsystem: "io.windmill.windmill", category: "windmill")
    
    let queue = DispatchQueue(label: "io.windmill.log.queue")
    
    let configuration: Configuration
    let locations: Locations
    let subscriptionManager: SubscriptionManager
    var activityManager: ActivityManager? {
        didSet {
            activityManager?.windmill = self
            activityManager?.delegate = self
        }
    }

    var subscriptionStatus: SubscriptionStatus? {
        didSet {
            if oldValue == nil, case .active(let account, let authorizationToken)? = subscriptionStatus {
                
                if self.configuration.activities.contains(.distribute) {
                    self.activityManager?.distribute(configuration: self.configuration, locations: self.locations, standardOutFormattedWriter: self.standardOutFormattedWriter, account: account, authorizationToken: authorizationToken)
                }
            }
        }
    }

    let standardOutFormattedWriter: StandardOutFormattedWriter
    
    var dispatchSourceWrite: DispatchSourceWrite? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    deinit {
        dispatchSourceWrite?.cancel()
    }

    // MARK: init
    init(configuration: Configuration, locations: Locations, subscriptionManager: SubscriptionManager) {

        self.configuration = configuration
        self.locations = locations
        self.standardOutFormattedWriter = StandardOutFormattedWriter.make(queue: self.queue, fileURL: self.locations.logfile)
        self.subscriptionManager = subscriptionManager
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActive(notification:)), name: SubscriptionManager.SubscriptionActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionFailed(notification:)), name: SubscriptionManager.SubscriptionFailed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(devicesListed(_:)), name: Windmill.Notifications.DevicesListed, object: self)
    }
    
    private func error(_ error: Error) {
        switch error {
        case let error as SubscriptionError:
            self.standardOutFormattedWriter.error(error: error)
            self.dispatchSourceWrite = self.standardOutFormattedWriter.activate()
        case let error:
            self.standardOutFormattedWriter.failed(title: "Subscription Access", error: (error as NSError))
            self.dispatchSourceWrite = self.standardOutFormattedWriter.activate()
        }
    }
    
    private func warn(_ error: SubscriptionError) {
        self.standardOutFormattedWriter.warn(error: error)
        self.dispatchSourceWrite = self.standardOutFormattedWriter.activate()
    }
    
    func accountStatus(accountStatus: CKAccountStatus, error: Error?) {
        
        switch (accountStatus, error) {
        case (.available, nil):
            return
        case (.noAccount, nil):
            DispatchQueue.main.async {
                self.notify(notification: Notifications.NoUserAccount)
            }
        case (.couldNotDetermine, nil):
            os_log("%{public}@", log: .default, type: .debug, "CKAccountStatus: Could not determine status.")
        case (.restricted, nil):
            os_log("%{public}@", log: .default, type: .debug, "CKAccountStatus: Access was denied due to Parental Controls or Mobile Device Management restrictions.")
        case (_, let error?):
            os_log("%{public}@", log: .default, type: .error, "CKAccountStatus error: \(error.localizedDescription)")
        @unknown default:
            return
        }
    }
    
    @objc func subscriptionActive(notification: NSNotification) {
        self.subscriptionStatus(SubscriptionStatus.default)
    }

    @objc func subscriptionFailed(notification: NSNotification) {
        guard let error = notification.userInfo?["error"] as? SubscriptionError else {
            return
        }
        
        self.warn(error)
    }
    
    func subscriptionStatus(_ subscriptionStatus: SubscriptionStatus) {
        guard subscriptionStatus.isActive else {
            return
        }
        
        self.subscriptionStatus = subscriptionStatus
    }

    @objc func devicesListed(_ notification: Notification) {
        if let destination = notification.userInfo?["destination"] as? Devices.Destination {
            Process.makeBoot(destination: destination).launch()
        }
    }
    
    // MARK: public
    @discardableResult func removeDerivedData() -> Bool {
        return self.locations.derivedData.remove()
    }
    
    @discardableResult func isRepositoryDirectoryPresent() -> Bool {
        return self.locations.repository.exists()
    }
    
    @discardableResult func removeRepositoryDirectory() -> Bool {
        return self.locations.repository.remove()
    }
    
    func willLaunch(activity: ActivityType, userInfo: [AnyHashable : Any]?) {
        
    }
    
    func will(_ manager: ActivityManager, launch activity: ActivityType, userInfo: [AnyHashable : Any]? = nil) {
        self.willLaunch(activity: activity, userInfo: userInfo)
    }

    func didLaunch(activity: ActivityType, userInfo: [AnyHashable : Any]?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Windmill.Notifications.activityDidLaunch, object: self, userInfo: userInfo)
        }
    }
    
    func did(_ manager: ActivityManager, launch activity: ActivityType, userInfo: [AnyHashable : Any]? = nil) {
        self.didLaunch(activity: activity, userInfo: userInfo)
    }

    func didExitSuccesfully(activity: ActivityType, userInfo: [AnyHashable : Any]?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Windmill.Notifications.activityDidExitSuccesfully, object: self, userInfo: userInfo)
        }
    }

    func did(_ manager: ActivityManager, exitSuccesfully activity: ActivityType, userInfo: [AnyHashable : Any]? = nil) {
        self.didExitSuccesfully(activity: activity, userInfo: userInfo)
    }
    
    func did(terminate activity: ActivityType, error: Error, userInfo: [AnyHashable : Any]?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Windmill.Notifications.didError, object: self, userInfo: userInfo)
        }
    }
    
    func did(_ manager: ActivityManager, terminate activity: ActivityType, error: Error, userInfo: [AnyHashable : Any]?) {
        self.did(terminate: activity, error: error, userInfo: userInfo)
    }
    
    func notify(notification name: Notification.Name, userInfo: [AnyHashable : Any]? = nil) {
        NotificationCenter.default.post(name: name, object: self, userInfo: userInfo)
    }
    
    func distribute(account: Account, authorizationToken: SubscriptionAuthorizationToken) {
        let activityDistribute = ActivityDistribute(subscriptionManager: self.subscriptionManager, standardOutFormattedWriter: self.standardOutFormattedWriter)
        activityDistribute.delegate = self
        
        let distribute = activityDistribute.make(account: account, authorizationToken: authorizationToken)
        distribute(ActivityDistribute.Context.make(locations: self.locations, configuration: self.configuration))
    }
    
    func exportAndMonitor(activityManager: ActivityManager, skipCheckout: Bool = false) -> Activity {
        
        let activityBuiler = activityManager.builder(configuration: self.configuration, locations: self.locations)
        
        let pollActivity =
            activityBuiler.pollActivity(activityManager: activityManager, then: DispatchWorkItem { [weak self] in
                self?.notify(notification: Windmill.Notifications.SourceCodeChanged)
            })
        
        return activityBuiler.exportSeries(activityManager: activityManager, skipCheckout: skipCheckout, next: pollActivity)
    }
    
    func testAndMonitor(activityManager: ActivityManager, skipCheckout: Bool = false) -> Activity {
        
        let activityBuiler = activityManager.builder(configuration: self.configuration, locations: self.locations)
        
        let pollActivity =
            activityBuiler.pollActivity(activityManager: activityManager, then: DispatchWorkItem { [weak self] in
                self?.notify(notification: Windmill.Notifications.SourceCodeChanged)
            })
        
        return activityBuiler.testSeries(activityManager: activityManager, skipCheckout: skipCheckout, next: pollActivity)
    }

    /**
     Do not call this method repeatedly.
     
    */
    public func run(skipCheckout: Bool = false) {
        
        guard let activityManager = self.activityManager else {
            preconditionFailure("ActivityManager hasn't been set on Windmill. Did you call the setter?")
        }
        
        if skipCheckout {
            self.standardOutFormattedWriter.note("Using existing source code")
            self.dispatchSourceWrite = self.standardOutFormattedWriter.activate()
        }
        
        self.notify(notification: Windmill.Notifications.willRun, userInfo: ["project":self.configuration.project])
        
        self.subscriptionStatus(SubscriptionStatus.default)
        
        if self.configuration.activities.contains(.export) {
            let exportAndMonitor = self.exportAndMonitor(activityManager: activityManager, skipCheckout: skipCheckout)
            exportAndMonitor([:])
        } else if self.configuration.activities.contains(.test) {
            let testAndMonitor = self.testAndMonitor(activityManager: activityManager, skipCheckout: skipCheckout)
            testAndMonitor([:])
        }
        
        self.notify(notification: Windmill.Notifications.didRun, userInfo: ["project":self.configuration.project])
    }
    
    func distribute(failure: @escaping (_ error: Error) -> Void) {

        self.subscriptionManager.fetchSubscription { result in
            switch result {
            case .failure(let error):
                self.standardOutFormattedWriter.failed(title: "Distribute Error", error: (error as NSError))
                self.dispatchSourceWrite = self.standardOutFormattedWriter.activate()
                failure(error)
            case .success:
                switch SubscriptionStatus.default {
                case .active(let account, let authorizationToken):
                    self.distribute(account: account, authorizationToken: authorizationToken)
                case .expired(let account, _):
                    if let token = try? Keychain.default.read(key: .subscriptionAuthorizationToken) {
                        self.distribute(account: account, authorizationToken: SubscriptionAuthorizationToken(value: token))
                    }
                default:
                    return
                }
            }
        }
    }
    
    public func restoreSubscription(failure: @escaping (_ error: Error) -> Void) {
        
        CKContainer.default().accountStatus { accountStatus, error in
            DispatchQueue.main.async {
                self.accountStatus(accountStatus: accountStatus, error: error)
            }
        }
        
        self.subscriptionManager.fetchSubscription { result in
            if case .failure(let error) = result {
                self.standardOutFormattedWriter.failed(title: "Restore Subscription", error: (error as NSError))
                self.dispatchSourceWrite = self.standardOutFormattedWriter.activate()
                self.error(error)
                failure(error)
            }
        }
    }

    public func refreshSubscription(failure: @escaping (_ error: Error) -> Void) {
        switch SubscriptionStatus.default {
        case .expired(let account, let claim):
            self.subscriptionManager.requestSubscription(account: account, claim: claim) { [weak self] token, error in
                if let error = error {
                    self?.error(error)
                    failure(error)
                }
            }
        default:
            return
        }
    }
    
    public func remove() {
        DispatchQueue.main.async {
            Windmill.Configuration.shared.delete(self.configuration)
        }
        self.removeDerivedData()
        self.removeRepositoryDirectory()
        self.locations.home.remove()
        self.locations.resultBundleDirectory.remove()
    }
}
