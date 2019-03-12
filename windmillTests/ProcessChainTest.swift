//
//  ProcessChainTest.swift
//  windmillTests
//
//  Created by Markos Charatzas on 8/2/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import XCTest

@testable import Windmill

class ProcessChainTest: XCTestCase {

    let bundle = Bundle(for: ProcessChainTest.self)
    
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

        let build = Process.makeBuildForTesting(location: Project.Location(url: repositoryLocalURL), project: project, scheme: project.scheme, destination: devices.destination!, derivedData: Directory(URL: FileManager.default.trashDirectoryURL.appendingPathComponent("DerivedData").appendingPathComponent(project.name), fileManager: .default), resultBundle: resultBundle, log: FileManager.default.trashDirectoryURL.appendingPathComponent(CharacterSet.Windmill.random()))
        
        processManager.launch(process: build, recover: RecoverableProcess.recover(terminationStatus: 66) { process in
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
        
        let build = Process.makeBuild(location: Project.Location(url: repositoryLocalURL), project: project, scheme: project.scheme, destination: devices.destination!, derivedData: Directory(URL: FileManager.default.trashDirectoryURL.appendingPathComponent("DerivedData").appendingPathComponent(project.name), fileManager: .default), resultBundle: resultBundle, log: FileManager.default.trashDirectoryURL.appendingPathComponent(CharacterSet.Windmill.random()))
        
        processManager.launch(process: build, wasSuccesful: { _ in
            expectation.fulfill()
        })
        
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
            monitor = nil //just a way to keep the monitor reference arround for the test execution
        }

        let url = bundle.url(forResource: "HelloWindmill", withExtension: "xcarchive")!
        let info = Archive.Info.make(at: URL(string: "any")!)
        let archive = Archive(url: url, info: info)
        
        let export = Process.makeExport(location: Project.Location(url: any), archive: archive, exportDirectoryURL: exportDirectoryURL, resultBundle: resultBundle, log: FileManager.default.trashDirectoryURL.appendingPathComponent(CharacterSet.Windmill.random()))
        
        processManager.launch(process: export, wasSuccesful: { _ in
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 45.0)
    }

}
