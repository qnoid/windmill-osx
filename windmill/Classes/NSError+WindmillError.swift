//
//  NSError+WindmillError.swift
//  windmill
//
//  Created by Markos Charatzas on 17/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation

extension NSError
{
    enum WindmillErrorCode : Int {
        
        /// No Repo
        
        case NoRepoError
        
        /// Error loading repo
        case RepoError
        
        /// Error loading commit
        case CommitError
    }
    
    class func errorNoRepo(localGitRepo: String) -> WindmillError
    {
        let failureDescription = "Error parsing location of local git repo: \(localGitRepo)"
        
        return NSError(domain: WindmillDomain, code: WindmillErrorCode.NoRepoError.rawValue, userInfo:
            [NSLocalizedDescriptionKey: failureDescription,
                NSLocalizedFailureReasonErrorKey: NSLocalizedString("windmill.latestCommit.error.failureReason", comment:"")])
    }
    
    class func errorRepo(localGitRepo: String, underlyingError : NSError) -> WindmillError
    {
        let localizedDescription = NSLocalizedString("windmill.repo.error.description", comment:"")
        let failureDescription = String(format:localizedDescription, localGitRepo)
        
        return NSError(domain: WindmillDomain, code: WindmillErrorCode.RepoError.rawValue, userInfo:
            [NSLocalizedDescriptionKey: failureDescription,
                NSLocalizedFailureReasonErrorKey: NSLocalizedString("windmill.repo.error.failureReason", comment:""),
                NSUnderlyingErrorKey: underlyingError])
    }
    
    class func errorCommit(underlyingError : NSError) -> WindmillError {
        return NSError(domain: WindmillDomain, code: WindmillErrorCode.CommitError.rawValue, userInfo:
            [NSLocalizedDescriptionKey: NSLocalizedString("windmill.latestCommit.error.description", comment:""),
                NSLocalizedFailureReasonErrorKey: NSLocalizedString("windmill.latestCommit.error.failureReason", comment:""),
                NSUnderlyingErrorKey: underlyingError])
    }
}