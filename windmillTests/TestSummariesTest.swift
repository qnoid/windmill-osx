//
//  TestSummariesTest.swift
//  windmillTests
//
//  Created by Markos Charatzas (markos@qnoid.com) on 22/3/18.
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

class TestSummariesTest: XCTestCase {

    func testGivenTestSummariesAssertValues() {
        let url = Bundle(for: TestSummariesTest.self).url(forResource: "TestSummaries", withExtension: "plist")!
        
        let testSummaries = TestSummaries(metadata: MetadataPlistEncoded(url: url))
        
        let testableSummaries = testSummaries.testableSummaries

        XCTAssertEqual(2, testableSummaries.count)
        
        let testableSummaryZero = testableSummaries[0]
        let testsZero = testableSummaryZero.tests

        XCTAssertEqual("windmillTests", testableSummaryZero.targetName)
        XCTAssertEqual("windmillTests", testableSummaryZero.testName)
        XCTAssertEqual("IntegrationTests", testableSummaries[1].targetName)
        XCTAssertEqual("IntegrationTests", testableSummaries[1].testName)

        XCTAssertEqual(1, testsZero.count)
        
        let testZero = testsZero[0]
        
        XCTAssertEqual(0.0123831033706665, testZero.duration)
        XCTAssertEqual("All tests", testZero.testIdentifier)
        XCTAssertEqual("All tests", testZero.testName)

        let subtests = testZero.subtests
        
        let subtestZero = subtests[0]
        
        XCTAssertEqual(0.0114690065383911, subtestZero.duration)
        XCTAssertEqual("windmillTests.xctest", subtestZero.testIdentifier)
        XCTAssertEqual("windmillTests.xctest", subtestZero.testName)

        let secondLevelSubtests = subtestZero.subtests
        
        let secondLevelSubtestZero = secondLevelSubtests[0]
        
        XCTAssertEqual(0.0110169649124146, secondLevelSubtestZero.duration)
        XCTAssertEqual("ApplicationStorageTest", secondLevelSubtestZero.testIdentifier)
        XCTAssertEqual("ApplicationStorageTest", secondLevelSubtestZero.testName)
    }
    
    func testGivenTestSummariesAssertSummaries() {
        let url = Bundle(for: TestSummariesTest.self).url(forResource: "TestSummariesWithFailureSummaries", withExtension: "plist")!
        
        let testSummaries = TestSummaries(metadata: MetadataPlistEncoded(url: url))
        
        let testableSummaries = testSummaries.testableSummaries
        let testableSummaryWithFailures = testableSummaries[0]
        
        let tests = testableSummaryWithFailures.tests.actual
        
        XCTAssertEqual(1, tests.count)
        XCTAssertEqual("ApplicationStorageTest", tests[0].testName)
        XCTAssertEqual(1, tests[0].subtests.count)
    }
    
    func testGivenTestSummariesInRuntimeAssertSummaries() {
        let url = Bundle(for: TestSummariesTest.self).url(forResource: "TestSummariesProducedInRuntimeByFramework", withExtension: "plist")!
        
        let testSummaries = TestSummaries(metadata: MetadataPlistEncoded(url: url))
        
        let testableSummaries = testSummaries.testableSummaries
        let testableSummaryWithFailures = testableSummaries[0]
        
        let tests = testableSummaryWithFailures.tests.actual
        
        XCTAssertEqual(1, tests.count)
        XCTAssertEqual("ApplicationStorageTest", tests[0].testName)
        XCTAssertEqual(1, tests[0].subtests.count)
    }

    func testGivenTestSummariesAssertFailureSummaries() {
        let url = Bundle(for: TestSummariesTest.self).url(forResource: "TestSummariesWithFailureSummaries", withExtension: "plist")!
        
        let testSummaries = TestSummaries(metadata: MetadataPlistEncoded(url: url))
        
        let testableSummaries = testSummaries.testableSummaries
        let testableSummaryWithFailures = testableSummaries[1]

        let tests = testableSummaryWithFailures.tests.actual
        
        XCTAssertEqual(1, tests.count)
        XCTAssertEqual("AccountResourceTest", tests[0].testName)
        XCTAssertEqual(3, tests[0].subtests.count)
    }
    
    func testGivenTestSummariesAssertPerformanceMeasurements() {
        let url = Bundle(for: TestSummariesTest.self).url(forResource: "TestSummariesWithPerformanceFailures", withExtension: "plist")!
        
        let testSummaries = TestSummaries(metadata: MetadataPlistEncoded(url: url))
        
        let testableSummaries = testSummaries.testableSummaries
        let testableSummaryWithFailures = testableSummaries[0]
        
        let roots = testableSummaryWithFailures.tests.actual
        let subtests = roots[0].subtests
        
        XCTAssertTrue(subtests[1].isPerformance)
        
        let performanceTest = subtests[1]
        let performanceMetric = performanceTest.performanceMetrics[0]

        XCTAssertTrue(10 == performanceMetric.measurements.count)

        XCTAssertEqual(0.0019, try! performanceTest.average())
        
    }
}

