//
//  Activities.swift
//  windmillTests
//
//  Created by Markos Charatzas on 09/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

@testable import Windmill

class Activities {
    let project: Project
    let windmill: Windmill

    lazy var activityManager = self.windmill.activityManager!
    lazy var processManager = self.windmill.activityManager!.processManager
    lazy var applicationCachesDirectory = Directory.Windmill.ApplicationCachesDirectory()
    lazy var applicationSupportDirectory = Directory.Windmill.ApplicationSupportDirectory()
    lazy var projectDirectory = self.windmill.locations.home
    
    
    init(project: Project, windmill: Windmill) {
        self.project = project
        self.windmill = windmill
    }
    
    func activityBuild(locationURL: URL, next: @escaping Activity) -> Activity {
        
        let location = Project.Location(project: self.project, url: locationURL)
        let configuration = self.projectDirectory.configuration()
        
        var activityReadProjectConfiguration =
            ActivityReadProjectConfiguration(processManager: processManager)
        activityReadProjectConfiguration.delegate = activityManager
        let readProjectConfiguration = activityReadProjectConfiguration.success(project: project, configuration: configuration)
        
        var activityShowBuildSettings =
            ActivityShowBuildSettings(processManager: processManager)
        activityShowBuildSettings.delegate = activityManager
        let showBuildSettings = activityShowBuildSettings.success(project: project, projectAt: location, configuration: configuration, buildSettings: self.projectDirectory.buildSettings())
        
        let devices = self.projectDirectory.devices()
        
        var activityListDevices =
            ActivityListDevices(processManager: processManager)
        activityListDevices.delegate = activityManager
        let listDevices = activityListDevices.success(devices: devices)
        
        let buildSettings = self.projectDirectory.buildSettings().for(project: self.project.name)
        
        let appBundle = self.projectDirectory.appBundle(name: project.name)
        
        var activityBuild =
            ActivityBuild(locations: self.windmill.locations, processManager: processManager, logfile: FileManager.default.trashDirectoryURL.appendingPathComponent(CharacterSet.Windmill.random()))
        activityBuild.delegate = activityManager
        let build = activityBuild.success(projectAt: location, project: project, appBundle: appBundle, configuration: configuration, home: self.projectDirectory, buildSettings: buildSettings)
        
        return readProjectConfiguration -->
            showBuildSettings -->
            listDevices -->
            build -->
            next
    }
    
    func activityTest(locationURL: URL, buildSettings: BuildSettings, next: @escaping Activity) -> Activity {
        
        let location = Project.Location(project: self.project, url: locationURL)        
        let devices = self.projectDirectory.devices()
        let configuration = self.windmill.locations.home.configuration()

        var activityListDevices =
            ActivityListDevices(processManager: processManager)
        activityListDevices.delegate = activityManager
        let listDevices = activityListDevices.success(devices: devices)
        
        var activityBuild = ActivityBuild(locations: self.windmill.locations, processManager: processManager, logfile: FileManager.default.trashDirectoryURL.appendingPathComponent(CharacterSet.Windmill.random()))
        activityBuild.delegate = activityManager
        let build = activityBuild.success(projectAt: location, project: project, appBundle: AppBundles.make(), configuration: configuration, home: self.projectDirectory, buildSettings: buildSettings)
        
        var activityTest =
            ActivityTest(locations: self.windmill.locations, processManager: processManager, logfile: FileManager.default.trashDirectoryURL.appendingPathComponent(CharacterSet.Windmill.random()))
        activityTest.delegate = activityManager
        let test = activityTest.success(projectAt: location, project: project, devices: devices, configuration: configuration)

        return listDevices --> build --> test --> next
    }
}
