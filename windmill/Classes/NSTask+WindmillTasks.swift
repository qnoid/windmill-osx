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

public protocol TaskError: ErrorType {
    var code: Int { get }
}

public enum BuildTaskError: Int, TaskError {
    
    case SchemeNotFound = 65
    
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
    case One = 1
    case Failed = 65
    case Seventy = 70
    
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
    case CodeSignError = 65
    
    public var code: Int {
        return self.rawValue
    }
}

public enum DeployTaskError: Int, TaskError {
    
    case FailedToConnect = 7 //"curl: (7) Failed to connect: Connection refused"
    
    public var code: Int {
        return self.rawValue
    }
}

public enum ExportTaskError : Int, TaskError {
    
    case AdHocProvisioningNotFound = 70 //"No matching provisioning profiles found"
    
    public var code: Int {
        return self.rawValue
    }
}

public enum PollTaskError : Int, TaskError {
    
    case Fatal = 128 //"ambiguous argument 'master': unknown revision or path not in the working tree. Use '--' to separate paths from revisions, like this: 'git <command> [<revision>...] -- [<file>...]"
    
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
    
    func status(terminationStatus: Int) -> ActivityTaskStatus? {
        return ActivityTaskStatus(rawValue: terminationStatus) ?? nil
    }
    
    func map(terminationStatus: Int) -> TaskError? {
        
        switch (self, terminationStatus){
        case (.Checkout, let code):
            debugPrint("WARN: \(#file):\(#function):\(#line) unknown checkout code: \(code)")
            return nil
        case (.Build, let code):
            if let code =  BuildTaskError(rawValue: code) {
                return code
            }
            
            debugPrint("WARN: \(#file):\(#function):\(#line) unknown build code: \(code)")
            return nil
        case (.Test, let code):
            if let code =  TestTaskError(rawValue: code) {
                return code
            }
            
            debugPrint("WARN: \(#file):\(#function):\(#line) unknown test code: \(code)")
            return nil
        case (.Archive, let code):
            if let code =  ArchiveTaskError(rawValue: code) {
                return code
            }
            
            debugPrint("WARN: \(#file):\(#function):\(#line) unknown archive code: \(code)")
            return nil
        case (.Export, let code):
            if let error =  ExportTaskError(rawValue: code) {
                return error
            }
            
            debugPrint("WARN: \(#file):\(#function):\(#line) unknown export code: \(code)")
            return nil
        case (.Deploy, let code):
            if let code =  DeployTaskError(rawValue: code) {
                return code
            }
            
            debugPrint("WARN: \(#file):\(#function):\(#line) unknown deploy status: \(code)")
            return nil
        case (.Poll, let code):
            if let code =  PollTaskError(rawValue: code) {
                return code
            }
            
            debugPrint("WARN: \(#file):\(#function):\(#line) unknown poll code: \(code)")
            return nil
        }
    }
}

enum ActivityTaskStatus: Int {
    case Succesful = 0
    case BranchBehindOrigin = 255
}

protocol ActivityTaskDelegate: class {
 
    func didReceive(task: ActivityTask, standardOutput: String)
    
    func didReceive(task: ActivityTask, standardError: String)
}

protocol ActivityTask {
    
    var activityType: ActivityType { get }
    
    var status: ActivityTaskStatus? { get }

    weak var delegate: ActivityTaskDelegate? { get set }

    func launch()
    func waitUntilExit(completion: (TaskError?) -> Void)
    
    func waitForStandardOutputInBackground()
    
    func waitForStandardErrorInBackground()
}

public struct Task: ActivityTask {
    let activityType: ActivityType
    
    var status: ActivityTaskStatus? {
        return self.activityType.status(Int(self.task.terminationStatus))
    }
    
    weak var delegate: ActivityTaskDelegate?
    
    let task: NSTask
    
    init(activityType: ActivityType, task: NSTask) {
        self.activityType = activityType
        self.task = task
    }
    
