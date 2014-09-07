//
//  NSTasks.swift
//  windmill
//
//  Created by Markos Charatzas on 07/09/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import Foundation

class WindmillTasks
{
    private class func pathForDir(name: String!) -> String! {
        return NSBundle.mainBundle().pathForResource(name, ofType:nil);
    }

    class func deployTask(folderName: String, user:String) -> NSTask
    {
        let task = NSTask()
        task.launchPath = NSBundle.mainBundle().pathForResource("scripts/checkout", ofType: "sh")!
        task.arguments = [folderName, self.pathForDir("scripts"), self.pathForDir("resources"), user]
        
    return task;
    }

}