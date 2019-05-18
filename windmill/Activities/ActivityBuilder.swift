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
    
    public func exportSeries(activityManager: ActivityManager, skipCheckout: Bool = false, next nextActivity: @escaping Activity) -> Activity {
        
        let checkoutActivity: SuccessfulActivity
        
        let repositoryLocalURL = self.projectRepositoryDirectory
        
        if skipCheckout {
            checkoutActivity =
                ActivityAlwaysSuccess(activityManager: activityManager, type: ActivityType.checkout)
                    .make(userInfo: ["repositoryDirectory": repositoryLocalURL])
        } else {
            var activityCheckout =
                ActivityCheckout(processManager: processManager, projectLogURL: projectLogURL)
            activityCheckout.delegate = activityManager
            checkoutActivity = activityCheckout.success(repositoryLocalURL: repositoryLocalURL, project: project)
        }
        
        let location = configuration.location
        
        var activityFindProject =
            ActivityFindProject(applicationCachesDirectory: applicationCachesDirectory, processManager: processManager)
        activityFindProject.delegate = activityManager
        let findProjectActivity = activityFindProject.success(project: project, location: location)
        
        let configuration = self.projectDirectory.configuration()
        
        var activityReadProjectConfiguration =
            ActivityReadProjectConfiguration(processManager: processManager)
        activityReadProjectConfiguration.delegate = activityManager
        let readProjectConfigurationActivity = activityReadProjectConfiguration.success(project: project, configuration: configuration)
        
        let scheme = configuration.detectScheme(name: project.scheme)
        
        var activityShowBuildSettings =
            ActivityShowBuildSettings(processManager: processManager)
        activityShowBuildSettings.delegate = activityManager
        let showBuildSettingsActivity = activityShowBuildSettings.success(project: project, location: location, scheme: scheme, buildSettings: self.projectDirectory.buildSettings())
        
        let devices = self.projectDirectory.devices()
        
        var activityListDevices =
            ActivityListDevices(processManager: processManager)
            activityListDevices.delegate = activityManager
        let listDevicesActivity = activityListDevices.success(devices: devices)
        
        let buildSettings = self.projectDirectory.buildSettings().for(project: self.project.name)
        
        let appBundle = self.projectDirectory.appBundle(name: project.name)
        
        var activityBuild =
            ActivityBuild(applicationCachesDirectory: self.applicationCachesDirectory, applicationSupportDirectory: self.applicationSupportDirectory, processManager: processManager, projectLogURL: projectLogURL)
        activityBuild.delegate = activityManager
        let buildActivity = activityBuild.success(location: location, project: project, appBundle: appBundle, scheme: scheme, projectDirectory: self.projectDirectory, buildSettings: buildSettings)
        
        var activityTest =
            ActivityTest(applicationCachesDirectory: self.applicationCachesDirectory, applicationSupportDirectory: self.applicationSupportDirectory, processManager: processManager, projectLogURL: projectLogURL)
        activityTest.delegate = activityManager
        let testActivity = activityTest.success(location: location, project: project, devices: devices, scheme: scheme)
        
        let archive = self.projectDirectory.archive(name: scheme)
        
        var activityArchive =
            ActivityArchive(applicationCachesDirectory: self.applicationCachesDirectory, applicationSupportDirectory: self.applicationSupportDirectory, processManager: processManager, projectLogURL: projectLogURL)
        activityArchive.delegate = activityManager
        let archiveActivity = activityArchive.success(location: location, project: project, scheme: scheme, archive: archive, configuration: .release)
        
        let export = self.projectDirectory.export(name: scheme)
        
        var activityExport =
            ActivityExport(applicationCachesDirectory: self.applicationCachesDirectory, applicationSupportDirectory: self.applicationSupportDirectory, processManager: processManager, projectLogURL: projectLogURL)
        activityExport.delegate = activityManager
        let exportActivity = activityExport.success(location: location, project: project, projectDirectory: self.projectDirectory, appBundle: appBundle, export: export, configuration: .release, exportDirectoryURL: self.projectDirectory.exportDirectoryURL())
        
        return checkoutActivity -->
            findProjectActivity -->
            readProjectConfigurationActivity -->
            showBuildSettingsActivity -->
            listDevicesActivity -->
            buildActivity -->
            testActivity -->
            archiveActivity -->
            exportActivity -->
            nextActivity
    }
    
    public func pollActivity(activityManager: ActivityManager, then: DispatchWorkItem) -> Activity {        
        return ActivityPoll(processManager: self.processManager, activityManager: activityManager)
                .make(project: project, repositoryDirectory: self.projectRepositoryDirectory, pollDirectoryURL: self.projectDirectory.pollURL(), do: then)
    }
    
    
    public func distributeActivity(standardOutFormattedWriter: StandardOutFormattedWriter, queue: DispatchQueue? = nil) -> ActivityDistribute {
        return ActivityDistribute(subscriptionManager: subscriptionManager, standardOutFormattedWriter: standardOutFormattedWriter)
    }
}
