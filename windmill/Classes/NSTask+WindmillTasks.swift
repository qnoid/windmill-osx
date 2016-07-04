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

public protocol TaskStatus : CustomStringConvertible {
    var value: Int { get }
}

extension TaskStatus {
    public var description : String {
        switch self.value {
        case 0:
            return "OK"
        default:
            return "unknown"
        }
    }
}

public enum CheckoutTaskStatus: Int, TaskStatus {
    
    case Unknown = -1
    case Success = 0
    
    public var value: Int {
        return self.rawValue
    }
}

public enum BuildTaskStatus: Int, TaskStatus {
    
    case Unknown = -1
    case Success = 0
    
    public var value: Int {
        return self.rawValue
    }
}

public enum TestTaskStatus: Int, TaskStatus {
    
    case Unknown = -1
    case OK = 0
    case Failed = 65
    
    public var value: Int {
        return self.rawValue
    }
    
    public var description: String {
        switch self{
        case .Unknown:
            return "unknown"
        case .OK:
            return "OK"
        case .Failed:
            return "Test Suite \'(Selected|All) tests\' (failed)"
        }
    }
}

public enum ArchiveTaskStatus: Int, TaskStatus {
    
    case Unknown = -1
    case OK = 0
    case CodeSignError = 65
    
    public var value: Int {
        return self.rawValue
    }
    
    public var description: String {
        switch self{
        case .Unknown:
            return "unknown"
        case .OK:
            return "OK"
        case .CodeSignError:
            return "Code Sign error: No code signing identities found: No valid signing identities (i.e. certificate and private key pair) were found."
        }
    }
}

public enum DeployTaskStatus : Int, TaskStatus {
    
    case Unknown = -1
    case Success = 0
    case Error = 1
    
    public var value: Int {
        return self.rawValue
    }

    public var description : String {
        switch self{
        case .Success:
            return "Successfuly deployed IPA."
        case .Error:
            return "Error deploying IPA"
        default:
            return "Unknown"
        }
    }
}

public enum PollTaskStatus : Int, TaskStatus
{
    case Unknown = -1
    case AlreadyUpToDate = 0
    case Dirty = 1
    
    public var value: Int {
        return self.rawValue
    }

    public var description : String {
        switch self{
        case .AlreadyUpToDate:
            return "Already up-to-date."
        case .Dirty:
            return "Dirty"
        default:
            return "Unknown"
        }
    }
}

enum ActivityType: String, CustomStringConvertible
{
    case Checkout
    case Build
    case Test
    case Archive
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
        case .Deploy:
            return "deploying"
        case .Poll:
            return "monitoring"
        }
    }
    
    func map(terminationStatus: Int) -> TaskStatus {
        
        switch (self, terminationStatus){
        case (.Checkout, let status):
            if let status =  CheckoutTaskStatus(rawValue: status) {
                return status
            }
            
            debugPrint("WARN: \(__FILE__):\(__FUNCTION__):\(__LINE__) unknown checkout status: \(status)")
            return CheckoutTaskStatus.Unknown
        case (.Build, let status):
            if let status =  BuildTaskStatus(rawValue: status) {
                return status
            }
            
            debugPrint("WARN: \(__FILE__):\(__FUNCTION__):\(__LINE__) unknown build status: \(status)")
            return BuildTaskStatus.Unknown

        case (.Test, let status):
            if let status =  TestTaskStatus(rawValue: status) {
                return status
            }
            
            debugPrint("WARN: \(__FILE__):\(__FUNCTION__):\(__LINE__) unknown test status: \(status)")
            return TestTaskStatus.Unknown

        case (.Archive, let status):
            if let status =  ArchiveTaskStatus(rawValue: status) {
                return status
            }
            
            debugPrint("WARN: \(__FILE__):\(__FUNCTION__):\(__LINE__) unknown archive status: \(status)")
            return ArchiveTaskStatus.Unknown

        case (.Deploy, let status):
            if let status =  DeployTaskStatus(rawValue: status) {
                return status
            }
            
            debugPrint("WARN: \(__FILE__):\(__FUNCTION__):\(__LINE__) unknown deploy status: \(status)")
            return DeployTaskStatus.Unknown
        case (.Poll, let status):
            if let status =  PollTaskStatus(rawValue: status) {
                return status
            }

            debugPrint("WARN: \(__FILE__):\(__FUNCTION__):\(__LINE__) unknown poll status: \(status)")
            return PollTaskStatus.Unknown
        }
    }
}

