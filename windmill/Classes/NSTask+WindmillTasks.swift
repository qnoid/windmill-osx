//
//  NSTasks.swift
//  windmill
//
//  Created by Markos Charatzas on 07/09/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import Foundation

let WINDMILL_BASE_URL_PRODUCTION = "http://api.windmill.io:8080"
let WINDMILL_BASE_URL_DEVELOPMENT = "http://localhost:8080"

#if DEBUG
let WINDMILL_BASE_URL = WINDMILL_BASE_URL_DEVELOPMENT
#else
let WINDMILL_BASE_URL = WINDMILL_BASE_URL_PRODUCTION
#endif

public protocol TaskError: Error {
    var code: Int { get }
}

public enum CheckoutTaskError: Int, TaskError {
    
    case branchBehindOrigin = 255
    
    public var code: Int {
        return self.rawValue
    }
}

public enum BuildTaskError: Int, TaskError {
    
    /**
     Cases
     
     * scheme not found
     * "The “Swift Language Version” (SWIFT_VERSION) build setting must be set to a supported value for targets which use Swift. This setting can be set in the build settings editor."
     "
     */
    case failed = 65
    
    public var code: Int {
        return self.rawValue
    }
}

public enum TestTaskError: Int, TaskError {
    
    /**
        Causes
     
     * "Test Suite \'(Selected|All) tests\' (failed)"
     * xcodebuild: error: The project named "soldo" does not contain a scheme named "com.soldo.soldo". The "-list" option can be used to find the names of the schemes in the project.
 
    */
    case one = 1
    case failed = 65
    case seventy = 70
    
    /**
 
     2017-06-30 21:39:20.591698+0100 xcodebuild[50470:15852836] [MT] DVTAssertions: ASSERTION FAILURE in /Library/Caches/com.apple.xbs/Sources/IDEFrameworks/IDEFrameworks-13158.29/IDEFoundation/Testing/IDETestRunSession.m:333
     Details:  (testableSummaryFilePath) should not be nil.
 
     */
    case assertionFailure = 134
    
    public var code: Int {
        return self.rawValue
    }
}

public enum ArchiveTaskError: Int, TaskError {
    
    /**
     Cases
     
        * "Code Sign error: No code signing identities found: No valid signing identities (i.e. certificate and private key pair) were found."
        * "Code Sign error: No matching provisioning profiles found: No provisioning profiles matching an applicable signing identity were found."

     */
    case codeSignError = 65
    
    public var code: Int {
        return self.rawValue
    }
}

public enum DeployTaskError: Int, TaskError {
    
    case failedToConnect = 7 //"curl: (7) Failed to connect: Connection refused"
    
    public var code: Int {
        return self.rawValue
    }
}

public enum ExportTaskError : Int, TaskError {
    
    case adHocProvisioningNotFound = 70 //"No matching provisioning profiles found"
    
    public var code: Int {
        return self.rawValue
    }
}

public enum PollTaskError : Int, TaskError {
    
    case fatal = 128 //"ambiguous argument 'master': unknown revision or path not in the working tree. Use '--' to separate paths from revisions, like this: 'git <command> [<revision>...] -- [<file>...]"
    
    case branchBehindOrigin = 255
    
    public var code: Int {
        return self.rawValue
    }
}

enum ActivityType: String, CustomStringConvertible
{
    case Checkout
    case Build
    case Test
    case Archive
    case Export
    case Deploy
    case Poll
    
    var imageName: String {
        switch (self){
        case .Checkout:
            return "windmill-activity-indicator-checkout"
        case .Build:
            return "windmill-activity-indicator-build"
        case .Test:
            return "windmill-activity-indicator-test"
        case .Archive:
            return "windmill-activity-indicator-archive"
        case .Export:
            return "windmill-activity-indicator-archive"
        case .Deploy:
            return "windmill-activity-indicator"
        case .Poll:
            return "windmill-activity-indicator"
        }
    }
    
    var imageNameLights: String {
        switch (self){
        case .Checkout:
            return "lights-checkout"
        case .Build:
            return "lights-build"
        case .Test:
            return "lights-test"
        case .Archive:
            return "lights-archive"
        case .Export:
            return "lights-archive"
        case .Deploy:
            return ""
        case .Poll:
            return ""
        }
    }
    
    
    var description: String {
        switch (self){
        case .Checkout:
            return "checking out"
        case .Build:
            return "building"
        case .Test:
            return "testing"
        case .Archive:
            return "archiving"
        case .Export:
            return "exporting"
        case .Deploy:
            return "deploying"
        case .Poll:
            return "monitoring"
        }
    }
    
    func status(_ terminationStatus: Int) -> TerminationStatus {
        return TerminationStatus(rawValue: terminationStatus) ?? TerminationStatus.unknown
    }
    
    func map(_ terminationStatus: Int) -> Error {
        return NSError.errorTermination(for: self, status: terminationStatus)
    }
}

enum TerminationStatus: Int {
    case succesful = 0
    case unknown
}

protocol ActivityTaskDelegate: class {
 
    func didReceive(_ task: ActivityTask, standardOutput: String, count: Int)
    
    func didReceive(_ task: ActivityTask, standardError: String, count: Int)
}

/**
 
 
 - SeeAlso: Task
 */
protocol ActivityTask {
    
    var activityType: ActivityType { get }
    
    var status: TerminationStatus { get }

    weak var delegate: ActivityTaskDelegate? { get set }

    func launch()
    func waitUntilExit(_ completion: (Error?) -> Void)
    
    func waitForStandardOutputInBackground()
    
    func waitForStandardErrorInBackground()
}

