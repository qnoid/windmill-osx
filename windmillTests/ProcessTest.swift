//
//  ProcessTest.swift
//  windmillTests
//
//  Created by Markos Charatzas (markos@qnoid.com) on 09/08/2017.
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

    let bundle: Bundle = Bundle(for: ProcessTest.self)
    
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
        let read = process.manager_waitForDataInBackground(standardOutputPipe, queue: queue) { availableString, count in
            actualAvailableString = availableString
            actualCount = count
            expectation.fulfill()
        }

        read.activate()
        process.launch()

        queue.async {
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
        let read = process.manager_waitForDataInBackground(standardOutputPipe, queue: queue) { availableString, count in
            actualAvailableString = availableString
            actualCount = count
            expectation.fulfill()
        }

        read.activate()
        process.launch()

        queue.async {
            process.waitUntilExit()
        }
        
        self.waitForExpectations(timeout: 5.0, handler: nil)
        XCTAssertEqual(actualAvailableString, "🥑\n")
        XCTAssertEqual(actualCount, "🥑\n".utf8.count)
    }
    
    /**
     */
    func testGivenProjectAssertMakeTestConfigurationFileExists() {

        let buildSettingsMetadataURL = bundle.url(forResource: "ProcessTest/build/settings", withExtension: "json")!
        let buildSettings = BuildSettings(url: buildSettingsMetadataURL)
        let devicesMetadataURL = Bundle(for: ProcessTest.self).url(forResource: "ProcessTest/test/devices", withExtension: "json")!
        let devices = Devices(metadata: MetadataJSONEncoded(url: devicesMetadataURL))
        
        let process = Process.makeList(devices: devices, for: buildSettings.deployment)
        
        process.launch()
        process.waitUntilExit()
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: devices.url.path))
        
        XCTAssertGreaterThanOrEqual(devices.version!, 11.3)
        XCTAssertEqual(devices.platform, "iOS")
        XCTAssertNotNil(devices.destination?.name)
        XCTAssertNotNil(devices.destination?.udid)
    }
    
    func testGivenProjectWithoutAvailableSimulatorAssertMakeTestConfigurationFileExists() {
        
        let buildSettingsMetadataURL = bundle.url(forResource: "ProcessTest/build/settings", withExtension: "json")!
        let buildSettings = BuildSettings(url: buildSettingsMetadataURL)
        let devicesMetadataURL = Bundle(for: ProcessTest.self).url(forResource: "ProcessTest/test/devices", withExtension: "json")!
        let devices = Devices(metadata: MetadataJSONEncoded(url: devicesMetadataURL))
        
        let process = Process.makeList(devices: devices, for: buildSettings.deployment)

        process.launch()
        process.waitUntilExit()
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: devices.url.path))
        

        XCTAssertGreaterThanOrEqual(devices.version!, 11.3)
        XCTAssertEqual(devices.platform, "iOS")
        XCTAssertNotNil(devices.destination?.name)
        XCTAssertNotNil(devices.destination?.udid)
    }
}
