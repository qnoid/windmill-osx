//
//  NSTasks.swift
//  windmill
//
//  Created by Markos Charatzas on 07/09/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import Foundation
import os

extension Process
{    
    func localizedFailureReason(type: ActivityType, exitStatus: Int32) -> String {
        return NSLocalizedString("windmill.activity.\(type.rawValue).error.failure.reason.exitStatus", comment: "") + "\(exitStatus)"
    }
    
    fileprivate class func pathForDir(_ name: String) -> String! {
        return Bundle.main.path(forResource: name, ofType:nil)
    }
    
    public static func makeSuccess() -> Process {
        
        let process = Process()
        process.launchPath = "/usr/bin/true"
        process.qualityOfService = .utility
        
        return process
    }
    
    public static func makeFind(project: Project, repositoryLocalURL: Repository.LocalURL) -> Process {
        
        let process = Process()
        process.launchPath = Bundle.main.path(forResource: Scripts.CommandLineTools.FIND_PROJECT_DIRECTORY, ofType: "sh")!
        process.arguments = [repositoryLocalURL.path, project.filename]
        process.qualityOfService = .utility
        
        return process
    }

    public static func makeShowBuildSettings(project: Project, scheme: String, buildSettings: BuildSettings, location: Project.Location) -> Process {
        
        switch project.isWorkspace {
        case true?:
            let process = Process()
            process.currentDirectoryPath = location.url.path
            process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.SHOW_WORKSPACE_BUILD_SETTINGS, ofType: "sh")!
            process.arguments = [project.filename, scheme, buildSettings.url.path, self.pathForDir("Scripts")]
            process.qualityOfService = .utility
            
            return process
        case false?:
            let process = Process()
            process.currentDirectoryPath = location.url.path
            process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.SHOW_PROJECT_BUILD_SETTINGS, ofType: "sh")!
            process.arguments = [project.filename, buildSettings.url.path, self.pathForDir("Scripts")]
            process.qualityOfService = .utility
            
