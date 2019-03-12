//
//  WindmillError.swift
//  windmill
//
//  Created by Markos Charatzas on 11/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

public enum WindmillError: Error {
    case failed(activityType: ActivityType) //only activity types of the WindmillErrorDomain
}

extension WindmillError : CustomNSError, LocalizedError {
    
    public static var errorDomain: String {
        return WindmillErrorDomain
    }
    
    public var errorDescription: String? {
        switch self {
        case .failed(let activityType):
            return NSLocalizedString("windmill.activity.\(activityType.rawValue).error.description", comment: "Failed")
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .failed(let activityType):
            return NSLocalizedString("windmill.activity.\(activityType.rawValue).error.failure.reason", comment: "")
        }
    }
}
