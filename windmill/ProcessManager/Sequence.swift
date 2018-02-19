//
//  Sequence.swift
//  windmill
//
//  Created by Markos Charatzas on 6/2/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation
import os

struct ProcessWasSuccesful {
    
    typealias WasSuccesful = (_ :[AnyHashable : Any]?) -> Swift.Void
    
    let block: WasSuccesful
    
    func perform(userInfo: [AnyHashable : Any]?) {
        block(userInfo)
    }
}

struct Sequence {
    
    unowned var processManager: ProcessManager
    
    let process: Process
    let userInfo: [AnyHashable : Any]?
    let wasSuccesful: ProcessWasSuccesful?

    init(processManager: ProcessManager = ProcessManager(), process: Process, userInfo: [AnyHashable : Any]? = nil, wasSuccesful: ProcessWasSuccesful? = nil) {
        self.processManager = processManager
        self.process = process
        self.userInfo = userInfo
        self.wasSuccesful = wasSuccesful
    }
    
    func launch() {
        self.processManager.launch(process: self.process, wasSuccesful: self.wasSuccesful, userInfo: self.userInfo)
    }
}
