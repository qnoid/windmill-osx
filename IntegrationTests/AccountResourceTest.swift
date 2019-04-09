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
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /**
     * Integration Test
     *
     - Precondition: requires server
     */
    func testGivenExportAssertExport() {
        let accountResource = AccountResource()
        let claim = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjU1ZmQyYWMzLTdkZTItNGM2Ny1iMGY4LTc5ZTdjZmEwMjBjMiIsImV4cCI6MzMxMDgxODg1NzQsInR5cCI6ImF0IiwidiI6MX0.yxmDN4QLq0eJeJ1D42ZoIb9HO67o8bRvYXFjDy9bLcs"
        

        let export = Export.make(at: exportURL, manifest: Export.Manifest.make(at: exportManifestURL), distributionSummary: Export.DistributionSummary.make(at: distributionSummaryURL))
        
        var actual: String = ""
        
        let expectation = XCTestExpectation(description: #function)
        accountResource.requestExport(export: export, forAccount: Account(identifier: "14810686-4690-4900-ada5-8b0b7338aa39"), authorizationToken: SubscriptionAuthorizationToken(value: claim)){ itms, error in
            
            guard let itms = itms else {
                XCTFail(error!.localizedDescription)
                return
            }
            
            actual = itms
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
        
        XCTAssertFalse(actual.isEmpty)
        XCTAssertEqual("\"itms-services://?action=download-manifest&url=https://ota.windmill.io/14810686-4690-4900-ada5-8b0b7338aa39/io.windmill.windmill/1.0/windmill.plist\"", actual)
    }
}
