//
//  NSTasks.swift
//  windmill
//
//  Created by Markos Charatzas on 07/09/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import Foundation
import os

let WINDMILL_BASE_URL_PRODUCTION = "https://api.windmill.io"
let WINDMILL_BASE_URL_DEVELOPMENT = "http://localhost:8080"

#if DEBUG
let WINDMILL_BASE_URL = WINDMILL_BASE_URL_DEVELOPMENT
#else
let WINDMILL_BASE_URL = WINDMILL_BASE_URL_PRODUCTION
#endif

extension Process {
    
    /* fileprivate */ func windmill_waitForDataInBackground(_ pipe: Pipe, queue: DispatchQueue, callback: @escaping (_ data: String, _ count: Int) -> Void) -> DispatchSourceRead {
        
        let fileDescriptor = pipe.fileHandleForReading.fileDescriptor
        let readSource = DispatchSource.makeReadSource(fileDescriptor: fileDescriptor, queue: queue)
        
        readSource.setEventHandler { [weak readSource = readSource] in
            guard let data = readSource?.data else {
                return
            }
            
            let estimated = Int(data)
            
            var buffer = [UInt8](repeating: 0, count: estimated)
            let count = read(fileDescriptor, &buffer, estimated)
            
            guard case let availableData = Data(buffer), count > 0 else {
                return
            }
            
            let availableString = String(data: availableData, encoding: .utf8) ?? ""

            DispatchQueue.main.async {
                callback(availableString, availableString.count)
            }
        }
                
        readSource.activate()
        
        return readSource
    }
}

extension Process
{
    func domain(type: ActivityType) -> String {
        switch type {
        case .showBuildSettings, .devices, .readProjectConfiguration, .checkout, .deploy:
            return WindmillErrorDomain
        case .build, .test, .archive, .export:
            return NSPOSIXErrorDomain
        }
    }
    
    func localizedFailureReason(type: ActivityType, exitStatus: Int32) -> String {
        return NSLocalizedString("windmill.activity.\(type.rawValue).error.failure.reason", comment: "") + "\(exitStatus)"
    }
    
    fileprivate class func pathForDir(_ name: String) -> String! {
        return Bundle.main.path(forResource: name, ofType:nil);
    }
    
    public static func makeReadBuildSettings(repositoryLocalURL: Repository.LocalURL, scheme: String, buildSettings: BuildSettings) -> Process {
        
        let process = Process()
        process.currentDirectoryPath = repositoryLocalURL.path
        process.launchPath = Bundle.main.path(forResource: Scripts.CommandLineTools.READ_BUILD_SETTINGS, ofType: "sh")!
        process.arguments = [buildSettings.url.path, scheme]
        process.qualityOfService = .utility
        
        return process
    }
    
    public static func makeReadProjectConfiguration(repositoryLocalURL: Repository.LocalURL, projectConfiguration: Project.Configuration) -> Process {
        
        let process = Process()
        process.currentDirectoryPath = repositoryLocalURL.path
        process.launchPath = Bundle.main.path(forResource: Scripts.CommandLineTools.READ_PROJECT_CONFIGURATION, ofType: "sh")!
        process.arguments = [projectConfiguration.url.path]
        process.qualityOfService = .utility
        
        return process
    }


    public static func makeReadDevices(repositoryLocalURL: Repository.LocalURL, scheme: String, devices: Devices, buildSettings: BuildSettings) -> Process {
        
        let process = Process()
        process.currentDirectoryPath = repositoryLocalURL.path
        process.launchPath = Bundle.main.path(forResource: Scripts.CommandLineTools.READ_DEVICES, ofType: "sh")!
        process.arguments = [devices.url.path, scheme, buildSettings.url.path, self.pathForDir("Scripts")]
        process.qualityOfService = .utility
        
        return process
    }

