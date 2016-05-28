//
//  Scheduler.swift
//  windmill
//
//  Created by Markos Charatzas on 29/09/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import Foundation

/**

*/
final public class Scheduler
{
    let delayInSeconds = 0.5 * 60
    
    private func dispatch_block_create_for(task: ActivityTask) -> dispatch_block_t {
        return dispatch_block_create(dispatch_block_flags_t(0)) {
            task.launch()
            
            dispatch_async(dispatch_get_main_queue()) {[_activityType = task.activityType, defaultCenter = NSNotificationCenter.defaultCenter()] in
                defaultCenter.postNotification(NSTask.Notifications.taskDidLaunchNotification(_activityType))
            }
            
            task.waitUntilStatus { status in
                dispatch_async(dispatch_get_main_queue()) { [_activityType = task.activityType, defaultCenter = NSNotificationCenter.defaultCenter()] in
                    defaultCenter.postNotification(NSTask.Notifications.taskDidExitNotification(_activityType, terminationStatus: status))
                }
            }
        }
    }
    
    func queue(tasks: ActivityTask...) {
        for task in tasks {
            dispatch_async(Windmill.dispatch_queue_serial, dispatch_block_create_for(task))
        }
    }
    
    func schedule(@autoclosure(escaping) taskProvider taskProvider: TaskProvider, ifDirty callback: () -> Void)
    {
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(self.delayInSeconds) * Int64(NSEC_PER_SEC))
        
        dispatch_after(when, Windmill.dispatch_queue_serial) { [task = taskProvider(), weak self] in
            
            guard let _self = self else {
                return
            }
            
            task.launch()
            
            dispatch_async(dispatch_get_main_queue()) { [_activityType = task.activityType, defaultCenter = NSNotificationCenter.defaultCenter()] in
                defaultCenter.postNotification(NSTask.Notifications.taskDidLaunchNotification(_activityType))
            }
            
            task.waitUntilStatus { status in
             
                dispatch_async(dispatch_get_main_queue()) { [_activityType = task.activityType, defaultCenter = NSNotificationCenter.defaultCenter()] in
                    defaultCenter.postNotification(NSTask.Notifications.taskDidExitNotification(_activityType, terminationStatus: status))
                }
                
                switch status {
                case .AlreadyUpToDate, .Unknown:
                    _self.schedule(taskProvider: taskProvider, ifDirty: callback)
                case .Dirty:
                    callback()
                }
            }
        }
    }
}