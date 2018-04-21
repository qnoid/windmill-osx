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
    
    func didExit(manager: ProcessManager, process: Process, isSuccess: Bool, canRecover: Bool, userInfo: [AnyHashable : Any]?)
}

struct RecoverableProcess {

    static func recover(terminationStatus recoverableTerminationStatus: Int32, recover: @escaping Recover) -> RecoverableProcess {
        return RecoverableProcess(recover: recover) { terminationStatus in
            return terminationStatus == recoverableTerminationStatus
        }
    }

    static let always: Precondition = { _ in return true}
    
    typealias Recover  = (Process) -> Swift.Void
    typealias Precondition = (_ terminationStatus: Int32) -> Bool
    
    let recover: Recover
    let canRecover: Precondition

    init(recover: @escaping Recover, canRecover: @escaping Precondition = RecoverableProcess.always) {
        self.recover = recover
        self.canRecover = canRecover
    }
    
    func canRecover(terminationStatus: Int32) -> Bool {
        return self.canRecover(terminationStatus)
    }

    func perform(process: Process) {
        guard self.canRecover(process.terminationStatus) else {
            return
        }
        
        recover(process)
    }
}

struct ProcessWasSuccesful {
    
    static let ok: ProcessWasSuccesful = ProcessWasSuccesful { _ in }
    
    typealias WasSuccesful = (_ :[AnyHashable : Any]?) -> Swift.Void
    
    let block: WasSuccesful
    
    func perform(userInfo: [AnyHashable : Any]?) {
        block(userInfo)
    }
}

public struct ProcessManagerStringKey : RawRepresentable, Equatable, Hashable {
    
    public static let recoverable: ProcessManagerStringKey = ProcessManagerStringKey(rawValue: "io.windmill.process.manager.key.recoverable")!
    
    public static func ==(lhs: ProcessManagerStringKey, rhs: ProcessManagerStringKey) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    public typealias RawValue = String
    
    public var hashValue: Int {
        return self.rawValue.hashValue
    }

    public var rawValue: String
    
    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
}

class ProcessManager {
    
    let log = OSLog(subsystem: "io.windmill.windmill", category: "process.manager")
    let dispatch_queue_serial = DispatchQueue(label: "io.windmil.process.output", qos: .utility, attributes: [])
    
    weak var delegate: ProcessManagerDelegate?
    
    weak var monitor: ProcessMonitor?

    // MARK: Process Pipe output
    
    private func didReceive(process: Process, standardOutput: String, count: Int) {
        os_log("standardOutput: '%{public}@'", log: log, type: .debug, standardOutput)
        self.delegate?.standardOutput(manager: self, process: process, part: standardOutput, count: count)
    }
    
    private func didReceive(process: Process, standardError: String, count: Int) {
        os_log("standardError: '%{public}@'", log: log, type: .debug, standardError)
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

    func waitForStandardOutputInBackground(process: Process) -> DispatchSourceRead? {
        if delegate == nil {
            return nil
        }
        
        return waitForStandardOutputInBackground(process: process, queue: self.dispatch_queue_serial)
    }
    
    func waitForStandardErrorInBackground(process: Process) -> DispatchSourceRead? {
        if delegate == nil {
            return nil
        }

        return waitForStandardErrorInBackground(process: process, queue: self.dispatch_queue_serial)
    }
    
    // MARK: Process lifecycle
    
    func didLaunch(process: Process, userInfo: [AnyHashable : Any]? = nil) {
        self.monitor?.didLaunch(manager: self, process: process, userInfo: userInfo)
    }
    
    func willLaunch(process: Process, userInfo: [AnyHashable : Any]? = nil) {
        self.monitor?.willLaunch(manager: self, process: process, userInfo: userInfo)
    }
    
    func didExit(process: Process, isSuccess: Bool, canRecover: Bool, userInfo: [AnyHashable : Any]? = nil) {        
        self.monitor?.didExit(manager: self, process: process, isSuccess: isSuccess, canRecover: canRecover, userInfo: userInfo)
    }

    // MARK: public

    /**
     Launches the given `process`
 
    */
    public func launch(process: Process, recover: RecoverableProcess? = nil, wasSuccesful: ProcessWasSuccesful? = nil, userInfo: [AnyHashable : Any]? = nil) {

        self.willLaunch(process: process, userInfo: userInfo)

        let waitForStandardOutputInBackground = self.waitForStandardOutputInBackground(process: process)
        let waitForStandardErrorInBackground = self.waitForStandardErrorInBackground(process: process)

        process.terminationHandler = { [weak self] process in
            let canRecover = recover?.canRecover(process.terminationStatus) ?? false

            DispatchQueue.main.async { [isSuccess = (process.terminationStatus == 0)] in
                waitForStandardOutputInBackground?.cancel()
                waitForStandardErrorInBackground?.cancel()

                self?.didExit(process: process, isSuccess: isSuccess, canRecover: canRecover, userInfo: userInfo)
                guard isSuccess else {
                    recover?.perform(process: process)
                    return
                }
                
                wasSuccesful?.perform(userInfo: userInfo)
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

    public func processChain(process: Process, userInfo: [AnyHashable : Any]? = nil, wasSuccesful: ProcessWasSuccesful? = nil) -> ProcessChain {
        return ProcessChain(processManager: self, process: process, userInfo: userInfo, wasSuccesful: wasSuccesful)
    }
}
