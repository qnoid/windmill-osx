//
//  ProcessManager.swift
//  windmill
//
//  Created by Markos Charatzas on 16/08/2017.
//  Copyright © 2017 qnoid.com. All rights reserved.
//

import Foundation
import os

extension Process {
    
    /* fileprivate */ func manager_waitForDataInBackground(_ pipe: Pipe, queue: DispatchQueue, callback: @escaping (_ data: String, _ count: Int) -> Void) -> DispatchSourceRead {
        
        let fileDescriptor = pipe.fileHandleForReading.fileDescriptor
        let readSource = DispatchSource.makeReadSource(fileDescriptor: fileDescriptor, queue: queue)
        
        readSource.setEventHandler { [weak readSource = readSource] in
            guard let data = readSource?.data else {
                return
            }
            
            let estimatedBytesAvailableToRead = Int(data)
            
            var buffer = [UInt8](repeating: 0, count: estimatedBytesAvailableToRead)
            let bytesRead = read(fileDescriptor, &buffer, estimatedBytesAvailableToRead)
            
            guard bytesRead > 0, let availableString = String(bytes: buffer, encoding: .utf8) else {
                return
            }
            
            DispatchQueue.main.async {
                callback(availableString, availableString.utf8.count)
            }
        }
        
        readSource.activate()
        
        return readSource
    }
}

typealias ProcessIdentifer = Int32

protocol ProcessManagerDelegate: class {
    
    func standardOutput(manager: ProcessManager, process: Process, part: String, count: Int)
    
    func standardError(manager: ProcessManager, process: Process, part: String, count: Int)
}

protocol ProcessMonitor: class {
    
    func willLaunch(manager: ProcessManager, process: Process, userInfo: [AnyHashable : Any]?)
    
    func didLaunch(manager: ProcessManager, process: Process, userInfo: [AnyHashable : Any]?)
    
    func didExit(manager: ProcessManager, process: Process, isSuccess: Bool, canRecover: Bool, userInfo: [AnyHashable : Any]?)
    
    func didTerminate(manager: ProcessManager, process: Process, status: Int32, userInfo: [AnyHashable : Any]?)
}

extension ProcessMonitor {

    func willLaunch(manager: ProcessManager, process: Process, userInfo: [AnyHashable : Any]?) {
        
    }
    
    func didLaunch(manager: ProcessManager, process: Process, userInfo: [AnyHashable : Any]?) {
        
    }
    
    func didExit(manager: ProcessManager, process: Process, isSuccess: Bool, canRecover: Bool, userInfo: [AnyHashable : Any]?) {
        
    }
    
    func didTerminate(manager: ProcessManager, process: Process, status: Int32, userInfo: [AnyHashable : Any]?) {
        
    }
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

typealias ProcessSuccess = (_ userInfo:[AnyHashable : Any]) -> Swift.Void

class ProcessManager {

    public enum StandardOutput {
        case success(String?)
        case failure(Int32)
        
        public var isSuccess: Bool {
            switch self {
            case .success:
                return true
            case .failure:
                return false
            }
        }
        
        public var value: String? {
            switch self {
            case .success(let value):
                return value
            case .failure:
                return nil
            }
        }
        
        public var terminationStatus: Int32? {
            switch self {
            case .success:
                return 0
            case .failure(let terminationStatus):
                return terminationStatus
            }
        }
    }
    
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
        
        return process.manager_waitForDataInBackground(standardOutputPipe, queue: queue) { [weak process, weak self] availableString, count in
            guard let process = process else {
                return
            }
            
            self?.didReceive(process: process, standardOutput: availableString, count: count)
        }
    }
    
    private func waitForStandardErrorInBackground(process: Process, queue: DispatchQueue) -> DispatchSourceRead {
        let standardErrorPipe = Pipe()
        process.standardError = standardErrorPipe
        
        return process.manager_waitForDataInBackground(standardErrorPipe, queue: queue){ [weak process, weak self] availableString, count in
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

    func didTerminate(process: Process, status: Int32, userInfo: [AnyHashable : Any]? = nil) {
        self.monitor?.didTerminate(manager: self, process: process, status: status, userInfo: userInfo)
    }

    // MARK: internal

    func launch(process: Process, completion: @escaping (ProcessManager.StandardOutput) -> Void) {
        
        self.willLaunch(process: process)

        let standardOutputPipe = Pipe()
        process.standardOutput = standardOutputPipe
        
        process.terminationHandler = { [weak self] process in
            let isSuccess = (process.terminationStatus == 0)
            
            var value: String? = nil
            if isSuccess {
                let data = standardOutputPipe.fileHandleForReading.readDataToEndOfFile()
                value = String(bytes: data, encoding: .utf8)?.trimmingCharacters(in: CharacterSet.newlines)
            }
            
            DispatchQueue.main.async {
                
                self?.didExit(process: process, isSuccess: isSuccess, canRecover: false)
                guard isSuccess else {
                    completion(.failure(process.terminationStatus))
                    return
                }
                
                completion(.success(value))
            }
        }
        
        process.launch()
        self.didLaunch(process: process)
    }
    
    func launch(process: Process, recover: RecoverableProcess? = nil, userInfo: [AnyHashable : Any] = [:], wasSuccesful: ProcessSuccess? = nil) {
        
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
                    
                    if canRecover {
                        os_log("will attempt to recover process '%{public}@'", log: .default, type: .debug, process.executableURL?.lastPathComponent ?? "")
                        recover?.perform(process: process)
                    } else {
                        self?.didTerminate(process: process, status: process.terminationStatus, userInfo: userInfo)
                    }
                    
                    return
                }
                
                wasSuccesful?(userInfo)
            }
        }
        
        process.launch()
        
        self.didLaunch(process: process, userInfo: userInfo)
    }
    
    // MARK: public

    /**
     Launches the given `process`
 
    */
    public func `repeat`(process provider: @escaping () -> Process, every timeInterval: DispatchTimeInterval, untilTerminationStatus terminationStatus: Int, then eventHandler: DispatchWorkItem, deadline: DispatchTime = DispatchTime.now()) {
        
        let process = provider()
        
        process.terminationHandler = { process in
            
            if process.terminationStatus == terminationStatus {
                DispatchQueue.main.async {
                    eventHandler.perform()
                }
                return
            }

            DispatchQueue.main.async { [weak self] in 
                self?.repeat(process: provider, every: timeInterval, untilTerminationStatus: terminationStatus, then: eventHandler, deadline: DispatchTime.now() + timeInterval)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            process.launch()
        }
    }
}