public struct Task: ActivityTask {
    let activityType: ActivityType
    
    var status: TerminationStatus {
        return self.activityType.status(Int(self.task.terminationStatus))
    }
    
    weak var delegate: ActivityTaskDelegate?
    
    let task: Process
    
    init(activityType: ActivityType, task: Process) {
        self.activityType = activityType
        self.task = task
    }
    
    fileprivate func waitForDataInBackground(_ pipe: Pipe, callback: @escaping (_ data: String, _ count: Int) -> Void) {
        
        pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()

        let queue = OperationQueue()
        queue.qualityOfService = .utility
        
        NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: pipe.fileHandleForReading , queue: queue) { notification in
            
            guard let fileHandleForReading = notification.object as? FileHandle else {
                return
            }
            
            guard case let availableData = fileHandleForReading.availableData, availableData.count != 0 else {
                return
            }
            
            let availableString = String(data: availableData, encoding: .utf8) ?? ""
            
            DispatchQueue.main.async {
                callback(availableString, availableData.count)
                fileHandleForReading.waitForDataInBackgroundAndNotify()
            }
        }
    }
    
    func launch() {
        self.task.launch()
    }
    
    func waitUntilExit(_ completion: (Error?) -> Void) {
        self.task.waitUntilExit()
        
        let terminationStatus = Int(self.task.terminationStatus)
        
        if case .succesful = activityType.status(terminationStatus) {
            completion(nil)
        return
        }
        
        completion(self.activityType.map(terminationStatus))
    }
    
    func waitForStandardOutputInBackground() {
        let standardOutputPipe = Pipe()
        self.task.standardOutput = standardOutputPipe
        
        self.waitForDataInBackground(standardOutputPipe) { availableString, count in
            self.delegate?.didReceive(self, standardOutput: availableString, count: count)
        }
    }
    
    func waitForStandardErrorInBackground() {
        let standardErrorPipe = Pipe()
        self.task.standardError = standardErrorPipe
        
        self.waitForDataInBackground(standardErrorPipe){ availableString, count in
            self.delegate?.didReceive(self, standardError: availableString, count: count)
        }
    }
}

extension Process
{
    struct Notifications {
        static let taskDidLaunch = Notification.Name("taskDidLaunch")
        static let taskError = Notification.Name("taskError")
        static let taskDidExit = Notification.Name("taskDidExit")
        
        static func taskDidLaunchNotification(_ type: ActivityType) -> Notification {
            return Notification(name: taskDidLaunch, object: nil, userInfo: ["activity":type.rawValue])
        }
        static func taskDErrorNotification(_ type: ActivityType) -> Notification {
            return Notification(name: taskError, object: nil, userInfo: ["activity":type.rawValue])
        }
        static func taskDidExitNotification(_ type: ActivityType) -> Notification {
            return Notification(name: taskDidExit, object: nil, userInfo: ["activity":type.rawValue])
        }
    }
    
    fileprivate class func pathForDir(_ name: String) -> String! {
        return Bundle.main.path(forResource: name, ofType:nil);
    }
    
    public static func taskCheckout(_ repoName: String, origin: String) -> Task {
        
        let task = Process()
        task.launchPath = Bundle.main.path(forResource: Scripts.Git.CHECKOUT, ofType: "sh")!
        task.arguments = [repoName, origin, self.pathForDir("scripts")]
        
        return Task(activityType: ActivityType.Checkout, task: task)
    }
    
    public static func taskBuild(directoryPath: String, scheme: String) -> Task {
        
        let task = Process()
        task.currentDirectoryPath = directoryPath
        task.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.BUILD, ofType: "sh")!
        task.arguments = [scheme]
        
        return Task(activityType: ActivityType.Build, task: task)
    }
    
    
    public static func taskTest(directoryPath: String, scheme: String, simulatorName: String = "iPhone 4s") -> Task {
        
        let task = Process()
        task.currentDirectoryPath = directoryPath
        task.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.TEST, ofType: "sh")!
        task.arguments = [scheme, simulatorName]
        
        return Task(activityType: ActivityType.Test, task: task)
    }
    
    public static func taskArchive(directoryPath: String, scheme: String, projectName name: String) -> Task {
        
        let task = Process()
        task.currentDirectoryPath = directoryPath
        task.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.ARCHIVE, ofType: "sh")!
        task.arguments = [scheme, name, self.pathForDir("resources")]
        
        return Task(activityType: ActivityType.Archive, task: task)
    }
    
    public static func taskExport(directoryPath: String, projectName name: String) -> Task {
        
        let task = Process()
        task.currentDirectoryPath = directoryPath
        task.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.EXPORT, ofType: "sh")!
        task.arguments = [name, self.pathForDir("resources")]
        
        return Task(activityType: ActivityType.Export, task: task)
    }
    
    public static func taskDeploy(directoryPath: String, projectName name: String, forUser user:String) -> Task {
        
        let task = Process()
        task.currentDirectoryPath = directoryPath
        task.launchPath = Bundle.main.path(forResource: Scripts.Xcodebuild.DEPLOY, ofType: "sh")!
        task.arguments = [name, user, WINDMILL_BASE_URL]
        
        return Task(activityType: ActivityType.Deploy, task: task)
    }
    
    static func taskPoll(_ repoName: String, branch: String = "master") -> Task
    {
        let task = Process()
        task.launchPath = Bundle.main.path(forResource: Scripts.Git.POLL, ofType: "sh")!
        task.arguments = [repoName, self.pathForDir("scripts"), branch]
        
        return Task(activityType: ActivityType.Poll, task: task);
    }
}
