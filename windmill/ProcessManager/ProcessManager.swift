//
//  ProcessManager.swift
//  windmill
//
//  Created by Markos Charatzas on 16/08/2017.
//  Copyright © 2017 qnoid.com. All rights reserved.
//

import Foundation
import os

typealias ProcessIdentifer = Int32

protocol ProcessManagerDelegate: class {
    
    func standardOutput(manager: ProcessManager, process: Process, part: String, count: Int)
    
    func standardError(manager: ProcessManager, process: Process, part: String, count: Int)
}

protocol ProcessMonitor: class {
    
    func willLaunch(manager: ProcessManager, process: Process, userInfo: [AnyHashable : Any]?)
    
    func didLaunch(manager: ProcessManager, process: Process, userInfo: [AnyHashable : Any]?)
    
    func didExit(manager: ProcessManager, process: Process, isSuccess: Bool, userInfo: [AnyHashable : Any]?)
}

class ProcessManager {
    
    let log = OSLog(subsystem: "io.windmill.windmill", category: "process.manager")
    let dispatch_queue_serial = DispatchQueue(label: "io.windmil.process.output", qos: .utility, attributes: [])
    
    weak var delegate: ProcessManagerDelegate?
    
    weak var monitor: ProcessMonitor?

    // MARK: Process Pipe output
    
    private func didReceive(process: Process, standardOutput: String, count: Int) {
        os_log("%{public}@", log: log, type: .debug, standardOutput)
        self.delegate?.standardError(manager: self, process: process, part: standardOutput, count: count)
    }
    
    private func didReceive(process: Process, standardError: String, count: Int) {
        os_log("%{public}@", log: log, type: .debug, standardError)
        self.delegate?.standardError(manager: self, process: process, part: standardError, count: count)
    }

    private func waitForStandardOutputInBackground(process: Process, queue: DispatchQueue) -> DispatchSourceRead {
        let standardOutputPipe = Pipe()
        process.standardOutput = standardOutputPipe
        
        return process.windmill_waitForDataInBackground(standardOutputPipe, queue: queue) { [weak process, weak self] availableString, count in
            guard let process = process else {
                return
            }
            
            self?.didReceive(process: process, standardOutput: availableString, count: count)
        }
    }
    
    private func waitForStandardErrorInBackground(process: Process, queue: DispatchQueue) -> DispatchSourceRead {
        let standardErrorPipe = Pipe()
        process.standardError = standardErrorPipe
        
        return process.windmill_waitForDataInBackground(standardErrorPipe, queue: queue){ [weak process, weak self] availableString, count in
            guard let process = process else {
                return
            }
            
            self?.didReceive(process: process, standardError: availableString, count: count)
        }
    }

    func waitForStandardOutputInBackground(process: Process) -> DispatchSourceRead {
        return waitForStandardOutputInBackground(process: process, queue: self.dispatch_queue_serial)
    }
    
    func waitForStandardErrorInBackground(process: Process) -> DispatchSourceRead {
        return waitForStandardErrorInBackground(process: process, queue: self.dispatch_queue_serial)
    }
    
    // MARK: Process lifecycle
    
    func didLaunch(process: Process, userInfo: [AnyHashable : Any]? = nil) {
        self.monitor?.didLaunch(manager: self, process: process, userInfo: userInfo)
    }
    
    func willLaunch(process: Process, userInfo: [AnyHashable : Any]? = nil) {
        self.monitor?.willLaunch(manager: self, process: process, userInfo: userInfo)
    }
    
    func didExit(process: Process, processIdentifier: ProcessIdentifer, userInfo: [AnyHashable : Any]? = nil) {        
        self.monitor?.didExit(manager: self, process: process, isSuccess: process.terminationStatus == 0, userInfo: userInfo)
    }

    // MARK: public

    /**
     Launches the given `process`
 
    */
    public func launch(process: Process, wasSuccesful eventHandler: DispatchWorkItem? = nil, userInfo: [AnyHashable : Any]? = nil) {
    
        self.willLaunch(process: process, userInfo: userInfo)

        let waitForStandardOutputInBackground = self.waitForStandardOutputInBackground(process: process)
        let waitForStandardErrorInBackground = self.waitForStandardErrorInBackground(process: process)

        process.terminationHandler = { [weak self] process in
            DispatchQueue.main.async {
                waitForStandardOutputInBackground.cancel()
                waitForStandardErrorInBackground.cancel()
                
                let processIdentifier = process.processIdentifier
                self?.didExit(process: process, processIdentifier: processIdentifier, userInfo: userInfo)
                guard process.terminationStatus == 0 else {
                    return
                }
                
                eventHandler?.perform()
            }
        }

        process.launch()

        self.didLaunch(process: process, userInfo: userInfo)
    }
    
    public func `repeat`(process provider: @escaping @autoclosure () -> Process, every timeInterval: DispatchTimeInterval, until terminationStatus: Int, then eventHandler: DispatchWorkItem, deadline: DispatchTime = DispatchTime.now()) {
        
        let process = provider()
        
        process.terminationHandler = { process in
            
            if process.terminationStatus == terminationStatus {
                DispatchQueue.main.async {
                    eventHandler.perform()
                }
                return
            }

            DispatchQueue.main.async { [weak self] in 
                self?.repeat(process: provider, every: timeInterval, until: terminationStatus, then: eventHandler, deadline: DispatchTime.now() + timeInterval)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            process.launch()
        }
    }

    public func sequence(process: Process, userInfo: [AnyHashable : Any]? = nil, wasSuccesful: DispatchWorkItem? = nil) -> Sequence {
        return Sequence(processManager: self, process: process, userInfo: userInfo, wasSuccesful: wasSuccesful)
    }
}
