//
//  BundleResult.swift
//  windmill
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

import Foundation

protocol Summary {
    var documentURL: URL? { get }
    var lineNumber: Int { get }
    
    var characterRange: NSRange? { get }
    var characterRangeLoc: Int { get }
}

struct TextDocumentLocationSummary: Summary {
    
    var documentURL: URL? {
        return textDocumentLocation.documentURL
    }
    
    var lineNumber: Int {
        return textDocumentLocation.startingLineNumber + 1
    }
    
    var characterRange: NSRange? {
        return textDocumentLocation.characterRange
    }
    
    var characterRangeLoc: Int {
        return textDocumentLocation.characterRangeLoc
    }
    
    let textDocumentLocation: TextDocumentLocation
    
    init?(textDocumentLocation: TextDocumentLocation?) {
        guard let textDocumentLocation = textDocumentLocation else {
            return nil
        }
        
        self.textDocumentLocation = textDocumentLocation
    }
}

public struct ResultBundle {
    
    public struct TestFailureSummary {
        
        let values: [String: Any]
        
        /**
         Possible values as of Xcode 9.2
         
         "Uncategorized"
         
         */
        var issueType: String {
            let issueType = values["IssueType"] as? String
            
            return issueType ?? ""
        }
        
        var message: String {
            let message = values["Message"] as? String
            
            return message ?? ""
        }
        
        var testCase: String {
            let testCase = values["TestCase"] as? String
            
            return testCase ?? ""
        }
        
        /*
         Depending on the `issueType`, this returns additional information.
         
         e.g. a "Swift Compiler Error", has a `textDocumentLocation` with the name of the file and line number information as to where the error occured.
         */
        var textDocumentLocation: TextDocumentLocation? {
            guard let documentLocationData = values["DocumentLocationData"] as? Data else {
                return nil
            }
            
            return (try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(documentLocationData)) as? TextDocumentLocation
        }
    }
    
    public struct ErrorSummary {
        
        let values: [String: Any]
        
        /**
            Possible values as of Xcode 9.2
         
            "Swift Compiler Error"
            "Code Signing Error"
            "Dependency Analysis Error"
 
        */
        var issueType: String? {
            return values["IssueType"] as? String
        }
        
        var message: String? {
            return values["Message"] as? String
        }
        
        var target: String? {
            return values["Target"] as? String
        }
        
        /*
            Depending on the `issueType`, this returns additional information.
         
            e.g. a "Swift Compiler Error", has a `textDocumentLocation` with the name of the file and line number information as to where the error occured.
         */
        var textDocumentLocation: TextDocumentLocation? {
            guard let documentLocationData = values["DocumentLocationData"] as? Data else {
                return nil
            }
            
            return (try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(documentLocationData)) as? TextDocumentLocation
        }
    }

    struct Info {
        
        static func make(at url: URL) -> Info {
            return Info(metadata: MetadataPlistEncoded(url: url))
        }

        private let metadata: Metadata
        let url: URL
        
        init(metadata: Metadata) {
            self.metadata = metadata
            self.url = metadata.url
        }
        
        var errorCount: Int {
            let errorCount: Int? = metadata["ErrorCount"]
            
            return errorCount ?? errorSummaries.count
        }
        
        var errorSummaries: [ErrorSummary] {
            let errorSummaries:[[String: Any]]? = metadata["ErrorSummaries"]
            
            return errorSummaries?.map { dictionary in
                return ErrorSummary(values: dictionary)
            } ?? []
        }
        
        var testsCount: Int? {
            let testsCount: Int? = metadata["TestsCount"]
            
            return testsCount
        }

        var testsFailedCount: Int? {
            let testsFailedCount: Int? = metadata["TestsFailedCount"]
            
            return testsFailedCount
        }
        
        var testFailureSummaries: [TestFailureSummary] {
            let testFailureSummaries:[[String: Any]]? = metadata["TestFailureSummaries"]
            
            return testFailureSummaries?.map { dictionary in
                return TestFailureSummary(values: dictionary)
                } ?? []
        }
    }
    
    static func make(at url: URL, info: ResultBundle.Info) -> ResultBundle {
        return ResultBundle(url: url, info: info, testSummaries: nil)
    }

    static func make(at url: URL, info: ResultBundle.Info, testSummaries: TestSummaries) -> ResultBundle {
        return ResultBundle(url: url, info: info, testSummaries: testSummaries)
    }

    let url: URL
    let info: Info
    
    //available on the test action
    let testSummaries: TestSummaries?
}
