//
//  ActivityBuilder.swift
//  windmill
//
//  Created by Markos Charatzas on 11/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

class ActivityBuiler {
    
    let applicationCachesDirectory = Directory.Windmill.ApplicationCachesDirectory()
    let applicationSupportDirectory = Directory.Windmill.ApplicationSupportDirectory()

    static func make(configuration: Windmill.Configuration, subscriptionManager: SubscriptionManager, processManager: ProcessManager) -> ActivityBuiler {
        return ActivityBuiler(configuration: configuration, subscriptionManager: subscriptionManager, processManager: processManager)
    }

    let configuration: Windmill.Configuration
    
    
    unowned var subscriptionManager: SubscriptionManager
    unowned var processManager: ProcessManager

    lazy var project: Project = configuration.project
    lazy var projectDirectory = configuration.projectDirectory
    lazy var projectLogURL = configuration.projectLogURL
    lazy var projectRepositoryDirectory = configuration.projectRepositoryDirectory

    init(configuration: Windmill.Configuration, subscriptionManager: SubscriptionManager, processManager: ProcessManager) {
        self.configuration = configuration
        self.subscriptionManager = subscriptionManager
        self.processManager = processManager
    }
    
    public func exportActivity(activityManager: ActivityManager, skipCheckout: Bool = false, next: @escaping Activity) -> Activity {
        
        try? FileManager.default.removeItem(at: projectLogURL)
                
        let activityCheckout: ActivitySuccess
        
        let repositoryLocalURL = self.projectRepositoryDirectory
        
        if skipCheckout {
            activityCheckout =
                ActivityAlwaysSuccess(activityManager: activityManager, type: ActivityType.checkout)
                    .make(userInfo: ["repositoryDirectory": repositoryLocalURL])
        } else {
            activityCheckout =
                ActivityCheckout(processManager: processManager, activityManager: activityManager, projectLogURL: projectLogURL)
                    .success(repositoryLocalURL: repositoryLocalURL, project: project)
        }
        
        let location = Project.Location(url: self.projectRepositoryDirectory.URL)
        
        let activityFindProject =
            ActivityFindProject(applicationCachesDirectory: applicationCachesDirectory, processManager: processManager, activityManager: activityManager)
                .success(project: project, location: location)
        
        let configuration = self.projectDirectory.configuration()
        
        let activityReadProjectConfiguration =
            ActivityReadProjectConfiguration(processManager: processManager, activityManager: activityManager)
                .success(project: project, configuration: configuration)
        
        let scheme = configuration.detectScheme(name: project.scheme)
        
        let activityShowBuildSettings =
            ActivityShowBuildSettings(processManager: processManager, activityManager: activityManager)
                .success(project: project, location: location, scheme: scheme, buildSettings: self.projectDirectory.buildSettings())
        
        let devices = self.projectDirectory.devices()
        
        let activityListDevices =
            ActivityListDevices(processManager: processManager, activityManager: activityManager)
                .success(devices: devices)
        
        let buildSettings = self.projectDirectory.buildSettings().for(project: self.project.name)
        
        let appBundle = self.projectDirectory.appBundle(name: project.name)
        
        let activityBuild =
            ActivityBuild(applicationCachesDirectory: self.applicationCachesDirectory, applicationSupportDirectory: self.applicationSupportDirectory, processManager: processManager, activityManager: activityManager, log: projectLogURL)
                .make(location: location, project: project, appBundle: appBundle, scheme: scheme, projectDirectory: self.projectDirectory, buildSettings: buildSettings)
        
        let activityTest =
            ActivityTest(applicationCachesDirectory: self.applicationCachesDirectory, applicationSupportDirectory: self.applicationSupportDirectory, processManager: processManager, activityManager: activityManager, log: projectLogURL)
                .success(location: location, project: project, devices: devices, scheme: scheme)
        
        let archive = self.projectDirectory.archive(name: scheme)
        
        let activityArchive =
            ActivityArchive(applicationCachesDirectory: self.applicationCachesDirectory, applicationSupportDirectory: self.applicationSupportDirectory, processManager: processManager, activityManager: activityManager, log: projectLogURL)
                .success(location: location, project: project, scheme: scheme, archive: archive)
        
        let export = self.projectDirectory.export(name: scheme)
        
        let activityExport =
            ActivityExport(applicationCachesDirectory: self.applicationCachesDirectory, applicationSupportDirectory: self.applicationSupportDirectory, processManager: processManager, activityManager: activityManager, log: projectLogURL)
                .success(location: location, project: project, projectDirectory: self.projectDirectory, appBundle: appBundle, export: export, exportDirectoryURL: self.projectDirectory.exportDirectoryURL())
        
        return activityCheckout(activityFindProject(activityReadProjectConfiguration(activityShowBuildSettings(
            activityListDevices(activityBuild(activityTest(activityArchive(activityExport(next))))
        )))))
    }
    
    public func pollActivity(activityManager: ActivityManager, then: DispatchWorkItem) -> Activity {        
        return ActivityPoll(processManager: self.processManager, activityManager: activityManager)
                .make(project: project, repositoryDirectory: self.projectRepositoryDirectory, pollDirectoryURL: self.projectDirectory.pollURL(), do: then)
    }
    
    
    public func distributeActivity(account: Account, authorizationToken: SubscriptionAuthorizationToken, activityManager: ActivityManager, standardOutFormattedWriter: StandardOutFormattedWriter, queue: DispatchQueue? = nil) -> Activity {        
        return ActivityDistribute(subscriptionManager: subscriptionManager, activityManager: activityManager, standardOutFormattedWriter: standardOutFormattedWriter)
            .make(queue: queue, account: account, authorizationToken: authorizationToken)
    }
}
