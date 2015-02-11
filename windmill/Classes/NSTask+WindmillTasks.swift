//
//  NSTasks.swift
//  windmill
//
//  Created by Markos Charatzas on 07/09/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import Foundation

let WINDMILL_BASE_URL_PRODUCTION = "http://ec2-54-77-169-177.eu-west-1.compute.amazonaws.com"
let WINDMILL_BASE_URL_DEVELOPMENT = "http://localhost:8080"

let ScriptCheckout = "scripts/checkout"
let ScriptPoll = "scripts/poll"

enum TerminationStatus : Int32, Printable
{
    case AlreadyUpToDate = 0
    case Dirty = 1
    
    var description : String {
        switch self{
        case .AlreadyUpToDate:
            return "Already up-to-date."
        case .Dirty:
            return "Dirty"
        }
    }
}

extension NSTask
{
    func waitForStatus() -> TerminationStatus
    {
        self.waitUntilExit()
        return TerminationStatus(rawValue: self.terminationStatus)!
    }

    private class func pathForDir(name: String!) -> String! {
        return NSBundle.mainBundle().pathForResource(name, ofType:nil);
    }

    static func taskDeploy(#localGitRepo: String, forUser user:String) -> NSTask
    {
        var windmillBaseURL = WINDMILL_BASE_URL_PRODUCTION
        #if DEBUG
            windmillBaseURL = WINDMILL_BASE_URL_DEVELOPMENT
        #endif
            
        let task = NSTask()
        task.launchPath = NSBundle.mainBundle().pathForResource(ScriptCheckout, ofType: "sh")!
        task.arguments = [localGitRepo, self.pathForDir("scripts"), self.pathForDir("resources"), user, windmillBaseURL]
        
    return task;
    }
    
    static func taskPoll(localGitRepo: String) -> NSTask
    {
        let task = NSTask()
        task.launchPath = NSBundle.mainBundle().pathForResource(ScriptPoll, ofType: "sh")!
        task.arguments = [localGitRepo, self.pathForDir("scripts"), "master"]
        
    return task;
    }
}