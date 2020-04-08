//
//  ConfigurationTest.swift
//  windmillTests
//
//  Created by Markos Charatzas (markos@qnoid.com) on 19/2/18.
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

class ConfigurationTest: XCTestCase {

    func testGivenConfigurationWithSingleSchemeAssertSchemeMatch() {
        
        let url = Bundle(for: ConfigurationTest.self).url(forResource: "/ConfigurationTest/configuration-with-single-scheme", withExtension: "json")!
        
        let metadata = MetadataJSONEncoded(url: url)
        let configuration = Project.Configuration(metadata: metadata)
        
        XCTAssertEqual("HelloWindmill", configuration.detectScheme(name:"HelloWindmill"))
    }

    func testGivenConfigurationWithSingleSchemeAssertValidSchemeReturned() {
        
        let url = Bundle(for: ConfigurationTest.self).url(forResource: "/ConfigurationTest/configuration-with-single-scheme", withExtension: "json")!
        
        let metadata = MetadataJSONEncoded(url: url)
        let configuration = Project.Configuration(metadata: metadata)
        
        XCTAssertEqual("HelloWindmill", configuration.detectScheme(name:"HelloWindmill-"))
    }

    func testGivenConfigurationWithoutSchemesAssertSchemeIsTarget() {
        
        let url = Bundle(for: ConfigurationTest.self).url(forResource: "/ConfigurationTest/configuration-without-scheme", withExtension: "json")!
        
        let metadata = MetadataJSONEncoded(url: url)
        let configuration = Project.Configuration(metadata: metadata)
        
        XCTAssertEqual("HelloWindmillTarget", configuration.detectScheme(name:"HelloWindmill"))
    }

    //Scenario when parsing fails
    func testGivenConfigurationWithoutSchemesAssertMatchingTarget() {
        
        let url = Bundle(for: ConfigurationTest.self).url(forResource: "/ConfigurationTest/configuration-without-scheme", withExtension: "json")!
        
        let metadata = MetadataJSONEncoded(url: url)
        let configuration = Project.Configuration(metadata: metadata)
        
        XCTAssertEqual("HelloWindmillTarget", configuration.detectScheme(name:"HelloWindmillTarget"))
    }

    //Scenario when parsing fails
    func testGivenConfigurationWithoutSchemesOrTargetAssertName() {
        
        let url = Bundle(for: ConfigurationTest.self).url(forResource: "/ConfigurationTest/configuration-without-schemes-or-targets-or-name", withExtension: "json")!
        
        let metadata = MetadataJSONEncoded(url: url)
        let configuration = Project.Configuration(metadata: metadata)
      
        let scheme = "folder name"
        XCTAssertEqual(scheme, configuration.detectScheme(name:scheme))
    }

}
