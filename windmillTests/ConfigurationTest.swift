//
//  ConfigurationTest.swift
//  windmillTests
//
//  Created by Markos Charatzas on 19/2/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import XCTest

@testable import windmill

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
