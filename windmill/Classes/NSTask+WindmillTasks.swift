//
//  NSTasks.swift
//  windmill
//
//  Created by Markos Charatzas on 07/09/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import Foundation

let WINDMILL_BASE_URL_PRODUCTION = "http://ec2-52-50-52-225.eu-west-1.compute.amazonaws.com"
let WINDMILL_BASE_URL_DEVELOPMENT = "http://localhost:8080"

#if DEBUG
let WINDMILL_BASE_URL = WINDMILL_BASE_URL_DEVELOPMENT
#else
let WINDMILL_BASE_URL = WINDMILL_BASE_URL_PRODUCTION
#endif

let ScriptOnCommit = "scripts/on_commit"
let ScriptNightly = "scripts/nightly"
let ScriptPoll = "scripts/poll"

public enum TerminationStatus : Int, CustomStringConvertible
{
    case AlreadyUpToDate = 0
    case Dirty = 1
    
    public var description : String {
        switch self{
        case .AlreadyUpToDate:
            return "Already up-to-date."
        case .Dirty:
            return "Dirty"
        }
    }
}

struct TaskNightly
{
    enum TerminationStatus : Int32, CustomStringConvertible
    {
        case Success = 0
        case Error = 1
        
        var description : String {
            switch self{
            case .Success:
                return "Successfuly deployed IPA."
            case .Error:
                return "Error deploying IPA"
            }
        }
    }
}

enum TaskType: String
{
    case Checkout
    case Build
    case Test
    case Package
    case Deploy
    case Nightly
    
    var imageName: String {
        switch (self){
        case .Checkout:
            return "windmill-activity-indicator-checkout"
        case .Build:
            return "windmill-activity-indicator-build"
        case .Test:
            return "windmill-activity-indicator-test"
        case .Package:
            return "windmill-activity-indicator-package"
        case .Deploy:
            return "windmill-activity-indicator"
        case .Nightly:
            return "Nightly"
        }
    }
}

typealias TaskProvider = () -> NSTask

extension NSTask
{
    struct Notifications {
        static let taskDidLaunch = "taskDidLaunch"
        static let taskDidExit = "taskDidExit"
        
        static func taskDidLaunchNotification(userInfo: [String: AnyObject] ) -> NSNotification {
            return NSNotification(name: taskDidLaunch, object: nil, userInfo: userInfo)
        }
        static func taskDidExitNotification(type: TaskType, terminationStatus: TerminationStatus) -> NSNotification {
            return NSNotification(name: taskDidExit, object: nil, userInfo: ["type":type.rawValue, "status":terminationStatus.rawValue])
        }
    }
    
    private class func pathForDir(name: String) -> String! {
        return NSBundle.mainBundle().pathForResource(name, ofType:nil);
    }

    /**

    :directoryPath:
    :buildProjectWithName:
    :scheme:
    */
    public static func taskBuild(directoryPath directoryPath: String, scheme: String) -> NSTask
    {
        let task = NSTask()
        task.currentDirectoryPath = directoryPath        
        task.launchPath = NSBundle.mainBundle().pathForResource(Xcodebuild.Development.BUILD, ofType: "sh")!
        task.arguments = [scheme]
        
        return task;
    }

    public static func taskCheckout(repoName: String, origin: String) -> NSTask {
        
        let task = NSTask()
        task.launchPath = NSBundle.mainBundle().pathForResource(Git.Development.CHECKOUT, ofType: "sh")!
        task.arguments = [repoName, origin, self.pathForDir("scripts")]
        
        return task;
    }

    public static func taskTest(directoryPath directoryPath: String, scheme: String, simulatorName: String = "iPhone 4s") -> NSTask {
        
        let task = NSTask()
        task.currentDirectoryPath = directoryPath
        task.launchPath = NSBundle.mainBundle().pathForResource(Xcodebuild.Development.TEST, ofType: "sh")!
        task.arguments = [scheme, simulatorName]
        
        return task;
    }

    public static func taskPackage(directoryPath directoryPath: String, projectName name: String) -> NSTask {
        
        let task = NSTask()
        task.currentDirectoryPath = directoryPath
        task.launchPath = NSBundle.mainBundle().pathForResource(Xcodebuild.Development.PACKAGE, ofType: "sh")!
        task.arguments = [name, self.pathForDir("resources")]
        
        return task;
    }

    public static func taskDeploy(directoryPath directoryPath: String, projectName name: String, forUser user:String) -> NSTask {
        
        let task = NSTask()
        task.currentDirectoryPath = directoryPath
        task.launchPath = NSBundle.mainBundle().pathForResource(Xcodebuild.Development.DEPLOY, ofType: "sh")!
        task.arguments = [name, user, WINDMILL_BASE_URL]
        
        return task;
    }

    static func taskOnCommit(repoName: String, origin: String) -> NSTask {
        
        let task = NSTask()
        task.launchPath = NSBundle.mainBundle().pathForResource(ScriptOnCommit, ofType: "sh")!
        task.arguments = [repoName, origin, self.pathForDir("scripts")]
        
        return task
    }
    
    static func taskNightly(repoName: String, origin: String, forUser user:String) -> NSTask
    {
        var windmillBaseURL = WINDMILL_BASE_URL_PRODUCTION
        #if DEBUG
            windmillBaseURL = WINDMILL_BASE_URL_DEVELOPMENT
        #endif
            
        let task = NSTask()
        task.launchPath = NSBundle.mainBundle().pathForResource(ScriptNightly, ofType: "sh")!
        task.arguments = [repoName, origin, self.pathForDir("scripts"), self.pathForDir("resources"), user, windmillBaseURL]
        
    return task
    }
    
    static func taskPoll(repoName: String) -> NSTask
    {
        let task = NSTask()
        task.launchPath = NSBundle.mainBundle().pathForResource(ScriptPoll, ofType: "sh")!
        task.arguments = [repoName, self.pathForDir("scripts"), "master"]
        
    return task;
    }
    
    public func waitUntilStatus() -> TerminationStatus
    {
        self.waitUntilExit()
        return TerminationStatus(rawValue: Int(self.terminationStatus))!
    }
    
    func whenExit(block: (TerminationStatus) -> Void)
    {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) { [self]
 
            let status = self.waitUntilStatus()
            
            dispatch_async(dispatch_get_main_queue()) {
                block(status)
            }
        }
    }
}