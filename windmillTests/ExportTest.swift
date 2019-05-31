//
//  ExportTest.swift
//  windmillTests
//
//  Created by Markos Charatzas on 01/05/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import XCTest

@testable import Windmill

class ExportTest: XCTestCase {

    let buildSettingsURL = Bundle(for: ExportTest.self).url(forResource: "ExportTest/build/settings", withExtension: "json")!
    let distributionSummaryURL = Bundle(for: ExportTest.self).url(forResource: "DistributionSummary", withExtension: "plist")!
    let exportManifestURL = Bundle(for: ExportTest.self).url(forResource: "ExportTest/export/manifest", withExtension: "plist")!
    let exportURL = Bundle(for: ExportTest.self).url(forResource: "test", withExtension: "ipa")!

    func testExample() {
        let project = Project(name: "windmill", scheme: "any", origin: "any")
        let url = URL(string: "/Users/qnoid/Library/Caches/io.windmill.windmill.macos/Sources/windmill")!
        let location: Project.Location = Project.Location(project: project, url: url)
        
        let metadata = Export.Metadata(project: project, buildSettings: BuildSettings(url: buildSettingsURL).for(project: project.name), location: location, distributionSummary: DistributionSummary.make(at: distributionSummaryURL), configuration: .release, applicationProperties: AppBundles.make().info)        
        
        let encoder = JSONEncoder()
        
        encoder.dateEncodingStrategy = .secondsSince1970
        
        let data = try? encoder.encode(metadata)

        XCTAssertNotNil(data)
        let expected: String = #"""
        {"configuration":"RELEASE","commit":{"shortSha":"f60878c","date":1558279667,"branch":"master"},"applicationProperties":{"bundleDisplayName":"Windmill","bundleVersion":"1.2"},"deployment":{"target":"12.2"},"distributionSummary":{"certificateExpiryDate":1540414800}}
        """#
        
        XCTAssertEqual(expected, String(data: data!, encoding: .utf8)!)
    }
}