    public static func makeCheckout(sourceDirectory: ProjectSourceDirectory, project: Project, branch: String = "master") -> Process {
        
        let process = Process()
        process.launchPath = Bundle.main.path(forResource: Scripts.Git.CHECKOUT, ofType: "sh")!
        process.arguments = [sourceDirectory.URL.path, branch, project.origin, self.pathForDir("Scripts")]
        process.qualityOfService = .utility
        
        return process
    }
    
    public static func makeBuildForTesting(repositoryLocalURL: Repository.LocalURL, scheme: String, configuration: Configuration = .debug, destination: Devices.Destination, derivedDataURL: URL, resultBundle: ResultBundle) -> Process {
        
        let process = Process()
        process.currentDirectoryPath = repositoryLocalURL.path
        process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.BUILD_FOR_TESTING, ofType: "sh")!
        process.arguments = [destination.udid ?? "", scheme, configuration.name, derivedDataURL.path, resultBundle.url.path]
        process.qualityOfService = .utility
        
        return process
    }

    public static func makeBuild(repositoryLocalURL: Repository.LocalURL, scheme: String, configuration: Configuration = .debug, destination: Devices.Destination, derivedDataURL: URL, resultBundle: ResultBundle) -> Process {
        
        let process = Process()
        process.currentDirectoryPath = repositoryLocalURL.path
        process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.BUILD, ofType: "sh")!
        process.arguments = [destination.udid ?? "", scheme, configuration.name, derivedDataURL.path, resultBundle.url.path]
        process.qualityOfService = .utility
        
        return process
    }
    
    static func makeTestWithoutBuilding(repositoryLocalURL: Repository.LocalURL, scheme: String, destination: Devices.Destination, derivedDataURL: URL, resultBundle: ResultBundle) -> Process {
        
        let process = Process()
        process.currentDirectoryPath = repositoryLocalURL.path
        process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.TEST_WITHOUT_BUILDING, ofType: "sh")!
        process.arguments = [destination.udid ?? "", scheme, derivedDataURL.path, resultBundle.url.path]
        process.qualityOfService = .utility
        
        return process
    }
    
    static func makeTestSkip(repositoryLocalURL: Repository.LocalURL, scheme: String, destination: Devices.Destination, derivedDataURL: URL, resultBundle: ResultBundle) -> Process {
        
        let process = Process()
        process.currentDirectoryPath = repositoryLocalURL.path
        process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.TEST_SKIP, ofType: "sh")!
        process.arguments = [destination.udid ?? "", scheme, derivedDataURL.path, resultBundle.url.path]
        process.qualityOfService = .utility
        
        return process
    }
    
    public static func makeArchive(repositoryLocalURL: Repository.LocalURL, scheme: String, configuration: Configuration = .release, derivedDataURL: URL, archive: Archive, resultBundle: ResultBundle) -> Process {
        
        let process = Process()
        process.currentDirectoryPath = repositoryLocalURL.path
        process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.ARCHIVE, ofType: "sh")!
        process.arguments = [scheme, configuration.name, derivedDataURL.path, archive.url.path, resultBundle.url.path]
        process.qualityOfService = .utility
        
        return process
    }
    
    public static func makeExport(repositoryLocalURL: Repository.LocalURL, archive: Archive, exportDirectoryURL: URL, resultBundle: ResultBundle) -> Process {
        
        let process = Process()
        process.currentDirectoryPath = repositoryLocalURL.path
        process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.EXPORT, ofType: "sh")!
        process.arguments = [archive.url.path, exportDirectoryURL.path, self.pathForDir("resources"), resultBundle.url.path]
        process.qualityOfService = .utility
        
        return process
    }
    
    public static func makeDeploy(repositoryLocalURL: Repository.LocalURL, export: Export, forUser user:String) -> Process {
        
        let process = Process()
        process.currentDirectoryPath = repositoryLocalURL.path
        process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.DEPLOY, ofType: "sh")!
        process.arguments = [user, export.url.path, export.manifest.url.path, WINDMILL_BASE_URL]
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
}