            return process
        default:
            let process = Process()
            process.currentDirectoryPath = location.url.path
            process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.SHOW_BUILD_SETTINGS, ofType: "sh")!
            process.arguments = [buildSettings.url.path, self.pathForDir("Scripts")]
            process.qualityOfService = .utility
            
            return process
        }
    }
    
    public static func makeListConfiguration(project: Project, configuration: Project.Configuration, location: Project.Location) -> Process {
        
        switch project.isWorkspace {
        case true?:
            let process = Process()
            process.currentDirectoryPath = location.url.path
            process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.LIST_WORKSPACE_CONFIGURATION, ofType: "sh")!
            process.arguments = [project.filename, configuration.url.path]
            process.qualityOfService = .utility
            
            return process
        case false?:
            let process = Process()
            process.currentDirectoryPath = location.url.path
            process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.LIST_PROJECT_CONFIGURATION, ofType: "sh")!
            process.arguments = [project.filename, configuration.url.path]
            process.qualityOfService = .utility
            
            return process
        default:
            let process = Process()
            process.currentDirectoryPath = location.url.path
            process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.LIST_CONFIGURATION, ofType: "sh")!
            process.arguments = [configuration.url.path]
            process.qualityOfService = .utility
            
            return process
        }
    }
    
    
    public static func makeList(devices: Devices, for deployment: BuildSettings.Deployment?, or minimum: String = "11.0", xcode: Xcode.Build = .XCODE_10_2_BETA_1) -> Process {
        
        let target: String = deployment?.target.flatMap { (value) -> String? in
            return String(value)
        } ?? minimum
        
        let process = Process()
        process.launchPath = Bundle.main.path(forResource: Scripts.Simctl.LIST_DEVICES, ofType: "sh")!
        process.arguments = [devices.url.path, target, self.pathForDir("Scripts"), xcode.rawValue]
        process.qualityOfService = .utility
        
        return process
    }
    
    public static func makeCheckout(sourceDirectory: RepositoryDirectory, project: Project, branch: String = "master", log: URL) -> Process {

        let process = Process()
        process.launchPath = Bundle.main.path(forResource: Scripts.Git.CHECKOUT, ofType: "sh")!
        process.arguments = [sourceDirectory.URL.path, branch, project.origin, self.pathForDir("Scripts"), log.path]
        process.qualityOfService = .utility
    
        return process
    }
    
    public static func makeBuildForTesting(location: Project.Location, project: Project, scheme: String, configuration: Configuration = .debug, destination: Devices.Destination, derivedData: DerivedDataDirectory, resultBundle: ResultBundle, log: URL) -> Process {
        
        switch project.isWorkspace {
        case true?:
            let process = Process()
            process.currentDirectoryPath = location.url.path
            process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.BUILD_WORKSPACE_FOR_TESTING, ofType: "sh")!
            process.arguments = [project.filename, scheme, configuration.name, destination.udid ?? "", derivedData.URL.path, resultBundle.url.path, log.path]
            process.qualityOfService = .utility
            
            return process
        case false?:
            let process = Process()
            process.currentDirectoryPath = location.url.path
            process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.BUILD_PROJECT_FOR_TESTING, ofType: "sh")!
            process.arguments = [project.filename, scheme, configuration.name, destination.udid ?? "", derivedData.URL.path, resultBundle.url.path, log.path]
            process.qualityOfService = .utility
            
            return process
        default:
            let process = Process()
            process.currentDirectoryPath = location.url.path
            process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.BUILD_FOR_TESTING, ofType: "sh")!
            process.arguments = [scheme, configuration.name, destination.udid ?? "", derivedData.URL.path, resultBundle.url.path, log.path]
            process.qualityOfService = .utility
            
            return process
        }
    }
    
    public static func makeBuild(location: Project.Location, project:Project, scheme: String, configuration: Configuration = .debug, destination: Devices.Destination, derivedData: DerivedDataDirectory, resultBundle: ResultBundle, log: URL) -> Process {
        
        switch project.isWorkspace {
        case true?:
            let process = Process()
            process.currentDirectoryPath = location.url.path
            process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.BUILD_WORKSPACE, ofType: "sh")!
            process.arguments = [project.filename, scheme, configuration.name, destination.udid ?? "", derivedData.URL.path, resultBundle.url.path, log.path]
            process.qualityOfService = .utility
            
            return process
        case false?:
            let process = Process()
            process.currentDirectoryPath = location.url.path
            process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.BUILD_PROJECT, ofType: "sh")!
            process.arguments = [project.filename, scheme, configuration.name, destination.udid ?? "", derivedData.URL.path, resultBundle.url.path, log.path]
            process.qualityOfService = .utility
            
            return process
        default:
            let process = Process()
            process.currentDirectoryPath = location.url.path
            process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.BUILD, ofType: "sh")!
            process.arguments = [scheme, configuration.name, destination.udid ?? "", derivedData.URL.path, resultBundle.url.path, log.path]
            process.qualityOfService = .utility
            
            return process
        }
    }
    
    static func makeTestWithoutBuilding(location: Project.Location, project:Project, scheme: String, destination: Devices.Destination, derivedData: DerivedDataDirectory, resultBundle: ResultBundle, log: URL) -> Process {
        
        switch project.isWorkspace {
        case true?:
            let process = Process()
            process.currentDirectoryPath = location.url.path
            process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.TEST_WORKSPACE_WITHOUT_BUILDING, ofType: "sh")!
            process.arguments = [project.filename, destination.udid ?? "", scheme, derivedData.URL.path, resultBundle.url.path, log.path]
            process.qualityOfService = .utility
            
            return process
        case false?:
            let process = Process()
            process.currentDirectoryPath = location.url.path
            process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.TEST_PROJECT_WITHOUT_BUILDING, ofType: "sh")!
            process.arguments = [project.filename, destination.udid ?? "", scheme, derivedData.URL.path, resultBundle.url.path, log.path]
            process.qualityOfService = .utility
            
            return process
        default:
            let process = Process()
            process.currentDirectoryPath = location.url.path
            process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.TEST_WITHOUT_BUILDING, ofType: "sh")!
            process.arguments = [destination.udid ?? "", scheme, derivedData.URL.path, resultBundle.url.path, log.path]
            process.qualityOfService = .utility
            
            return process
        }
    }
    
    static func makeTestSkip(projectLocalURL: Project.LocalURL, scheme: String, destination: Devices.Destination, derivedData: DerivedDataDirectory, resultBundle: ResultBundle) -> Process {
        
        let process = Process()
        process.currentDirectoryPath = projectLocalURL.path
        process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.TEST_SKIP, ofType: "sh")!
        process.arguments = [destination.udid ?? "", scheme, derivedData.URL.path, resultBundle.url.path]
        process.qualityOfService = .utility
        
        return process
    }
    
    public static func makeArchive(location: Project.Location, project:Project, scheme: String, configuration: Configuration = .release, derivedData: DerivedDataDirectory, archive: Archive, resultBundle: ResultBundle, log: URL) -> Process {
        
        switch project.isWorkspace {
        case true?:
            let process = Process()
            process.currentDirectoryPath = location.url.path
            process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.ARCHIVE_WORKSPACE, ofType: "sh")!
            process.arguments = [project.filename, scheme, configuration.name, derivedData.URL.path, archive.url.path, resultBundle.url.path, log.path]
            process.qualityOfService = .utility
            
            return process
        case false?:
            let process = Process()
            process.currentDirectoryPath = location.url.path
            process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.ARCHIVE_PROJECT, ofType: "sh")!
            process.arguments = [project.filename, scheme, configuration.name, derivedData.URL.path, archive.url.path, resultBundle.url.path, log.path]
            process.qualityOfService = .utility
            
            return process
        default:

            let process = Process()
            process.currentDirectoryPath = location.url.path
            process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.ARCHIVE, ofType: "sh")!
            process.arguments = [scheme, configuration.name, derivedData.URL.path, archive.url.path, resultBundle.url.path, log.path]
            process.qualityOfService = .utility
            
            return process
        }
    }
    
    public static func makeExport(location: Project.Location, archive: Archive, exportDirectoryURL: URL, resultBundle: ResultBundle, log: URL) -> Process {
        
        let process = Process()
        process.currentDirectoryPath = location.url.path
        process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.EXPORT, ofType: "sh")!
        process.arguments = [archive.url.path, exportDirectoryURL.path, self.pathForDir("resources"), resultBundle.url.path, log.path]
        process.qualityOfService = .utility
        
        return process
    }
    
    static func makePoll(repositoryLocalURL: Repository.LocalURL, pollDirectoryURL: URL, branch: String = "master") -> Process
    {
        
        let process = Process()
        process.currentDirectoryPath = repositoryLocalURL.path
        process.launchPath = Bundle.main.path(forResource: Scripts.Git.POLL, ofType: "sh")!
        process.arguments = [branch, self.pathForDir("Scripts"), pollDirectoryURL.path]
        process.qualityOfService = .utility
        
        return process
    }
    
    public static func makeBoot(destination: Devices.Destination) -> Process {
        
        let process = Process()
        process.launchPath = Bundle.main.path(forResource: Scripts.Simctl.BOOT, ofType: "sh")!
        process.arguments = [destination.udid ?? ""]
        process.qualityOfService = .background
        
        return process
    }
    
    public static func makeInstall(destination: Devices.Destination, appBundle: AppBundle) -> Process {
        
        let process = Process()
        process.launchPath = Bundle.main.path(forResource: Scripts.Simctl.INSTALL, ofType: "sh")!
        process.arguments = [destination.udid ?? "", appBundle.url.path]
        process.qualityOfService = .background
        
        return process
    }
    
    public static func makeLaunch(destination: Devices.Destination, info: AppBundle.Info) -> Process {
        
        let process = Process()
        process.launchPath = Bundle.main.path(forResource: Scripts.Simctl.LAUNCH, ofType: "sh")!
        process.arguments = [destination.udid ?? "", info.bundleIdentifier]
        process.qualityOfService = .userInitiated
        
        return process
    }
    
    public static func makeRecordVideo(destination: Devices.Destination, file: URL) -> Process {
        
        let process = Process()
        process.launchPath = Bundle.main.path(forResource: Scripts.Simctl.RECORD_VIDEO, ofType: "sh")!
        process.arguments = [destination.udid ?? "", file.path]
        process.qualityOfService = .userInitiated
        
        return process
    }
}


