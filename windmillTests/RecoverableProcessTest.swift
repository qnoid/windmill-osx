//
//  RecoverableProcessTest.swift
//  windmillTests
//
//  Created by Markos Charatzas on 9/3/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import XCTest

@testable import Windmill

class ProcessWithTerminationStatus: Process {
    
    let _terminationStatus: Int32
    
    init(terminationStatus: Int32) {
        self._terminationStatus = terminationStatus
    }
    
    override var terminationStatus: Int32 {
        return _terminationStatus
    }
}

class RecoverableProcessTest: XCTestCase {

    func testGivenRecoverableProcessAssertAlwaysRecovers() {
        let expectation = self.expectation(description: #function)
        
        let any: Process = Process()
        
        let recoverableProcess = RecoverableProcess( recover: { _ in
            expectation.fulfill()
        })
        
        recoverableProcess.recover(any)
        
        wait(for: [expectation], timeout: 2.0)
    }

    func testGivenRecoverableProcessAssertRecoversOnTerminationStatus() {
        let expectation = self.expectation(description: #function)
        
        let succesful: Process = ProcessWithTerminationStatus(terminationStatus: 66)
        
        let recoverableProcess = RecoverableProcess.recover(terminationStatus: 66) { _ in
            expectation.fulfill()
        }
        
        recoverableProcess.recover(succesful)
        
        wait(for: [expectation], timeout: 2.0)
    }

}
