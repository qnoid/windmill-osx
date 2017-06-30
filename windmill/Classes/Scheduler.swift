//
//  Scheduler.swift
//  windmill
//
//  Created by Markos Charatzas on 29/09/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import Foundation
import os

protocol SchedulerDelegate: class {
    
    func willLaunch(_ task: ActivityTask, scheduler: Scheduler)
    
    func didLaunch(_ task: ActivityTask, scheduler: Scheduler)
    
    func didExit(_ task: ActivityTask, error: Error?, scheduler: Scheduler)
}

typealias TaskCompletionBlock = (_ task: ActivityTask, _ error: Error?) -> Void
/**

*/
final public class Scheduler
{
    #if DEBUG
    let delayInSeconds:Int = 10
    #else
    let delayInSeconds:Int = 30
    #endif
    
    weak var delegate: SchedulerDelegate?
    
    var key: DispatchSpecificKey = DispatchSpecificKey<Bool>()
    var error: Bool = true
    
    fileprivate func willLaunch(_ task: ActivityTask) {
        self.delegate?.willLaunch(task, scheduler: self)
    }
    
    fileprivate func didLaunch(_ task: ActivityTask) {
        self.delegate?.didLaunch(task, scheduler: self)
    }
    
    fileprivate func didExit(_ task: ActivityTask, error: Error?) {
        self.delegate?.didExit(task, error: error, scheduler: self)
    }
    
    fileprivate func dispatch_block_create_for(_ queue: DispatchQueue, task: ActivityTask, completion: @escaping TaskCompletionBlock = {status in }) -> DispatchWorkItem {
        return DispatchWorkItem { [weak self] in
            
            guard queue.getSpecific(key: self!.key) == nil else {
                os_log("error key in queue %{public}@. Execution will stop.", log: .default, type: .debug, queue)
                return
            }

            DispatchQueue.main.sync {
                self?.willLaunch(task)
            }

            task.launch()
            
            DispatchQueue.main.async {
                self?.didLaunch(task)
            }
            
            task.waitUntilExit { error in
                
                if error != nil {
                    queue.setSpecific(key: self!.key, value: self!.error)
                }

                DispatchQueue.main.async {
                    self?.didExit(task, error: error)
                }
                
                DispatchQueue.main.async {
                    completion(task, error)
                }
            }
        }
    }
    
    func queue(_ queue: DispatchQueue = Windmill.dispatch_queue_serial, tasks: ActivityTask...) {
        for task in tasks {
            queue.async(execute: dispatch_block_create_for(queue, task: task))
        }
    }
    
    func schedule(_ queue: DispatchQueue = Windmill.dispatch_queue_serial, task: ActivityTask, completion: @escaping TaskCompletionBlock)
    {
        queue.asyncAfter(deadline: DispatchTime.now() + .seconds(self.delayInSeconds), execute: dispatch_block_create_for(queue, task: task, completion: completion))
    }
}
