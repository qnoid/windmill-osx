//
//  Sequence.swift
//  windmill
//
//  Created by Markos Charatzas on 6/2/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation
import os

struct ProcessChain {
    
    unowned var processManager: ProcessManager
    
    let process: Process
    let userInfo: [AnyHashable : Any]?
    let wasSuccesful: ProcessWasSuccesful?

    init(processManager: ProcessManager, process: Process, userInfo: [AnyHashable : Any]? = nil, wasSuccesful: ProcessWasSuccesful? = nil) {
        self.processManager = processManager
        self.process = process
        self.userInfo = userInfo
        self.wasSuccesful = wasSuccesful
    }
    
    func launch(recover: RecoverableProcess? = nil) {
        self.processManager.launch(process: self.process, recover: recover, wasSuccesful: self.wasSuccesful, userInfo: self.userInfo)
    }
}
