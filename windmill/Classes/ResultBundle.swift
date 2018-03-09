//
//  BundleResult.swift
//  windmill
//
//  Created by Markos Charatzas on 3/3/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation

public struct ResultBundle {
    
    public struct ErrorSummary {
        
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
    }
    
    static func make(at url: URL, info: ResultBundle.Info) -> ResultBundle {
        return ResultBundle(url: url, info: info)
    }
    
    let url: URL
    let info: Info
}
