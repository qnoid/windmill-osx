//
//  ProcessChainTest.swift
//  windmillTests
//
//  Created by Markos Charatzas (markos@qnoid.com) on 8/2/18.
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

class ProcessChainTest: XCTestCase {

    let bundle = Bundle(for: ProcessChainTest.self)
    
    override func setUp() {
        continueAfterFailure = false
    }
    
    func testGivenProjectWithoutTestTargetAssertBuildForTestingFailedWithStatusCode() {
        
        let expectation = self.expectation(description: #function)
        let processManager = ProcessManager()
        
        let project = Project(isWorkspace: false, name: "helloword-no-test-target", scheme: "helloword-no-test-target", origin: "any")
        let repositoryLocalURL = bundle.url(forResource: project.name, withExtension: "")!
        
        let devices = Devices(metadata: MetadataJSONEncoded(url: bundle.url(forResource: "/metadata/\(project.name)/devices", withExtension: "json")!))
        
        let resultBundleURL = FileManager.default.trashDirectoryURL.appendingPathComponent("ResultBundle").appendingPathComponent(project.name).appendingPathComponent(CharacterSet.Windmill.random(characters: CharacterSet.alphanumerics, length: 32)).appendingPathComponent("\(name).bundle")
        let resultBundle = ResultBundle.make(at: resultBundleURL, info: ResultBundle.Info.make(at: URL(string: "any")!))
        
        defer {
            try? FileManager.default.removeItem(at: resultBundleURL)
        }

        let build = Process.makeBuildForTesting(projectAt: Project.Location(project: project, url: repositoryLocalURL), project: project, scheme: project.scheme, destination: devices.destination!, derivedData: Directory(URL: FileManager.default.trashDirectoryURL.appendingPathComponent("DerivedData").appendingPathComponent(project.name), fileManager: .default), resultBundle: resultBundle, log: FileManager.default.trashDirectoryURL.appendingPathComponent(CharacterSet.Windmill.random()))
        
        processManager.launch(process: build, recover: RecoverableProcess.recover(terminationStatus: 66) { process in
            XCTAssertEqual(66, process.terminationStatus, "Process \(process.executableURL!.lastPathComponent) failed with exit code \(process.terminationStatus)")
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testGivenProjectWithoutTestTargetAssertBuildWasSuccesful() {
        
        let expectation = self.expectation(description: #function)
        let processManager = ProcessManager()
        
        let project = Project(isWorkspace: false, name: "helloword-no-test-target", scheme: "helloword-no-test-target", origin: "any")
        let repositoryLocalURL = bundle.url(forResource: project.name, withExtension: "")!
        
        let devices = Devices(metadata: MetadataJSONEncoded(url: bundle.url(forResource: "/metadata/\(project.name)/devices", withExtension: "json")!))
        
        let resultBundleURL = FileManager.default.trashDirectoryURL.appendingPathComponent("ResultBundle").appendingPathComponent(project.name).appendingPathComponent(CharacterSet.Windmill.random(characters: CharacterSet.alphanumerics, length: 32)).appendingPathComponent("\(name).bundle")
        let resultBundle = ResultBundle.make(at: resultBundleURL, info: ResultBundle.Info.make(at: URL(string: "any")!))
        
        defer {
            try? FileManager.default.removeItem(at: resultBundleURL)
        }        
        
        let build = Process.makeBuild(projectAt: Project.Location(project: project, url: repositoryLocalURL), project: project, scheme: project.scheme, destination: devices.destination!, derivedData: Directory(URL: FileManager.default.trashDirectoryURL.appendingPathComponent("DerivedData").appendingPathComponent(project.name), fileManager: .default), resultBundle: resultBundle, log: FileManager.default.trashDirectoryURL.appendingPathComponent(CharacterSet.Windmill.random()))
        
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

        let project = Project(isWorkspace: false, name: "HelloWindmill", scheme: "HelloWindmill", origin: "any")
        let url = bundle.url(forResource: "HelloWindmill", withExtension: "xcarchive")!
        let info = Archive.Info.make(at: URL(string: "any")!)
        let archive = Archive(url: url, info: info)
        
        let export = Process.makeExport(projectAt: Project.Location(project: project, url: any), archive: archive, exportDirectoryURL: exportDirectoryURL, resultBundle: resultBundle, log: FileManager.default.trashDirectoryURL.appendingPathComponent(CharacterSet.Windmill.random()))
        
        processManager.launch(process: export, wasSuccesful: { _ in
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 45.0)
    }

}
