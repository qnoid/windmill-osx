//
//  ActivityBuilder.swift
//  windmill
//
//  Created by Markos Charatzas on 11/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

class ActivityBuiler {
    
    static func make(configuration: Windmill.Configuration, locations: Windmill.Locations, subscriptionManager: SubscriptionManager, processManager: ProcessManager) -> ActivityBuiler {
        return ActivityBuiler(configuration: configuration, locations: locations, subscriptionManager: subscriptionManager, processManager: processManager)
    }

    let configuration: Windmill.Configuration
    let locations: Windmill.Locations
    
    unowned var subscriptionManager: SubscriptionManager
    unowned var processManager: ProcessManager

    init(configuration: Windmill.Configuration, locations: Windmill.Locations, subscriptionManager: SubscriptionManager, processManager: ProcessManager) {
        self.configuration = configuration
        self.locations = locations
        self.subscriptionManager = subscriptionManager
        self.processManager = processManager
    }
    
    public func testSeries(activityManager: ActivityManager, skipCheckout: Bool = false, next nextActivity: @escaping Activity) -> Activity {

        let project: Project = configuration.project
        let home = locations.home
        let logfile = locations.logfile
        let repository = locations.repository

        FileManager.default.createFile(atPath: logfile.path, contents: nil, attributes: nil)

        let checkoutActivity: SuccessfulActivity
        
        if skipCheckout {
            checkoutActivity =
                ActivityAlwaysSuccess(activityManager: activityManager, type: ActivityType.checkout)
                    .make(userInfo: ["repository": repository])
        } else {
            var activityCheckout =
                ActivityCheckout(processManager: processManager, logfile: logfile)
            activityCheckout.delegate = activityManager
            checkoutActivity = activityCheckout.success(repository: repository, project: project, branch: configuration.branch)
        }
        
        let projectAt = self.locations.projectAt
        
        var activityFindProject =
            ActivityFindProject(processManager: processManager)
        activityFindProject.delegate = activityManager
        let findProjectActivity = activityFindProject.success(project: project, projectAt: projectAt)
        
        let configuration = home.configuration()
        
        var activityReadProjectConfiguration =
            ActivityReadProjectConfiguration(processManager: processManager)
        activityReadProjectConfiguration.delegate = activityManager
        let readProjectConfigurationActivity = activityReadProjectConfiguration.success(project: project, configuration: configuration)
        
        var activityShowBuildSettings =
            ActivityShowBuildSettings(processManager: processManager)
        activityShowBuildSettings.delegate = activityManager
        let showBuildSettingsActivity = activityShowBuildSettings.success(project: project, projectAt: projectAt, configuration: configuration, buildSettings: home.buildSettings())
        
        let devices = home.devices()
        
        var activityListDevices =
            ActivityListDevices(processManager: processManager)
        activityListDevices.delegate = activityManager
        let listDevicesActivity = activityListDevices.success(devices: devices)
        
        let buildSettings = home.buildSettings().for(project: project.name)
        
        let appBundle = home.appBundle(name: project.name)
        
        var activityBuild =
            ActivityBuild(locations: self.locations, processManager: processManager, logfile: logfile)
        activityBuild.delegate = activityManager
        let buildActivity = activityBuild.success(projectAt: projectAt, project: project, appBundle: appBundle, configuration: configuration, home: home, buildSettings: buildSettings)
        
        var activityTest =
            ActivityTest(locations: self.locations, processManager: processManager, logfile: logfile)
        activityTest.delegate = activityManager
        let testActivity = activityTest.success(projectAt: projectAt, project: project, devices: devices, configuration: configuration)
        
        return checkoutActivity -->
            findProjectActivity -->
            readProjectConfigurationActivity -->
            showBuildSettingsActivity -->
            listDevicesActivity -->
            buildActivity -->
            testActivity -->
        nextActivity
    }

    public func exportSeries(activityManager: ActivityManager, skipCheckout: Bool = false, next nextActivity: @escaping Activity) -> Activity {
        
        let project = configuration.project
        let home = locations.home
        let logfile = locations.logfile
        let repository = locations.repository

        FileManager.default.createFile(atPath: logfile.path, contents: nil, attributes: nil)
        
        let checkoutActivity: SuccessfulActivity
        
        if skipCheckout {
            checkoutActivity =
                ActivityAlwaysSuccess(activityManager: activityManager, type: ActivityType.checkout)
                    .make(userInfo: ["repository": repository])
        } else {
            var activityCheckout =
                ActivityCheckout(processManager: processManager, logfile: logfile)
            activityCheckout.delegate = activityManager
            checkoutActivity = activityCheckout.success(repository: repository, project: project)
        }
        
        let projectAt = locations.projectAt
        
        var activityFindProject =
            ActivityFindProject(processManager: processManager)
        activityFindProject.delegate = activityManager
        let findProjectActivity = activityFindProject.success(project: project, projectAt: projectAt)
        
        let configuration = home.configuration()
        
        var activityReadProjectConfiguration =
            ActivityReadProjectConfiguration(processManager: processManager)
        activityReadProjectConfiguration.delegate = activityManager
        let readProjectConfigurationActivity = activityReadProjectConfiguration.success(project: project, configuration: configuration)
        
        var activityShowBuildSettings =
            ActivityShowBuildSettings(processManager: processManager)
        activityShowBuildSettings.delegate = activityManager
        let showBuildSettingsActivity = activityShowBuildSettings.success(project: project, projectAt: projectAt, configuration: configuration, buildSettings: home.buildSettings())
        
        let devices = home.devices()
        
        var activityListDevices =
            ActivityListDevices(processManager: processManager)
            activityListDevices.delegate = activityManager
        let listDevicesActivity = activityListDevices.success(devices: devices)
        
        let buildSettings = home.buildSettings().for(project: project.name)
        
        let appBundle = home.appBundle(name: project.name)
        
        var activityBuild =
            ActivityBuild(locations: self.locations, processManager: processManager, logfile: logfile)
        activityBuild.delegate = activityManager
        let buildActivity = activityBuild.success(projectAt: projectAt, project: project, appBundle: appBundle, configuration: configuration, home: home, buildSettings: buildSettings)
        
        var activityTest =
            ActivityTest(locations: self.locations, processManager: processManager, logfile: logfile)
        activityTest.delegate = activityManager
        let testActivity = activityTest.success(projectAt: projectAt, project: project, devices: devices, configuration: configuration)
        
        var activityArchive =
            ActivityArchive(locations: self.locations, processManager: processManager, logfile: logfile)
        activityArchive.delegate = activityManager
        let archiveActivity = activityArchive.success(projectAt: projectAt, project: project, configuration: configuration, build: .release)
        
        var activityExport =
            ActivityExport(locations: self.locations, processManager: processManager, logfile: logfile)
        activityExport.delegate = activityManager
        let exportActivity = activityExport.success(projectAt: projectAt, project: project, appBundle: appBundle, configuration: configuration, build: .release, exportDirectoryURL: home.exportDirectoryURL())
        
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
            .make(project: self.configuration.project, branch: self.configuration.branch, repository: self.locations.repository, pollDirectoryURL: self.locations.home.pollURL(), do: then)
    }
    
    
    public func distributeActivity(standardOutFormattedWriter: StandardOutFormattedWriter, queue: DispatchQueue? = nil) -> ActivityDistribute {
        return ActivityDistribute(subscriptionManager: subscriptionManager, standardOutFormattedWriter: standardOutFormattedWriter)
    }
}
