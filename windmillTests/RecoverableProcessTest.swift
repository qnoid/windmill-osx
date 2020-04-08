//
//  RecoverableProcessTest.swift
//  windmillTests
//
//  Created by Markos Charatzas (markos@qnoid.com) on 9/3/18.
//  Copyright © 2014-2020 qnoid.com. All rights reserved.
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation is required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.
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
