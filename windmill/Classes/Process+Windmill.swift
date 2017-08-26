//
//  NSTasks.swift
//  windmill
//
//  Created by Markos Charatzas on 07/09/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import Foundation
import os

let WINDMILL_BASE_URL_PRODUCTION = "http://api.windmill.io:8080"
let WINDMILL_BASE_URL_DEVELOPMENT = "http://localhost:8080"

#if DEBUG
let WINDMILL_BASE_URL = WINDMILL_BASE_URL_DEVELOPMENT
#else
let WINDMILL_BASE_URL = WINDMILL_BASE_URL_PRODUCTION
#endif

extension Process {
    
    /* fileprivate */ func windmill_waitForDataInBackground(_ pipe: Pipe, queue: DispatchQueue, callback: @escaping (_ data: String, _ count: Int) -> Void) {
        
        let fileDescriptor = pipe.fileHandleForReading.fileDescriptor
        let readSource = DispatchSource.makeReadSource(fileDescriptor: fileDescriptor, queue: queue)
        
        readSource.setEventHandler {
            let estimated = Int(readSource.data)
            
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
        
        readSource.setCancelHandler {
            close(fileDescriptor)
        }
        
        readSource.activate()
    }
}

extension Windmill {
    
    func waitForStandardOutputInBackground(process: Process, queue: DispatchQueue, type: ActivityType) {
        let standardOutputPipe = Pipe()
        process.standardOutput = standardOutputPipe
        
        process.windmill_waitForDataInBackground(standardOutputPipe, queue: queue) { [weak process, weak self] availableString, count in
            guard let process = process else {
                return
            }
            
            self?.didReceive(process: process, type: type, standardOutput: availableString, count: count)
        }
    }
    
    func waitForStandardErrorInBackground(process: Process, queue: DispatchQueue, type: ActivityType) {
        let standardErrorPipe = Pipe()
        process.standardError = standardErrorPipe
        
        process.windmill_waitForDataInBackground(standardErrorPipe, queue: queue){ [weak process, weak self] availableString, count in
            guard let process = process else {
                return
            }

            self?.didReceive(process: process, type: type, standardError: availableString, count: count)
        }
    }
}

extension Process
{
    struct Notifications {
        static let activityDidLaunch = Notification.Name("activityDidLaunch")
        static let activityError = Notification.Name("activityError")
        static let activityDidExitSuccesfully = Notification.Name("activityDidExitSuccesfully")
        
        static func makeDidLaunchNotification(_ type: ActivityType) -> Notification {
            return Notification(name: activityDidLaunch, object: nil, userInfo: ["activity":type.rawValue])
        }
        static func makeErrorNotification(_ type: ActivityType) -> Notification {
            return Notification(name: activityError, object: nil, userInfo: ["activity":type.rawValue])
        }
        static func makeDidExitSuccesfullyNotification(_ type: ActivityType) -> Notification {
            return Notification(name: activityDidExitSuccesfully, object: nil, userInfo: ["activity":type.rawValue])
        }
    }
    
    fileprivate class func pathForDir(_ name: String) -> String! {
        return Bundle.main.path(forResource: name, ofType:nil);
    }
    
    public static func makeCheckout(windmillHomeDirectoryURL: URL = FileManager.default.windmillHomeDirectoryURL, repoName: String, origin: String) -> Process {
        
        let process = Process()
        process.launchPath = Bundle.main.path(forResource: Scripts.Git.CHECKOUT, ofType: "sh")!
        process.arguments = [windmillHomeDirectoryURL.path, repoName, origin, self.pathForDir("scripts")]
        process.qualityOfService = .utility
        
        return process
    }
    
    public static func makeBuild(directoryPath: String, scheme: String) -> Process {
        
        let process = Process()
        process.currentDirectoryPath = directoryPath
        process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.BUILD, ofType: "sh")!
        process.arguments = [scheme]
        
        return process
    }
    
    
    public static func makeTest(directoryPath: String, scheme: String) -> Process {
        
        let process = Process()
        process.currentDirectoryPath = directoryPath
        process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.TEST, ofType: "sh")!
        process.arguments = [scheme]
        
        return process
    }
    
    public static func makeArchive(directoryPath: String, scheme: String, projectName name: String) -> Process {
        
        let process = Process()
        process.currentDirectoryPath = directoryPath
        process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.ARCHIVE, ofType: "sh")!
        process.arguments = [scheme, name, self.pathForDir("resources")]
        
        return process
    }
    
    public static func makeExport(directoryPath: String, scheme: String) -> Process {
        
        let process = Process()
        process.currentDirectoryPath = directoryPath
        process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.EXPORT, ofType: "sh")!
        process.arguments = [scheme, self.pathForDir("resources")]
        
        return process
    }
    
    public static func makeDeploy(directoryPath: String, scheme: String, forUser user:String) -> Process {
        
        let process = Process()
        process.currentDirectoryPath = directoryPath
        process.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.DEPLOY, ofType: "sh")!
        process.arguments = [scheme, user, WINDMILL_BASE_URL]
        
        return process
    }
    
    static func makePoll(_ repoName: String, branch: String = "master") -> Process
    {
        let process = Process()
        process.launchPath = Bundle.main.path(forResource: Scripts.Git.POLL, ofType: "sh")!
        process.arguments = [FileManager.default.windmillHomeDirectoryURL.path, repoName, self.pathForDir("scripts"), branch]
        
        return process
    }
}


