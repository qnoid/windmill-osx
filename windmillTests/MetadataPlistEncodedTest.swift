//
//  MetadataPlistEncodedTest.swift
//  windmillTests
//
//  Created by Markos Charatzas (markos@qnoid.com) on 1/1/18.
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
