//
//  Sequence.swift
//  windmill
//
//  Created by Markos Charatzas on 6/2/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation
import os

struct Sequence {
    
    unowned var processManager: ProcessManager
    
    let process: Process
    let userInfo: [AnyHashable : Any]?
    let wasSuccesful: DispatchWorkItem?

    init(processManager: ProcessManager = ProcessManager(), process: Process, userInfo: [AnyHashable : Any]? = nil, wasSuccesful: DispatchWorkItem? = nil) {
        self.processManager = processManager
        self.process = process
        self.userInfo = userInfo
        self.wasSuccesful = wasSuccesful
    }
    
    func launch() {
        self.processManager.launch(process: self.process, wasSuccesful: self.wasSuccesful, userInfo: self.userInfo)
    }
}
