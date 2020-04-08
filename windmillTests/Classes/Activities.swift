//
//  Activities.swift
//  windmillTests
//
//  Created by Markos Charatzas (markos@qnoid.com) on 09/03/2019.
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
