//
//  SequenceTest.swift
//  windmillTests
//
//  Created by Markos Charatzas on 8/2/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import XCTest

@testable import windmill

class SequenceTest: XCTestCase {

    let bundle = Bundle(for: SequenceTest.self)
    
    func testGivenProjectWithoutTestTargetAssertTestWasSuccesful() {
        
        let expectation = self.expectation(description: #function)
        let processManager = ProcessManager()
        
        let name = "helloword-no-test-target"
        let project = Project(name: name, scheme: "helloword-no-test-target", origin: "any")
        let directoryPath = bundle.url(forResource: name, withExtension: "")!.path

        let metadata = MetadataJSONEncoded(url: bundle.url(forResource: "/metadata/\(name)/test/metadata", withExtension: "json")!)
        let buildMetadata = MetadataJSONEncoded(url: bundle.url(forResource: "/metadata/\(name)/build/metadata", withExtension: "json")!)
        
        let build = Process.makeBuild(directoryPath: directoryPath, project: project, metadata: metadata)
        let readTestMetadata = Process.makeReadTestMetadata(directoryPath: directoryPath, forProject: project, metadata: metadata, buildMetadata: buildMetadata)
        let test = Process.makeTest(directoryPath: directoryPath, scheme: project.scheme, metadata: metadata)
        
        processManager.sequence(process: build, wasSuccesful: DispatchWorkItem {
            processManager.sequence(process: readTestMetadata, wasSuccesful: DispatchWorkItem {
                processManager.sequence(process: test, wasSuccesful: DispatchWorkItem {
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
        
        let project = Project(name: name, scheme: "helloworld", origin: "any")
        let directoryPath = project.directoryPathURL.path
        
        let metadata = MetadataJSONEncoded(url: bundle.url(forResource: "/metadata/\(name)/test/metadata", withExtension: "json")!)
        let buildMetadata = MetadataJSONEncoded(url: bundle.url(forResource: "/metadata/\(name)/build/metadata", withExtension: "json")!)
        
        let build = Process.makeBuild(directoryPath: directoryPath, project: project, metadata: metadata)
        let readTestMetadata = Process.makeReadTestMetadata(directoryPath: directoryPath, forProject: project, metadata: metadata, buildMetadata: buildMetadata)
        let test = Process.makeTest(directoryPath: directoryPath, scheme: project.scheme, metadata: metadata)
        
        processManager.sequence(process: build, wasSuccesful: DispatchWorkItem {
            processManager.sequence(process: readTestMetadata, wasSuccesful: DispatchWorkItem {
                processManager.sequence(process: test, wasSuccesful: DispatchWorkItem {
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
        let project = Project(name: name, scheme: "no_simulator_available", origin: "any")
        let directoryPath = bundle.url(forResource: name, withExtension: "")!.path
        
        let metadata = MetadataJSONEncoded(url: bundle.url(forResource: "/metadata/\(name)/test/metadata", withExtension: "json")!)
        let buildMetadata = MetadataJSONEncoded(url: bundle.url(forResource: "/metadata/\(name)/build/metadata", withExtension: "json")!)
        
        let build = Process.makeBuild(directoryPath: directoryPath, project: project, metadata: metadata)
        let readTestMetadata = Process.makeReadTestMetadata(directoryPath: directoryPath, forProject: project, metadata: metadata, buildMetadata: buildMetadata)
        let test = Process.makeTest(directoryPath: directoryPath, scheme: project.scheme, metadata: metadata)
        
        processManager.sequence(process: build, wasSuccesful: DispatchWorkItem {
            processManager.sequence(process: readTestMetadata, wasSuccesful: DispatchWorkItem {
                processManager.sequence(process: test, wasSuccesful: DispatchWorkItem {
                    expectation.fulfill()
                }).launch()
            }).launch()
        }).launch()
        
        wait(for: [expectation], timeout: 30.0)
    }
}
