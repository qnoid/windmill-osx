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
    
    override func setUp() {
        continueAfterFailure = false
    }
    
    func testGivenProjectWithoutTestTargetAssertBuildForTestingFailedWithStatusCode() {
        
        let expectation = self.expectation(description: #function)
        let processManager = ProcessManager()
        
        let project = Project(name: "helloword-no-test-target", scheme: "helloword-no-test-target", origin: "any")
        let repositoryLocalURL = bundle.url(forResource: project.name, withExtension: "")!
        
        let devices = Devices(metadata: MetadataJSONEncoded(url: bundle.url(forResource: "/metadata/\(project.name)/devices", withExtension: "json")!))
        
        let resultBundleURL = FileManager.default.trashDirectoryURL.appendingPathComponent("ResultBundle").appendingPathComponent(project.name).appendingPathComponent(CharacterSet.Windmill.random(characters: CharacterSet.alphanumerics, length: 32)).appendingPathComponent("\(name).bundle")
        let resultBundle = ResultBundle.make(at: resultBundleURL, info: ResultBundle.Info.make(at: URL(string: "any")!))
        
        defer {
            try? FileManager.default.removeItem(at: resultBundleURL)
        }

        let build = Process.makeBuildForTesting(repositoryLocalURL: repositoryLocalURL, scheme: project.scheme, destination: devices.destination!, derivedDataURL: FileManager.default.trashDirectoryURL.appendingPathComponent("DerivedData").appendingPathComponent(project.name), resultBundle: resultBundle)
        
        processManager.sequence(process: build).launch(recover: RecoverableProcess.recover(terminationStatus: 66) { process in
            XCTAssertEqual(66, process.terminationStatus, "Process \(process.executableURL!.lastPathComponent) failed with exit code \(process.terminationStatus)")
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testGivenProjectWithoutTestTargetAssertBuildWasSuccesful() {
        
        let expectation = self.expectation(description: #function)
        let processManager = ProcessManager()
        
        let project = Project(name: "helloword-no-test-target", scheme: "helloword-no-test-target", origin: "any")
        let repositoryLocalURL = bundle.url(forResource: project.name, withExtension: "")!
        
        let devices = Devices(metadata: MetadataJSONEncoded(url: bundle.url(forResource: "/metadata/\(project.name)/devices", withExtension: "json")!))
        
        let resultBundleURL = FileManager.default.trashDirectoryURL.appendingPathComponent("ResultBundle").appendingPathComponent(project.name).appendingPathComponent(CharacterSet.Windmill.random(characters: CharacterSet.alphanumerics, length: 32)).appendingPathComponent("\(name).bundle")
        let resultBundle = ResultBundle.make(at: resultBundleURL, info: ResultBundle.Info.make(at: URL(string: "any")!))
        
        defer {
            try? FileManager.default.removeItem(at: resultBundleURL)
        }        
        
        let build = Process.makeBuild(repositoryLocalURL: repositoryLocalURL, scheme: project.scheme, destination: devices.destination!, derivedDataURL: FileManager.default.trashDirectoryURL.appendingPathComponent("DerivedData").appendingPathComponent(project.name), resultBundle: resultBundle)
        
        processManager.sequence(process: build, wasSuccesful: ProcessWasSuccesful { _ in
            expectation.fulfill()
        }).launch()
        
        wait(for: [expectation], timeout: 30.0)
    }


    func testGivenProjectArchiveAssertExport() {
        let expectation = self.expectation(description: #function)
        let processManager = ProcessManager()
        var monitor: ProcessMonitor? = ProcessMonitorFailOnUnsuccessfulExit()
        processManager.monitor = monitor

        let any = FileManager.default.trashDirectoryURL
        
        let exportDirectoryURL = FileManager.default.trashDirectoryURL.appendingPathComponent("export")
        
        let resultBundleURL = FileManager.default.trashDirectoryURL.appendingPathComponent(name)
        let resultBundle = ResultBundle.make(at: resultBundleURL, info: ResultBundle.Info.make(at: URL(string: "any")!))
        
        defer {
            try? FileManager.default.removeItem(at: resultBundleURL)
            try? FileManager.default.removeItem(at: exportDirectoryURL)
            monitor = nil
        }

        let url = bundle.url(forResource: "HelloWindmill", withExtension: "xcarchive")!
        let info = Archive.Info.make(at: URL(string: "any")!)
        let archive = Archive(url: url, info: info)
        
        let export = Process.makeExport(repositoryLocalURL: any, archive: archive, exportDirectoryURL: exportDirectoryURL, resultBundle: resultBundle)
        
        processManager.sequence(process: export, wasSuccesful: ProcessWasSuccesful { _ in
            expectation.fulfill()
        }).launch()
        
        wait(for: [expectation], timeout: 30.0)
    }

}
