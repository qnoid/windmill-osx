//
//  ProcessMonitorFailOnUnsuccessfulExit.swift
//  windmillTests
//
//  Created by Markos Charatzas on 5/3/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import XCTest

@testable import Windmill

class ProcessMonitorFailOnUnsuccessfulExit: ProcessMonitor {
    
    func willLaunch(manager: ProcessManager, process: Process, userInfo: [AnyHashable : Any]?) {
    }
    
    func didLaunch(manager: ProcessManager, process: Process, userInfo: [AnyHashable : Any]?) {
    }
    
    func didTerminate(manager: ProcessManager, process: Process, status: Int32, userInfo: [AnyHashable : Any]?) {        
        XCTFail("Process \(process.executableURL!.lastPathComponent) failed with exit code \(process.terminationStatus)")
    }
}
