//
//  SubscriptionResourceTest.swift
//  windmillTests
//
//  Created by Markos Charatzas on 12/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
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
