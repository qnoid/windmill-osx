//
//  BundleResult.swift
//  windmill
//
//  Created by Markos Charatzas on 3/3/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation

protocol Summary {
    var textDocumentLocation: TextDocumentLocation? { get }
}

public struct ResultBundle {
    
    public struct TestFailureSummary: Summary {
        
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
    
    public struct ErrorSummary: Summary {
        
        let values: [String: Any]
        
        /**
            Possible values as of Xcode 9.2
         
            "Swift Compiler Error"
            "Code Signing Error"
            "Dependency Analysis Error"
 
        */
        var issueType: String {
            let issueType = values["IssueType"] as? String
            
            return issueType ?? ""
        }
        
        var message: String {
            let message = values["Message"] as? String
            
            return message ?? ""
        }
        
        var target: String {
            let target = values["Target"] as? String
            
            return target ?? ""
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
        return ResultBundle(url: url, info: info)
    }
    
    let url: URL
    let info: Info
}
