//
//  MetadataPlistEncodedTest.swift
//  windmillTests
//
//  Created by Markos Charatzas on 1/1/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import XCTest

@testable import Windmill

class MetadataPlistEncodedTest: XCTestCase {

    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        return dateFormatter
    }()

    func testGivenMetadataPlistEncodedAssertParsedDictionary() {
        
        let url = Bundle(for: MetadataPlistEncodedTest.self).url(forResource: "DistributionSummary", withExtension: "plist")!
        
        let metadata = MetadataPlistEncoded(url: url)
        
        XCTAssertNotNil(metadata.dictionary)
    }
    
    func testGivenMetadataPlistEncodedAssertValues() {

        let url = Bundle(for: MetadataPlistEncodedTest.self).url(forResource: "DistributionSummary", withExtension: "plist")!

        let metadata = MetadataPlistEncoded(url: url)
        let distributionOptions = DistributionSummary(metadata: metadata)
        
        XCTAssertEqual(distributionOptions.key, "windmill.ipa")
        XCTAssertEqual(distributionOptions.teamId, "AQ2US2UQQ7")
        XCTAssertEqual(distributionOptions.teamName, "Markos Charatzas")
        XCTAssertEqual(distributionOptions.certificateType, "iOS Distribution")
        XCTAssertEqual(distributionOptions.certificateExpiryDate, dateFormatter.date(from: "2018-10-25"))
        XCTAssertEqual(distributionOptions.profileName, "iOS Team Ad Hoc Provisioning Profile: io.windmill.windmill")
    }
}
