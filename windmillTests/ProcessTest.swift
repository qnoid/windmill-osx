//
//  ProcessTest.swift
//  windmillTests
//
//  Created by Markos Charatzas on 09/08/2017.
//  Copyright © 2017 qnoid.com. All rights reserved.
//

import XCTest

@testable import windmill

class EphemeralFileManager: FileManager {
    
    let url: URL
    
    init(url: URL) {
        self.url = url

    }
    
    deinit {
        try? self.removeItem(at: url)
    }
}

class ProcessTest: XCTestCase {

    func testGivenProcessOutputAssertCallback() {
     
        let queue = DispatchQueue(label: "any")
        
        let process = Process()
        process.launchPath = "/bin/echo"
        process.arguments = ["Hello World"]
        let standardOutputPipe = Pipe()
        process.standardOutput = standardOutputPipe
        
        let expectation = self.expectation(description: #function)

        var actualAvailableString: String?
        var actualCount = 0
        process.windmill_waitForDataInBackground(standardOutputPipe, queue: queue) { availableString, count in
            actualAvailableString = availableString
            actualCount = count
            expectation.fulfill()
        }
        
        queue.async {
            process.launch()
            process.waitUntilExit()
        }
        
        self.waitForExpectations(timeout: 5.0, handler: nil)
        XCTAssertEqual(actualAvailableString, "Hello World\n")
        XCTAssertEqual(actualCount, "Hello World\n".count)
    }
    
    func testGivenUnicodeOutputAssertStringCount() {
        
        let queue = DispatchQueue(label: "any")

        let process = Process()
        process.launchPath = "/bin/echo"
        process.arguments = ["🥑"]
        let standardOutputPipe = Pipe()
        process.standardOutput = standardOutputPipe
        
        let expectation = self.expectation(description: #function)
        
        var actualAvailableString: String?
        var actualCount = 0
        process.windmill_waitForDataInBackground(standardOutputPipe, queue: queue) { availableString, count in
            actualAvailableString = availableString
            actualCount = count
            expectation.fulfill()
        }
        
        queue.async {
            process.launch()
            process.waitUntilExit()
        }
        
        self.waitForExpectations(timeout: 2 * 60.0, handler: nil)
        XCTAssertEqual(actualAvailableString, "🥑\n")
        XCTAssertEqual(actualCount, "🥑\n".count)
    }
    
    /**
     - Precondition: a checked out project
     */
    func testGivenProjectAssertMakeTestConfigurationFileExists() {
        
        let project = Project(name: "windmill-ios", scheme: "windmill", origin: "foo")
        
        let metadata = MetadataJSONEncoded.testMetadata(for: project)
        
        let manager = EphemeralFileManager(url: metadata.url)
        
        let directoryPath = project.directoryPathURL.path
        
        let process = Process.makeReadTestMetadata(directoryPath: directoryPath, forProject: project, metadata: metadata)
        
        process.launch()
        process.waitUntilExit()
        
        XCTAssertTrue(manager.fileExists(atPath: metadata.url.path))
        
        let deployment: [String: String] = metadata["deployment"]!
        let destination: [String: String] = metadata["destination"]!
        XCTAssertEqual(deployment["target"], "10.3")
        XCTAssertEqual(destination["name"], "iPhone 5s")
    }
}
