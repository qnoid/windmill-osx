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
}

typealias TaskProvider = () -> Task

protocol ActivityTask {
    var activityType: ActivityType { get }
    
    func launch()
    func waitUntilStatus(block: (TerminationStatus) -> Void)
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
    
    
    func waitUntilStatus(block: (TerminationStatus) -> Void) {
        let status = self.task.waitUntilStatus()
        block(status)
    }

}

extension NSTask
{
    struct Notifications {
        static let taskDidLaunch = "taskDidLaunch"
        static let taskDidExit = "taskDidExit"

        static func taskDidLaunchNotification(type: ActivityType) -> NSNotification {
            return NSNotification(name: taskDidLaunch, object: nil, userInfo: ["activity":type.rawValue])
        }
        static func taskDidExitNotification(type: ActivityType, terminationStatus: TerminationStatus) -> NSNotification {
            return NSNotification(name: taskDidExit, object: nil, userInfo: ["activity":type.rawValue, "status":terminationStatus.rawValue])
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
    
    public func waitUntilStatus() -> TerminationStatus {
        
        self.waitUntilExit()
        return TerminationStatus(rawValue: Int(self.terminationStatus))!
    }
}