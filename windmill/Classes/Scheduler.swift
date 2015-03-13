//
//  Scheduler.swift
//  windmill
//
//  Created by Markos Charatzas on 29/09/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import Foundation

typealias TaskProvider = () -> NSTask

/**

*/
final public class Scheduler
{
    static var dispatch_queue_global_utility : dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.value), 0)
    }

    static var dispatch_queue_serial : dispatch_queue_t {
        return dispatch_queue_create("io.windmil.queue", DISPATCH_QUEUE_SERIAL)
    }

    let delayInSeconds = 0.5 * 60
    let operationQueue : NSOperationQueue
    
    required public init()
    {
        self.operationQueue = NSOperationQueue()
        self.operationQueue.qualityOfService = .UserInitiated
    }
    
    func queue(task: NSTask)
    {        
        self.operationQueue.addOperationWithBlock {
            task.launch()
        }
    }
    
    func schedule(taskProvider: TaskProvider)(ifDirty callback: () -> Void)
    {
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(self.delayInSeconds * Double(NSEC_PER_SEC)))
        
        let task = taskProvider()
        
        dispatch_after(when, Scheduler.dispatch_queue_serial) {
            
            task.launch()
            let terminationStatus = task.waitForStatus()
            
            switch terminationStatus
            {
            case .AlreadyUpToDate:
                self.schedule(taskProvider)(ifDirty: callback)
            case .Dirty:
                callback()
            }
        }
    }
}