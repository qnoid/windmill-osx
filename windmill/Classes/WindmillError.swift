//
//  WindmillError.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 11/03/2019.
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
