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
    lazy var applicationCachesDirectory = self.windmill.configuration.applicationCachesDirectory
    lazy var applicationSupportDirectory = self.windmill.configuration.applicationSupportDirectory
    lazy var projectDirectory = self.windmill.configuration.projectDirectory
    
    
    init(project: Project, windmill: Windmill) {
        self.project = project
        self.windmill = windmill
    }
    
    func activityBuild(locationURL: URL, next: @escaping Activity) -> Activity {
        
        let location = Project.Location(url: locationURL)
        let configuration = self.projectDirectory.configuration()
        
        let activityReadProjectConfiguration =
            ActivityReadProjectConfiguration(processManager: processManager, activityManager: activityManager)
                .make(project: project, configuration: configuration)
        
        let scheme = configuration.detectScheme(name: project.scheme)
        
        let activityShowBuildSettings =
            ActivityShowBuildSettings(processManager: processManager, activityManager: activityManager)
                .make(project: project, location: location, scheme: scheme, buildSettings: self.projectDirectory.buildSettings())
        
        let devices = self.projectDirectory.devices()
        
        let activityListDevices =
            ActivityListDevices(processManager: processManager, activityManager: activityManager)
                .make(devices: devices)
        
        let buildSettings = self.projectDirectory.buildSettings().for(project: self.project.name)
        
        let appBundle = self.projectDirectory.appBundle(name: project.name)
        
        let activityBuild =
            ActivityBuild(applicationCachesDirectory: self.applicationCachesDirectory, applicationSupportDirectory: self.applicationSupportDirectory, processManager: processManager, activityManager: activityManager, log: FileManager.default.trashDirectoryURL.appendingPathComponent(CharacterSet.Windmill.random()))
                .make(location: location, project: project, appBundle: appBundle, scheme: scheme, projectDirectory: self.projectDirectory, buildSettings: buildSettings)
        
        return activityReadProjectConfiguration(activityShowBuildSettings(activityListDevices(activityBuild(next))))
    }
    
    func activityTest(locationURL: URL, buildSettings: BuildSettings, next: @escaping Activity) -> Activity {
        
        let location = Project.Location(url: locationURL)

        let devices = self.projectDirectory.devices()

        let activityListDevices =
            ActivityListDevices(processManager: processManager, activityManager: activityManager)
                .make(devices: devices)
        
        let activityBuild = ActivityBuild(applicationCachesDirectory: applicationCachesDirectory, applicationSupportDirectory: applicationSupportDirectory, processManager: processManager, activityManager: activityManager, log: FileManager.default.trashDirectoryURL.appendingPathComponent(CharacterSet.Windmill.random())).make(location: location, project: project, appBundle: AppBundle.make(), scheme: project.scheme, projectDirectory: projectDirectory, buildSettings: buildSettings)
        
        let activityTest =
            ActivityTest(applicationCachesDirectory: applicationCachesDirectory, applicationSupportDirectory: applicationSupportDirectory, processManager: processManager, activityManager: activityManager, log: FileManager.default.trashDirectoryURL.appendingPathComponent(CharacterSet.Windmill.random()))
                .make(location: location, project: project, devices: devices, scheme: project.scheme)

        return activityListDevices(activityBuild(activityTest(next)))
    }
}
