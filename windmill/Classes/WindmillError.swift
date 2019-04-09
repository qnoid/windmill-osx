//
//  WindmillError.swift
//  windmill
//
//  Created by Markos Charatzas on 11/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

public enum WindmillError: Error {
    case recoverable(activityType: ActivityType, error: Error?)
    case fatal(activityType: ActivityType) //only activity types of the WindmillErrorDomain
}

extension WindmillError : CustomNSError, LocalizedError {
    
    public static var errorDomain: String {
        return WindmillErrorDomain
    }
    
    public var errorDescription: String? {
        switch self {
        case .fatal(let activityType):
            return NSLocalizedString("windmill.activity.\(activityType.rawValue).error.description", comment: "Failed")
        case .recoverable(_, let error?):
            return error.localizedDescription
        case .recoverable(let activityType, _):
            return NSLocalizedString("windmill.activity.\(activityType.rawValue).error.description", comment: "Failed")
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .recoverable(_, let error?):
            return (error as NSError).localizedFailureReason
        case .fatal(let activityType), .recoverable(let activityType, _):
            return NSLocalizedString("windmill.activity.\(activityType.rawValue).error.failure.reason", comment: "")
        }
    }
    
    public var isRecoverable: Bool {
        switch self {
        case .recoverable:
            return true
        default:
            return false
        }
    }

}
