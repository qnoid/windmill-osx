//
//  BundleResult.swift
//  windmill
//
//  Created by Markos Charatzas on 3/3/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
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
