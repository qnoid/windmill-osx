//
//  SubscriptionResourceTest.swift
//  windmillTests
//
//  Created by Markos Charatzas (markos@qnoid.com) on 12/03/2019.
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

class SubscriptionResourceTest: XCTestCase {

    func testGivenAccountWithExpiredSubscriptionClaimAssertAccessExpired() {
        let subscriptionResource = SubscriptionResource()
        let claim = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJpOGVkZTE1OFhkdHpVZUFYZVFEbSIsInN1YiI6IjU1ZmQyYWMzLTdkZTItNGM2Ny1iMGY4LTc5ZTdjZmEwMjBjMiIsInR5cCI6InN1YiIsInYiOjF9.XoXNUnKJjJ5bXJsMvQQN72lO08fL7EpFQ_8m97vWQkw"
        
        
        var actual: SubscriptionError?
        
        let expectation = XCTestExpectation(description: #function)
        subscriptionResource.requestIsSubscriber(forAccount: Account(identifier: "14810686-4690-4900-ada5-8b0b7338aa39"), claim: SubscriptionClaim(value: claim), completion: { token, error in
            
            actual = error as? SubscriptionError
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 30.0)
        
        XCTAssertNotNil(actual)
        XCTAssertTrue(actual?.isExpired ?? false)
    }
}
