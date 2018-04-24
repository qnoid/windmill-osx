//
//  Foo.swift
//  windmill
//
//  Created by Markos Charatzas on 22/4/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation

class ProcessResult {
    
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
    
    unowned var processManager: ProcessManager
    
    let process: Process
    
    init(processManager: ProcessManager, process: Process) {
        self.processManager = processManager
        self.process = process
    }
    
    func launch(completion: @escaping (ProcessResult.StandardOutput) -> Void) {
        self.processManager.launch(process: self.process, completion: completion)
    }
}
