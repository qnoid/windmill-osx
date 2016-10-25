//
//  Scheduler.swift
//  windmill
//
//  Created by Markos Charatzas on 29/09/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import Foundation

protocol SchedulerDelegate: class {
    
    func willLaunch(task: ActivityTask, scheduler: Scheduler)
    
    func didLaunch(task: ActivityTask, scheduler: Scheduler)
    
    func didExit(task: ActivityTask, error: TaskError?, scheduler: Scheduler)
}

typealias TaskCompletionBlock = (task: ActivityTask, error: TaskError?) -> Void
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
    var error: Bool = true
    
    private func willLaunch(task: ActivityTask) {
        self.delegate?.willLaunch(task, scheduler: self)
    }
    
    private func didLaunch(task: ActivityTask) {
        self.delegate?.didLaunch(task, scheduler: self)
    }
    
    private func didExit(task: ActivityTask, error: TaskError?) {
        self.delegate?.didExit(task, error: error, scheduler: self)
    }
    
    private func dispatch_block_create_for(queue: dispatch_queue_t, task: ActivityTask, completion: TaskCompletionBlock = {status in }) -> dispatch_block_t {
        return dispatch_block_create(dispatch_block_flags_t(0)) {
            
            let error = dispatch_queue_get_specific(queue, &self.key)
            
            guard error == nil else {
                return
            }

            dispatch_sync(dispatch_get_main_queue()) { [weak self] in
                self?.willLaunch(task)
            }

            task.launch()
            
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                self?.didLaunch(task)
            }
            
            task.waitUntilExit { error in
                
                if error != nil {
                    dispatch_queue_set_specific(Windmill.dispatch_queue_serial, &self.key, &self.error, nil)
                }

                dispatch_async(dispatch_get_main_queue()) { [weak self] in
                    self?.didExit(task, error: error)
                }
                
                completion(task: task, error: error)
            }
        }
    }
    
    func queue(queue: dispatch_queue_t = Windmill.dispatch_queue_serial, tasks: ActivityTask...) {
        for task in tasks {
            dispatch_async(queue, dispatch_block_create_for(queue, task: task))
        }
    }
    
    func schedule(queue: dispatch_queue_t = Windmill.dispatch_queue_serial, task: ActivityTask, completion: TaskCompletionBlock)
    {
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(self.delayInSeconds) * Int64(NSEC_PER_SEC))
        
        dispatch_after(when, queue, dispatch_block_create_for(queue, task: task, completion: completion))
    }
}
