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
        
        /// No origin
        case noOriginError
        
        /// Error loading commit
        case commitError

        /// Error loading commit
        case listDevicesError
        
        /// CKContainer.default().accountStatus returned .noAccount
        case noAccountError
    }
    
    class func domain(type: ActivityType) -> String {
        switch type {
        case .showBuildSettings, .devices, .readProjectConfiguration, .checkout, .distribute:
            return WindmillErrorDomain
        case .build, .test, .archive, .export:
            return NSPOSIXErrorDomain
        }
    }

    class func errorNoRepo(_ localGitRepo: String) -> Error
    {
        let failureDescription = "Error parsing location of local git repo: \(localGitRepo)"
        
        return NSError(domain: WindmillErrorDomain, code: WindmillErrorCode.noRepoError.rawValue, userInfo:
            [NSLocalizedDescriptionKey: failureDescription,
             NSLocalizedFailureReasonErrorKey: NSLocalizedString("windmill.repo.error.failureReason", comment:"")])
    }
    
    class func errorRepo(_ localGitRepo: String, underlyingError : NSError? = nil) -> Error
    {
        let localizedDescription = NSLocalizedString("windmill.repo.error.description", comment:"")
        let failureDescription = String(format:localizedDescription, localGitRepo)
        
        if let underlyingError = underlyingError {
            return NSError(domain: WindmillErrorDomain, code: WindmillErrorCode.repoError.rawValue, userInfo:
                [NSLocalizedDescriptionKey: failureDescription,
                 NSLocalizedFailureReasonErrorKey: NSLocalizedString("windmill.repo.error.failureReason", comment:""),
                 NSUnderlyingErrorKey: underlyingError])
        }
        
        return NSError(domain: WindmillErrorDomain, code: WindmillErrorCode.repoError.rawValue, userInfo:
            [NSLocalizedDescriptionKey: failureDescription,
             NSLocalizedFailureReasonErrorKey: NSLocalizedString("windmill.repo.error.failureReason", comment:"")])
    }

    class func noOriginError(_ localGitRepo: String) -> Error
    {
        let localizedDescription = NSLocalizedString("windmill.noOriginError.error.description", comment:"")
        let failureDescription = String(format:localizedDescription, localGitRepo)
        
        return NSError(domain: WindmillErrorDomain, code: WindmillErrorCode.noOriginError.rawValue, userInfo:
            [NSLocalizedDescriptionKey: failureDescription,
             NSLocalizedFailureReasonErrorKey: NSLocalizedString("windmill.noOriginError.error.failureReason", comment:"")])
    }

    class func errorCommit(_ underlyingError : NSError) -> Error {
        return NSError(domain: WindmillErrorDomain, code: WindmillErrorCode.commitError.rawValue, userInfo:
            [NSLocalizedDescriptionKey: NSLocalizedString("windmill.latestCommit.error.description", comment:""),
             NSLocalizedFailureReasonErrorKey: NSLocalizedString("windmill.latestCommit.error.failureReason", comment:""),
             NSUnderlyingErrorKey: underlyingError])
    }
    
    class func errorNoAccount() -> Error {
        return NSError(domain: WindmillErrorDomain, code: WindmillErrorCode.noAccountError.rawValue, userInfo:
            [NSLocalizedDescriptionKey: "Windmill requires you to be logged in using your Apple ID to start distributing your apps.",
             NSLocalizedRecoverySuggestionErrorKey: "Go to Apple menu > System Preferences.\nSelect iCloud\nYou may need to authenticate. Enter your Apple ID and password. Click Sign In.\nSelect iCloud Drive\nSelect 'Options...'\nUnder 'Documents', make sure the check box for 'Windmill' is on"])
    }

    
    class func errorTermination(process: Process, for activityType: ActivityType, status code: Int32) -> NSError
    {
        let domain = NSError.domain(type: activityType)
        let localizedFailureReason = process.localizedFailureReason(type: activityType, exitStatus: code)
        
        return NSError(domain: domain, code: Int(code), userInfo:
            [NSLocalizedDescriptionKey: NSLocalizedString("windmill.activity.\(activityType.rawValue).error.description", comment: "Failed"), NSLocalizedFailureReasonErrorKey: localizedFailureReason])
    }
    
    class func activityError(underlyingError error: NSError, for activityType: ActivityType, status code: Int32, info: ResultBundle.Info) -> NSError
    {
        return NSError(domain: XcodeBuildErrorDomain, code: Int(code), userInfo:
            [NSUnderlyingErrorKey: error, NSLocalizedDescriptionKey: NSLocalizedString("windmill.activity.\(activityType.rawValue).error.description", comment: "Failed"), NSLocalizedFailureReasonErrorKey: String.localizedStringWithFormat(NSLocalizedString("%d \(activityType.rawValue) error(s).", comment: ""), info.errorCount)])
        
    }
    
    class func testError(underlyingError error: NSError, status code: Int32, info: ResultBundle.Info) -> NSError
    {
        return NSError(domain: XcodeBuildErrorDomain, code: Int(code), userInfo:
            [NSUnderlyingErrorKey: error, NSLocalizedDescriptionKey: NSLocalizedString("windmill.activity.test.failures.description", comment: "Test case(s) failed"), NSLocalizedFailureReasonErrorKey: String.localizedStringWithFormat(NSLocalizedString("%d test case(s) failed.", comment: ""), info.testsFailedCount ?? 0)])
        
    }

    class func error(for activityType: ActivityType, code: Int) -> NSError
    {
        let domain = NSError.domain(type: activityType)
        
        return NSError(domain: domain, code: code, userInfo:
            [NSLocalizedDescriptionKey: NSLocalizedString("windmill.activity.\(activityType.rawValue).error.description", comment: "Failed"),
             NSLocalizedFailureReasonErrorKey: NSLocalizedString("windmill.activity.\(activityType.rawValue).error.failure.reason", comment: "")])
    }
}
