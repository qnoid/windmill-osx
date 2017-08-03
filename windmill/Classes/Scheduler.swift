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
    
    func willLaunch(process: Process, type: ActivityType, scheduler: Scheduler)
    
    func didLaunch(process: Process, type: ActivityType, scheduler: Scheduler)
    
    func didExitSuccesfully(process: Process, type: ActivityType, scheduler: Scheduler)
}

/**

*/
final public class Scheduler
{
    let dispatch_queue_serial = DispatchQueue(label: "io.windmil.scheduler", attributes: [])
    
    weak var delegate: SchedulerDelegate?
    
    fileprivate func willLaunch(process: Process, type: ActivityType) {
        self.delegate?.willLaunch(process:process, type: type, scheduler: self)
    }
    
    fileprivate func didLaunch(process: Process, type: ActivityType) {
        self.delegate?.didLaunch(process:process, type: type, scheduler: self)
    }
    
    fileprivate func didExitSuccesfully(process: Process, type: ActivityType) {
        self.delegate?.didExitSuccesfully(process:process, type: type, scheduler: self)
    }
    
    func makeExecute(_ processProvider: @escaping @autoclosure () -> Process, type: ActivityType) -> Execute {
        return {
            let process = processProvider()
            
            DispatchQueue.main.sync { [weak self] in
                self?.willLaunch(process: process, type: type)
            }
            
            process.launch()
            
            DispatchQueue.main.async { [weak self] in
                self?.didLaunch(process: process, type: type)
            }
            
            process.waitUntilExit()
            
            let terminationStatus = Int(process.terminationStatus)
            guard terminationStatus == 0 else {
                throw NSError.errorTermination(for: type, status: terminationStatus)
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.didExitSuccesfully(process: process, type: type)
            }
        }
    }
    
    func queue(execute: DispatchWorkItem) {
        self.dispatch_queue_serial.async(execute: execute)
    }
    
    func queue(process: Process, type: ActivityType, delayInSeconds: Int, completionHandler: @escaping CompletionHandler)
    {
        let execute = makeExecute( process, type: type )
        let forwardExecution = ForwardExecution( execute: execute )        
        let dispatchWorkItem = forwardExecution.dispatchWorkItem(completionHandler: completionHandler)
        
        self.dispatch_queue_serial.asyncAfter(deadline: DispatchTime.now() + .seconds(delayInSeconds), execute: dispatchWorkItem)
    }
}