typealias TaskStatusCallback = (task: ActivityTask, withStatus: TaskStatus) -> Void
typealias ExitStatus = (TaskStatus) -> Void

protocol ActivityTask {
    var activityType: ActivityType { get }
    
    func launch()
    func waitUntilExit(callback: ExitStatus)
}

public struct Task: ActivityTask {
    let activityType: ActivityType
    let task: NSTask
    
    init(activityType: ActivityType, task: NSTask) {
        self.activityType = activityType
        self.task = task
    }
    
    func launch() {
        self.task.launch()
    }
    
    func waitUntilExit(callback: ExitStatus) {
        self.task.waitUntilExit()
        
        let terminationStatus = Int(self.task.terminationStatus)
        
        callback(self.activityType.map(terminationStatus))
    }
    
}

extension NSTask
{
    struct Notifications {
        static let taskDidLaunch = "taskDidLaunch"
        static let taskError = "taskError"
        static let taskDidExit = "taskDidExit"
        
        static func taskDidLaunchNotification(type: ActivityType) -> NSNotification {
            return NSNotification(name: taskDidLaunch, object: nil, userInfo: ["activity":type.rawValue])
        }
        static func taskDErrorNotification(type: ActivityType) -> NSNotification {
            return NSNotification(name: taskError, object: nil, userInfo: ["activity":type.rawValue])
        }
        static func taskDidExitNotification(type: ActivityType, terminationStatus: TaskStatus) -> NSNotification {
            return NSNotification(name: taskDidExit, object: nil, userInfo: ["activity":type.rawValue])
        }
    }
    
    private class func pathForDir(name: String) -> String! {
        return NSBundle.mainBundle().pathForResource(name, ofType:nil);
    }
    
    public static func taskCheckout(repoName: String, origin: String) -> Task {
        
        let task = NSTask()
        task.launchPath = NSBundle.mainBundle().pathForResource(Scripts.Git.CHECKOUT, ofType: "sh")!
        task.arguments = [repoName, origin, self.pathForDir("scripts")]
        
        return Task(activityType: ActivityType.Checkout, task: task)
    }
    
    public static func taskBuild(directoryPath directoryPath: String, scheme: String) -> Task {
        
        let task = NSTask()
        task.currentDirectoryPath = directoryPath
        task.launchPath = NSBundle.mainBundle().pathForResource(Scripts.Xcodebuild.BUILD, ofType: "sh")!
        task.arguments = [scheme]
        
        return Task(activityType: ActivityType.Build, task: task)
    }
    
    
    public static func taskTest(directoryPath directoryPath: String, scheme: String, simulatorName: String = "iPhone 4s") -> Task {
        
        let task = NSTask()
        task.currentDirectoryPath = directoryPath
        task.launchPath = NSBundle.mainBundle().pathForResource(Scripts.Xcodebuild.TEST, ofType: "sh")!
        task.arguments = [scheme, simulatorName]
        
        return Task(activityType: ActivityType.Test, task: task)
    }
    
    public static func taskArchive(directoryPath directoryPath: String, projectName name: String) -> Task {
        
        let task = NSTask()
        task.currentDirectoryPath = directoryPath
        task.launchPath = NSBundle.mainBundle().pathForResource(Scripts.Xcodebuild.ARCHIVE, ofType: "sh")!
        task.arguments = [name, self.pathForDir("resources")]
        
        return Task(activityType: ActivityType.Archive, task: task)
    }
    
    public static func taskDeploy(directoryPath directoryPath: String, projectName name: String, forUser user:String) -> Task {
        
        let task = NSTask()
        task.currentDirectoryPath = directoryPath
        task.launchPath = NSBundle.mainBundle().pathForResource(Scripts.Xcodebuild.DEPLOY, ofType: "sh")!
        task.arguments = [name, user, WINDMILL_BASE_URL]
        
        return Task(activityType: ActivityType.Deploy, task: task)
    }
    
    static func taskPoll(repoName: String) -> Task
    {
        let task = NSTask()
        task.launchPath = NSBundle.mainBundle().pathForResource(Scripts.Git.POLL, ofType: "sh")!
        task.arguments = [repoName, self.pathForDir("scripts"), "master"]
        
        return Task(activityType: ActivityType.Poll, task: task);
    }
}