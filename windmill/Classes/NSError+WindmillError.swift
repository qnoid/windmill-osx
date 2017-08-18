//
//  NSError+WindmillError.swift
//  windmill
//
//  Created by Markos Charatzas on 17/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation
import os

extension NSError
{
    enum WindmillErrorCode : Int {
        
        /// No Repo
        
        case noRepoError
        
        /// Error loading repo
        case repoError
        
        /// Error loading commit
        case commitError
    }
    
    class func errorNoRepo(_ localGitRepo: String) -> Error
    {
        let failureDescription = "Error parsing location of local git repo: \(localGitRepo)"
        
        return NSError(domain: WindmillDomain, code: WindmillErrorCode.noRepoError.rawValue, userInfo:
            [NSLocalizedDescriptionKey: failureDescription,
             NSLocalizedFailureReasonErrorKey: NSLocalizedString("windmill.latestCommit.error.failureReason", comment:"")])
    }
    
    class func errorRepo(_ localGitRepo: String, underlyingError : NSError? = nil) -> Error
    {
        let localizedDescription = NSLocalizedString("windmill.repo.error.description", comment:"")
        let failureDescription = String(format:localizedDescription, localGitRepo)
        
        if let underlyingError = underlyingError {
            return NSError(domain: WindmillDomain, code: WindmillErrorCode.repoError.rawValue, userInfo:
                [NSLocalizedDescriptionKey: failureDescription,
                 NSLocalizedFailureReasonErrorKey: NSLocalizedString("windmill.repo.error.failureReason", comment:""),
                 NSUnderlyingErrorKey: underlyingError])
        }
        
        return NSError(domain: WindmillDomain, code: WindmillErrorCode.repoError.rawValue, userInfo:
            [NSLocalizedDescriptionKey: failureDescription,
             NSLocalizedFailureReasonErrorKey: NSLocalizedString("windmill.repo.error.failureReason", comment:"")])
    }
    
    class func errorCommit(_ underlyingError : NSError) -> Error {
        return NSError(domain: WindmillDomain, code: WindmillErrorCode.commitError.rawValue, userInfo:
            [NSLocalizedDescriptionKey: NSLocalizedString("windmill.latestCommit.error.description", comment:""),
             NSLocalizedFailureReasonErrorKey: NSLocalizedString("windmill.latestCommit.error.failureReason", comment:""),
             NSUnderlyingErrorKey: underlyingError])
    }
    
    class func errorTermination(for activityType: ActivityType, status code: Int) -> Error
    {
        let failureDescription = "Activity '\(String(describing: activityType.rawValue))' exited with error"
        
        return NSError(domain: WindmillDomain, code: code, userInfo:
            [NSLocalizedDescriptionKey: failureDescription, "type": activityType])
    }
}
