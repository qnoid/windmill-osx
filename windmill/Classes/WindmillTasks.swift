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
class WindmillTasks
{
    private class func pathForDir(name: String!) -> String! {
        return NSBundle.mainBundle().pathForResource(name, ofType:nil);
    }

    class func deployTask(folderName: String, user:String) -> NSTask
    {
        var windmillBaseURL = WINDMILL_BASE_URL_PRODUCTION
        #if DEBUG
            windmillBaseURL = WINDMILL_BASE_URL_DEVELOPMENT
        #endif
            
        let task = NSTask()
        task.launchPath = NSBundle.mainBundle().pathForResource("scripts/checkout", ofType: "sh")!
        task.arguments = [folderName, self.pathForDir("scripts"), self.pathForDir("resources"), user, windmillBaseURL]
        
    return task;
    }

}