//
//  AccountResourceTest.swift
//  windmillTests
//
//  Created by Markos Charatzas on 06/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import XCTest

@testable import Windmill

class AccountResourceTest: XCTestCase {

    let distributionSummaryURL = Bundle(for: AccountResourceTest.self).url(forResource: "DistributionSummary", withExtension: "plist")!
    let exportManifestURL = Bundle(for: AccountResourceTest.self).url(forResource: "manifest", withExtension: "plist")!
    let exportURL = Bundle(for: AccountResourceTest.self).url(forResource: "test", withExtension: "ipa")!
    
    /**
     * Integration Test
     *
     - Precondition: requires server
     */
    func testGivenExportAssertExport() {
        let accountResource = AccountResource()
        let claim = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjU1ZmQyYWMzLTdkZTItNGM2Ny1iMGY4LTc5ZTdjZmEwMjBjMiIsImV4cCI6MzMxMDgxODg1NzQsInR5cCI6ImF0IiwidiI6MX0.yxmDN4QLq0eJeJ1D42ZoIb9HO67o8bRvYXFjDy9bLcs"
        

        let export = Export.make(at: exportURL, manifest: Export.Manifest.make(at: exportManifestURL), distributionSummary: Export.DistributionSummary.make(at: distributionSummaryURL))
        
        var actual: String?
        
        let expectation = XCTestExpectation(description: #function)
        accountResource.requestExport(export: export, forAccount: Account(identifier: "14810686-4690-4900-ada5-8b0b7338aa39"), authorizationToken: SubscriptionAuthorizationToken(value: claim)){ itms, error in
            
            guard let itms = itms else {
                XCTFail(error!.localizedDescription)
                return
            }
            
            actual = itms
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 60.0)
        
        XCTAssertFalse(actual?.isEmpty ?? true)
        XCTAssertNotNil(actual, actual ?? "")
    }
    
    func testGivenExpiredClaimAssertExpired() {
        let accountResource = AccountResource()
        let claim = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjU1ZmQyYWMzLTdkZTItNGM2Ny1iMGY4LTc5ZTdjZmEwMjBjMiIsImV4cCI6MTU1NTg0Mjc4MiwidHlwIjoiYXQiLCJ2IjoxfQ.iDrhorQgvTotWKSgGIWmhVOaUkQBvP5f9wrXetqePro"
        
        
        let export = Export.make(at: exportURL, manifest: Export.Manifest.make(at: exportManifestURL), distributionSummary: Export.DistributionSummary.make(at: distributionSummaryURL))
        
        var subscriptionError: SubscriptionError?
        
        let expectation = XCTestExpectation(description: #function)
        accountResource.requestExport(export: export, forAccount: Account(identifier: "14810686-4690-4900-ada5-8b0b7338aa39"), authorizationToken: SubscriptionAuthorizationToken(value: claim)){ itms, error in
            
            subscriptionError = (error as? SubscriptionError)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 60.0)
        
        XCTAssertNotNil(subscriptionError)
        XCTAssertTrue(subscriptionError?.isExpired ?? false)
    }

    func testGivenUnauthorisedClaimAssertUnauthorised() {
        let accountResource = AccountResource()
        let claim = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjU1ZmQyYWMzLTdkZTItNGM2Ny1iMGY4LTc5ZTdjZmEwMjBjMiIsImV4cCI6MTU1NTg0Mjc4MiwidHlwIjoiYXQiLCJ2IjoxfQ.dXwpYAtOkcVgQXKfBKmzbawXDRCDPYyKjQi8L7S9Q7w"
        
        
        let export = Export.make(at: exportURL, manifest: Export.Manifest.make(at: exportManifestURL), distributionSummary: Export.DistributionSummary.make(at: distributionSummaryURL))
        
        var subscriptionError: SubscriptionError?
        
        let expectation = XCTestExpectation(description: #function)
        accountResource.requestExport(export: export, forAccount: Account(identifier: "14810686-4690-4900-ada5-8b0b7338aa39"), authorizationToken: SubscriptionAuthorizationToken(value: claim)){ itms, error in
            
            subscriptionError = (error as? SubscriptionError)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 60.0)
        
        XCTAssertNotNil(subscriptionError)
        XCTAssertTrue(subscriptionError?.isUnauthorised ?? false)
    }

}
