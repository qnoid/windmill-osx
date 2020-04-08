//
//  TestSummaries.swift
//  windmill
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

import Foundation

extension Array where Element == Test {
    
    var actual: Array<Test> {
        if let tests = self.first(where: { $0.testName == "All tests" } ) {
            if let xctest = tests.subtests.first(where: { $0.testName.contains("xctest") }) {
                return xctest.subtests
            } else if let framework = tests.subtests.first(where: { $0.testName.contains("framework") }) {
                return framework.subtests
            }
            else {
                return tests.subtests
            }
        }
        else {
            return self
        }
    }
}

struct FailureSummary: Summary {
    var documentURL: URL? {
        
        if let string = values["FileName"] as? String {
            return URL(fileURLWithPath: string)
        }
        
        return nil
    }
    
    var lineNumber: Int {
        let lineNumber = values["LineNumber"] as? Int
        
        return lineNumber ?? -1
    }
    
    var characterRange: NSRange? {
        return nil
    }
    
    var characterRangeLoc: Int {
        return -1
    }

    var message: String {
        return values["Message"] as? String ?? ""
    }

    let values: [String: Any]
}

protocol PerformanceTest {
    var isPerformance: Bool { get }
    
    func iterations(metric: PerformanceMetric) -> Int
    
    func average() throws -> Double
}

extension Test {
    
    func iterations(metric: PerformanceMetric) -> Int {
        return metric.measurements.count
    }
    
    func average() throws -> Double {
        
        guard isPerformance, let performanceMetric = self.performanceMetrics.first else {
            throw NSError(domain: WindmillErrorDomain, code: -1, userInfo: nil)
        }
        
        let measurements = performanceMetric.measurements.reduce(0, +)
        
        return round(1000 * measurements) / Double(self.iterations(metric: performanceMetric)) / 1000.0
    }
}

struct PerformanceMetric {

    let values: [String: Any]
    
    var measurements: [Double] {
        let measurements: [Double]? = values["Measurements"] as? [Double]
        
        return measurements ?? []
    }
}

struct Test: PerformanceTest {
    
    var isPerformance: Bool {
        return self.performanceMetrics.count > 0
    }
    
    let values: [String: Any]
    
    var testIdentifier: String {
        let testIdentifier = values["TestIdentifier"] as? String
        
        return testIdentifier ?? ""
    }
    
    var testName: String {
        let testName = values["TestName"] as? String
        
        return testName ?? ""
    }

    var duration: NSNumber {
        let duration = values["Duration"] as? NSNumber
        
        return duration ?? 0.0
    }
    
    var testStatus: TestStatus? {
        guard let testStatus = values["TestStatus"] as? String else {
            return nil
        }

        return TestStatus(rawValue: testStatus)
    }
    
    var performanceMetrics: [PerformanceMetric] {
        let performanceMetrics:[[String: Any]]? = values["PerformanceMetrics"] as? [[String : Any]]

        return performanceMetrics?.map { dictionary -> PerformanceMetric in
            return PerformanceMetric(values: dictionary)
            } ?? []
    }
    
    var failureSummaries: [FailureSummary] {
        let failureSummaries:[[String: Any]]? = values["FailureSummaries"] as? [[String : Any]]
        
        return failureSummaries?.map { dictionary -> FailureSummary in
            return FailureSummary(values: dictionary)
        } ?? []
    }
    
    var subtests: [Test] {
        let subtests:[[String: Any]]? = values["Subtests"] as? [[String : Any]]
        
        return subtests?.map { dictionary in
            return Test(values: dictionary)
            } ?? []

    }
}

struct TestableSummary {
    
    let values: [String: Any]
    
    var testName: String {
        let testName = values["TestName"] as? String
        
        return testName ?? ""
    }
    
    var targetName: String {
        let targetName = values["TargetName"] as? String
        
        return targetName ?? ""
    }
    
    var tests: Array<Test> {
        let tests: [[String: Any]]? = values["Tests"] as? [[String : Any]]
        
        return tests?.map { dictionary in
            return Test(values: dictionary)
            } ?? []
    }
}

struct TestSummaries {
    
    static func make(at url: URL) -> TestSummaries {
        return TestSummaries(metadata: MetadataPlistEncoded(url: url))
    }
    
    private let metadata: Metadata
    let url: URL
    
    init(metadata: Metadata) {
        self.metadata = metadata
        self.url = metadata.url
    }
    
    var testableSummaries: [TestableSummary] {
        let testableSummaries:[[String: Any]]? = metadata["TestableSummaries"]
        
        return testableSummaries?.map { dictionary in
            return TestableSummary(values: dictionary)
            } ?? []
    }

}


