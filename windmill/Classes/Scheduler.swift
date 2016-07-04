//
//  Scheduler.swift
//  windmill
//
//  Created by Markos Charatzas on 29/09/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import Foundation

protocol SchedulerDelegate: class {
    
    func didLaunch(task: ActivityTask, scheduler: Scheduler)
    
    func didExit(task: ActivityTask, withStatus status: TaskStatus, scheduler: Scheduler)
}

/**

*/
final public class Scheduler
{
    #if DEBUG
    let delayInSeconds = 10
    #else
    let delayInSeconds = 0.5 * 60
    #endif
    
    weak var delegate: SchedulerDelegate?
    
    var key: UInt8 = 0
    var cancel: Bool = true
    
    private func dispatch_block_create_for(queue: dispatch_queue_t, task: ActivityTask, completion: TaskStatusCallback = {status in }) -> dispatch_block_t {
        return dispatch_block_create(dispatch_block_flags_t(0)) {
            
            let cancel = dispatch_queue_get_specific(queue, &self.key)
            
            guard cancel == nil else {
                return
            }
            
            task.launch()
            
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.delegate?.didLaunch(task, scheduler: self)
            }
            
            task.waitUntilExit { status in
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    self.delegate?.didExit(task, withStatus: status, scheduler: self)
                }
                
                completion(task: task, withStatus: status)
                
                if status.value != 0 {
                    dispatch_queue_set_specific(Windmill.dispatch_queue_serial, &self.key, &self.cancel, nil)
                }
            }
        }
    }
    
    func queue(queue: dispatch_queue_t = Windmill.dispatch_queue_serial, tasks: ActivityTask...) {
        for task in tasks {
            dispatch_async(queue, dispatch_block_create_for(queue, task: task))
        }
    }
    
    func schedule(queue: dispatch_queue_t = Windmill.dispatch_queue_serial, task: ActivityTask, completion: TaskStatusCallback)
    {
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(self.delayInSeconds) * Int64(NSEC_PER_SEC))
        
        dispatch_after(when, queue, dispatch_block_create_for(queue, task: task, completion: completion))
    }
}