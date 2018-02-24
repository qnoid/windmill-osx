//
//  AppBundleTest.swift
//  windmillTests
//
//  Created by Markos Charatzas on 12/2/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import XCTest

@testable import Windmill

class AppBundleTest: XCTestCase {

    func testGivenAppBundleInfoAssertValues() {

        let url = Bundle(for: AppBundleTest.self).url(forResource: "AppBundleTest/Info", withExtension: "plist")!
        
        let metadata = MetadataPlistEncoded(url: url)
        
        let info = AppBundle.Info(metadata: metadata)
        
        XCTAssertEqual(info.iconName, "AppIcon")
    }
    
    func testGivenAppBundleInfoAssertIconURL() {

        let url = Bundle(for: AppBundleTest.self).url(forResource: "AppBundleTest/Info", withExtension: "plist")!
        
        let metadata = MetadataPlistEncoded(url: url)
        
        let info = AppBundle.Info(metadata: metadata)
        
        let appBundle = AppBundle(url: URL(fileURLWithPath: "any"), info: info)
        
        XCTAssertEqual(appBundle.iconURL().lastPathComponent, "AppIcon60x60@2x.png")
    }

}