    private func waitForDataInBackground(pipe: NSPipe, callback: (data: String) -> Void) {
        
        pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()

        let queue = NSOperationQueue()
        queue.qualityOfService = .UserInitiated
        
        var observer: AnyObject!
        
        observer = NSNotificationCenter.defaultCenter().addObserverForName(NSFileHandleDataAvailableNotification, object: pipe.fileHandleForReading , queue: queue) { [weak fileHandleForReading = pipe.fileHandleForReading] notification in
            
            guard let _fileHandleForReading = fileHandleForReading else {
                return
            }
            
            guard case let availableData = _fileHandleForReading.availableData where availableData.length != 0 else {
                NSNotificationCenter.defaultCenter().removeObserver(observer)
                return
            }
            
            let availableString = String(data: availableData, encoding: NSUTF8StringEncoding) ?? ""
            
            dispatch_async(dispatch_get_main_queue()){
                callback(data: availableString)
                _fileHandleForReading.waitForDataInBackgroundAndNotify()
            }
        }
    }
    
    func launch() {
        self.task.launch()
    }
    
    func waitUntilExit(completion: (TaskError?) -> Void) {
        self.task.waitUntilExit()
        
        let terminationStatus = Int(self.task.terminationStatus)
        
        if case ActivityTaskStatus.Succesful? = ActivityTaskStatus(rawValue: terminationStatus) {
            completion(nil)
        return
        }
        
        completion(self.activityType.map(terminationStatus))
    }
    
    func waitForStandardOutputInBackground() {
        let standardOutputPipe = NSPipe()
        self.task.standardOutput = standardOutputPipe
        
        self.waitForDataInBackground(standardOutputPipe) { availableString in
            self.delegate?.didReceive(self, standardOutput: availableString)
        }
    }
    
    func waitForStandardErrorInBackground() {
        let standardErrorPipe = NSPipe()
        self.task.standardError = standardErrorPipe
        
        self.waitForDataInBackground(standardErrorPipe){ availableString in
            self.delegate?.didReceive(self, standardError: availableString)
        }
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
        static func taskDidExitNotification(type: ActivityType) -> NSNotification {
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
    
    public static func taskArchive(directoryPath directoryPath: String, scheme: String, projectName name: String) -> Task {
        
        let task = NSTask()
        task.currentDirectoryPath = directoryPath
        task.launchPath = NSBundle.mainBundle().pathForResource(Scripts.Xcodebuild.ARCHIVE, ofType: "sh")!
        task.arguments = [scheme, name, self.pathForDir("resources")]
        
        return Task(activityType: ActivityType.Archive, task: task)
    }
    
    public static func taskExport(directoryPath directoryPath: String, projectName name: String) -> Task {
        
        let task = NSTask()
        task.currentDirectoryPath = directoryPath
        task.launchPath = NSBundle.mainBundle().pathForResource(Scripts.Xcodebuild.EXPORT, ofType: "sh")!
        task.arguments = [name, self.pathForDir("resources")]
        
        return Task(activityType: ActivityType.Export, task: task)
    }
    
    public static func taskDeploy(directoryPath directoryPath: String, projectName name: String, forUser user:String) -> Task {
        
        let task = NSTask()
        task.currentDirectoryPath = directoryPath
        task.launchPath = NSBundle.mainBundle().pathForResource(Scripts.Xcodebuild.DEPLOY, ofType: "sh")!
        task.arguments = [name, user, WINDMILL_BASE_URL]
        
        return Task(activityType: ActivityType.Deploy, task: task)
    }
    
    static func taskPoll(repoName: String, branch: String = "master") -> Task
    {
        let task = NSTask()
        task.launchPath = NSBundle.mainBundle().pathForResource(Scripts.Git.POLL, ofType: "sh")!
        task.arguments = [repoName, self.pathForDir("scripts"), branch]
        
        return Task(activityType: ActivityType.Poll, task: task);
    }
}
