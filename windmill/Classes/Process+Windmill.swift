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
        case .buildSettings, .devices, .checkout, .deploy:
            return WindmillErrorDomain
        case .build, .test, .archive, .export:
            return NSPOSIXErrorDomain
        }
    }
    
    func failureDescription(type: ActivityType, exitStatus: Int32) -> String {
        
        switch type {
        case .checkout, .deploy:
            return "Activity '\(String(describing: type.rawValue))' exited with exit code: (\(exitStatus))"
        case .build, .test, .archive, .export:
            return "Command xcodebuild failed with exit code \(exitStatus)"
        case .buildSettings, .devices:
            return "Windmill '\(String(describing: type.rawValue))' failed with exit code: (\(exitStatus))"
        }
    }
    
    fileprivate class func pathForDir(_ name: String) -> String! {
        return Bundle.main.path(forResource: name, ofType:nil);
    }
    
    public static func makeReadBuildSettings(directoryPath: String, forProject project: Project, buildSettings: Metadata) -> Process {
        
        let process = Process()
        process.currentDirectoryPath = directoryPath
        process.launchPath = Bundle.main.path(forResource: Scripts.CommandLineTools.READ_BUILD_SETTINGS, ofType: "sh")!
        process.arguments = [buildSettings.url.path, project.scheme]
        process.qualityOfService = .utility
        
        return process
    }

    public static func makeReadDevices(directoryPath: String, forProject project: Project, devices: Metadata, buildSettings: Metadata) -> Process {
        
        let process = Process()
        process.currentDirectoryPath = directoryPath
        process.launchPath = Bundle.main.path(forResource: Scripts.CommandLineTools.READ_DEVICES, ofType: "sh")!
        process.environment = ["SCRIPTS_ROOT": self.pathForDir("Scripts")]
        process.arguments = [devices.url.path, project.scheme, buildSettings.url.path]
        process.qualityOfService = .utility
        
        return process
    }

    public static func makeCheckout(projectDirectoryURL: URL = ApplicationCachesDirectory().URL, branch: String = "master", repoName: String, origin: String) -> Process {
        
        let process = Process()
        process.currentDirectoryURL = projectDirectoryURL
        process.launchPath = Bundle.main.path(forResource: Scripts.Git.CHECKOUT, ofType: "sh")!
        process.environment = ["SCRIPTS_ROOT": self.pathForDir("Scripts")]
        process.arguments = [repoName, branch, origin]
        process.qualityOfService = .utility
        
        return process
    }
    
    public static func makeBuild(directoryPath: String, project: Project, configuration: Configuration = .debug, devices: Metadata) -> Process {
        
        let process = Process()
        process.currentDirectoryPath = directoryPath
        process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.BUILD, ofType: "sh")!
        process.environment = ["WIDMILL_HOME": FileManager.default.windmillHomeDirectoryURL.path, "BUILD_DIRECTORY_FOR_PROJECT":FileManager.default.buildDirectoryURL(forProject: project.name).path]
        process.arguments = [devices.url.path, project.name, project.scheme, configuration.name]
        process.qualityOfService = .utility
        
        return process
    }
    
    
    static func makeTest(directoryPath: String, project: Project, devices: Metadata) -> Process {
        
        let process = Process()
        process.currentDirectoryPath = directoryPath
        process.environment = ["BUILD_DIRECTORY_FOR_PROJECT":FileManager.default.buildDirectoryURL(forProject: project.name).path]
        process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.TEST, ofType: "sh")!
        process.arguments = [devices.url.path, project.scheme]
        process.qualityOfService = .utility
        
        return process
    }
    
    public static func makeArchive(directoryPath: String, project: Project, configuration: Configuration = .release) -> Process {
        
        let process = Process()
        process.currentDirectoryPath = directoryPath
        process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.ARCHIVE, ofType: "sh")!
        process.environment = ["WIDMILL_HOME": FileManager.default.windmillHomeDirectoryURL.path, "BUILD_DIRECTORY_FOR_PROJECT":FileManager.default.buildDirectoryURL(forProject: project.name).path, "ARCHIVE_DIRECTORY_FOR_PROJECT":FileManager.default.archiveDirectoryURL(forProject: project.name).path]
        process.arguments = [project.name, project.scheme, configuration.name]
        process.qualityOfService = .utility
        
        return process
    }
    
    public static func makeExport(directoryPath: String, project: Project) -> Process {
        
        let process = Process()
        process.currentDirectoryPath = directoryPath
        process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.EXPORT, ofType: "sh")!
        process.environment = ["WIDMILL_HOME": FileManager.default.windmillHomeDirectoryURL.path, "RESOURCES_ROOT": self.pathForDir("resources")]
        process.arguments = [project.name, project.scheme]
        process.qualityOfService = .utility
        
        return process
    }
    
    public static func makeDeploy(directoryPath: String, project: Project, forUser user:String) -> Process {
        
        let process = Process()
        process.currentDirectoryPath = directoryPath
        process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.DEPLOY, ofType: "sh")!
        process.environment = ["WIDMILL_HOME": FileManager.default.windmillHomeDirectoryURL.path, "EXPORT_DIRECTORY_FOR_PROJECT":FileManager.default.exportDirectoryURL(forProject: project.name).path, "WINDMILL_BASE_URL": WINDMILL_BASE_URL]
        process.arguments = [project.scheme, user]
        process.qualityOfService = .utility
        
        return process
    }
    
    static func makePoll(directoryPath: String, projectDirectoryURL: URL = ApplicationCachesDirectory().URL, project: Project, branch: String = "master") -> Process
    {
        let process = Process()
        process.currentDirectoryPath = directoryPath
        process.launchPath = Bundle.main.path(forResource: Scripts.Git.POLL, ofType: "sh")!
        process.environment = ["SCRIPTS_ROOT": self.pathForDir("Scripts"), "POLL_DIRECTORY_FOR_PROJECT": FileManager.default.pollDirectoryURL(forProject: project.name).path]
        process.arguments = [branch]
        process.qualityOfService = .utility
        
        return process
    }
}


