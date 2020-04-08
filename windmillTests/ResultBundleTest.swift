//
//  BundleResultTest.swift
//  windmillTests
//
//  Created by Markos Charatzas (markos@qnoid.com) on 3/3/18.
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

class ResultBundleTest: XCTestCase {
    
    func testGivenBundleResultInfoWithZeroErrorCountAssertValues() {
        let url = Bundle(for: MetadataPlistEncodedTest.self).url(forResource: "InfoWithZeroErrorCount", withExtension: "plist")!
        
        XCTAssertNotNil(url)
        
        let bundleResult = ResultBundle.Info.make(at: url)
        
        XCTAssertEqual(0, bundleResult.errorCount)
        let errorSummaries = bundleResult.errorSummaries
        XCTAssertTrue(0 == errorSummaries.count)
    }
    
    
    func testGivenBundleResultInfoWithOneErrorCountAssertValues() {
        let url = Bundle(for: MetadataPlistEncodedTest.self).url(forResource: "InfoWithOneErrorCount", withExtension: "plist")!
        
        XCTAssertNotNil(url)
        
        let bundleResult = ResultBundle.Info.make(at: url)
        
        XCTAssertEqual(1, bundleResult.errorCount)
        let errorSummaries = bundleResult.errorSummaries
        XCTAssertNotNil(errorSummaries)
        let summary = errorSummaries[0]
        
        let textDocumentLocation = summary.textDocumentLocation
        
        XCTAssertNotNil(textDocumentLocation)
        XCTAssertNotNil(textDocumentLocation?.documentURL)
        XCTAssertEqual(URL(fileURLWithPath:"/Users/qnoid/Library/Caches/io.windmill.windmill/Sources/project-with-submodules/project-with-submodules/ViewController.swift"), textDocumentLocation?.documentURL)
        XCTAssertEqual(20, textDocumentLocation?.startingLineNumber)
        XCTAssertEqual(18, textDocumentLocation?.startingColumnNumber)
        XCTAssertEqual(20, textDocumentLocation?.endingLineNumber)
        XCTAssertEqual(18, textDocumentLocation?.endingColumnNumber)
        XCTAssertEqual(414, textDocumentLocation?.characterRangeLoc)
        XCTAssertEqual(0, textDocumentLocation?.characterRangeLen)
    }
    
    func testGivenBundleResultInfoWithManyErrorCountAssertValues() {
        let url = Bundle(for: MetadataPlistEncodedTest.self).url(forResource: "InfoWithManyErrorCount", withExtension: "plist")!
        
        XCTAssertNotNil(url)
        
        let bundleResult = ResultBundle.Info.make(at: url)
        
        XCTAssertNotEqual(0, bundleResult.errorCount)
        let errorSummaries = bundleResult.errorSummaries
        XCTAssertNotNil(errorSummaries)
        XCTAssertEqual(2, errorSummaries.count)
        
        let summary = errorSummaries[0]
        
        let textDocumentLocation = summary.textDocumentLocation
        
        XCTAssertNotNil(textDocumentLocation)
        XCTAssertNotNil(textDocumentLocation?.documentURL)
        XCTAssertEqual(URL(fileURLWithPath:"/Users/qnoid/Developer/windmill-examples/project-with-submodules/project-with-submodules/ViewController.swift"), textDocumentLocation?.documentURL)
        XCTAssertEqual(17, textDocumentLocation?.startingLineNumber)
        XCTAssertEqual(18, textDocumentLocation?.startingColumnNumber)
        XCTAssertEqual(17, textDocumentLocation?.endingLineNumber)
        XCTAssertEqual(18, textDocumentLocation?.endingColumnNumber)
        XCTAssertEqual(321, textDocumentLocation?.characterRangeLoc)
        XCTAssertEqual(0, textDocumentLocation?.characterRangeLen)
        
        XCTAssertNotNil(errorSummaries[1].textDocumentLocation)
        XCTAssertNotNil(errorSummaries[1].textDocumentLocation?.documentURL)
        XCTAssertEqual(URL(fileURLWithPath:"/Users/qnoid/Developer/windmill-examples/project-with-submodules/project-with-submodules/ViewController.swift"), errorSummaries[1].textDocumentLocation?.documentURL)
        XCTAssertEqual(20, errorSummaries[1].textDocumentLocation?.startingLineNumber)
        XCTAssertEqual(18, errorSummaries[1].textDocumentLocation?.startingColumnNumber)
        XCTAssertEqual(20, errorSummaries[1].textDocumentLocation?.endingLineNumber)
        XCTAssertEqual(18, errorSummaries[1].textDocumentLocation?.endingColumnNumber)
        XCTAssertEqual(415, errorSummaries[1].textDocumentLocation?.characterRangeLoc)
        XCTAssertEqual(0, errorSummaries[1].textDocumentLocation?.characterRangeLen)
    }

    func testGivenResultBundleWithIncompatibleErrorSummaryAssertNilReturned() {
        
        let url = Bundle(for: ResultBundleTest.self).url(forResource: "InfoWithUnsupportedDocumentLocationData", withExtension: "plist")!
        let data = try? Data(contentsOf: url)
        
        let propertyList = try? PropertyListSerialization.propertyList(from: data!, options: [], format: nil)
        let dictionary = propertyList as! [String: Any]
        
        let errorSummary = ResultBundle.ErrorSummary(values: dictionary)
        
        XCTAssertNil(errorSummary.textDocumentLocation)
    }

}

