//
//  SequenceTest.swift
//  windmillTests
//
//  Created by Markos Charatzas on 8/2/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import XCTest

@testable import Windmill

class SequenceTest: XCTestCase {

    let bundle = Bundle(for: SequenceTest.self)
    
    func testGivenProjectWithoutTestTargetAssertTestWasSuccesful() {
        
        let expectation = self.expectation(description: #function)
        let processManager = ProcessManager()
        
        let name = "helloword-no-test-target"
        let repositoryLocalURL = bundle.url(forResource: name, withExtension: "")!

        let devices = Devices(metadata: MetadataJSONEncoded(url: bundle.url(forResource: "/metadata/\(name)/test/devices", withExtension: "json")!))
        let buildSettings = BuildSettings(metadata: MetadataJSONEncoded(url: bundle.url(forResource: "/metadata/\(name)/build/settings", withExtension: "json")!))
        
        let build = Process.makeBuild(repositoryLocalURL: repositoryLocalURL, scheme: "helloword-no-test-target", devices: devices, derivedDataURL: FileManager.default.trashDirectoryURL)
        let readTestMetadata = Process.makeReadDevices(repositoryLocalURL: repositoryLocalURL, scheme: "helloworld", devices: devices, buildSettings: buildSettings)
        let test = Process.makeTest(repositoryLocalURL: repositoryLocalURL, scheme: "helloword-no-test-target", devices: devices, derivedDataURL: FileManager.default.trashDirectoryURL)
        
        processManager.sequence(process: build, wasSuccesful: ProcessWasSuccesful { _ in
            processManager.sequence(process: readTestMetadata, wasSuccesful: ProcessWasSuccesful { _ in
                processManager.sequence(process: test, wasSuccesful: ProcessWasSuccesful { _ in
                    expectation.fulfill()
                }).launch()
            }).launch()
        }).launch()

        wait(for: [expectation], timeout: 30.0)
    }
    
    func testGivenProjectWithTestTargetAssertTestWasSuccesful() {
        
        let expectation = self.expectation(description: #function)
        let processManager = ProcessManager()
        
        let name = "helloworld"
        
        let repositoryLocalURL = bundle.url(forResource: name, withExtension: "")!
        
        let devices = Devices(metadata: MetadataJSONEncoded(url: bundle.url(forResource: "/metadata/\(name)/test/devices", withExtension: "json")!))
        let buildSettings = BuildSettings(metadata: MetadataJSONEncoded(url: bundle.url(forResource: "/metadata/\(name)/build/settings", withExtension: "json")!))
        
        let build = Process.makeBuild(repositoryLocalURL: repositoryLocalURL, scheme: "helloworld", devices: devices, derivedDataURL: FileManager.default.trashDirectoryURL)
        let readTestMetadata = Process.makeReadDevices(repositoryLocalURL: repositoryLocalURL, scheme: "helloworld", devices: devices, buildSettings: buildSettings)
        let test = Process.makeTest(repositoryLocalURL: repositoryLocalURL, scheme: "helloworld", devices: devices, derivedDataURL: FileManager.default.trashDirectoryURL)

        processManager.sequence(process: build, wasSuccesful: ProcessWasSuccesful { _ in
            processManager.sequence(process: readTestMetadata, wasSuccesful: ProcessWasSuccesful { _ in
                processManager.sequence(process: test, wasSuccesful: ProcessWasSuccesful { _ in
                    expectation.fulfill()
                }).launch()
            }).launch()
        }).launch()
        
        wait(for: [expectation], timeout: 60.0)
    }

    func testGivenProjectWithoutAvailableSimulatorAssertTestWasSuccesful() {
        
        let expectation = self.expectation(description: #function)
        let processManager = ProcessManager()
        
        let name = "no_simulator_available"
        let repositoryLocalURL = bundle.url(forResource: name, withExtension: "")!

        let devices = Devices(metadata: MetadataJSONEncoded(url: bundle.url(forResource: "/metadata/\(name)/test/devices", withExtension: "json")!))
        let buildSettings = BuildSettings(metadata: MetadataJSONEncoded(url: bundle.url(forResource: "/metadata/\(name)/build/settings", withExtension: "json")!))
        
        let build = Process.makeBuild(repositoryLocalURL: repositoryLocalURL, scheme: "no_simulator_available", devices: devices, derivedDataURL: FileManager.default.trashDirectoryURL)
        let readTestMetadata = Process.makeReadDevices(repositoryLocalURL: repositoryLocalURL, scheme: "no_simulator_available", devices: devices, buildSettings: buildSettings)
        let test = Process.makeTest(repositoryLocalURL: repositoryLocalURL, scheme: "no_simulator_available", devices: devices, derivedDataURL: FileManager.default.trashDirectoryURL)

        processManager.sequence(process: build, wasSuccesful: ProcessWasSuccesful { _ in
            processManager.sequence(process: readTestMetadata, wasSuccesful: ProcessWasSuccesful { _ in
                processManager.sequence(process: test, wasSuccesful: ProcessWasSuccesful { _ in
                    expectation.fulfill()
                }).launch()
            }).launch()
        }).launch()
        
        wait(for: [expectation], timeout: 30.0)
    }
}
