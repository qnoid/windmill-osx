//
//  SubscriptionError.swift
//  windmill
//
//  Created by Markos Charatzas on 06/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

public enum SubscriptionError : Error {
    
    case failed
    case connectionError(error: URLError)
    case restoreFailed
    case restoreConnectionError(error: URLError)
    
    public enum UnauthorisationReason: String {
        case expired
        
        var key: String {
            switch self {
            case .expired:
                return "subscription.expired"
            }
        }
    }
    
    case unauthorised(reason: UnauthorisationReason?)
    case outdated
}

extension SubscriptionError : CustomNSError, LocalizedError {
    
    public static var errorDomain: String {
        return "io.windmill.windmill"
    }
    
    public var errorTitle: String? {
        switch self {
        case .failed:
            return "Your purchase was succesful"
        case .connectionError:
            return "Your purchase was succesful"
        case .restoreFailed:
            return "Restore Failed"
        case .restoreConnectionError:
            return "Restore Failed"
        case .unauthorised(let reason):
            switch reason {
            case (.expired?):
                return "Subscription Expired"
            default:
                return "Subscription Access"
            }
        default:
            return ""
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .failed:
            return "There was an unexpected error while buying/renewing your subscription.\n\n"
        case .connectionError:
            return nil
        case .restoreFailed:
            return "There was an unexpected error while restoring your subscription.\n"
        case .restoreConnectionError:
            return nil
        case .unauthorised(let reason):
            if let reason = reason {
                return NSLocalizedString("\(SubscriptionError.errorDomain).\(reason.key)", comment: "Your subscription has expired or may have not renewed just yet.\n")
            }
            else {
                return "Your Windmill subscription is no longer active.\n"
            }
        default:
            return nil
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .failed:
            return nil
        case .connectionError:
            return "Buying/renewing your subscription failed because of a network error.\n\n"
        case .restoreFailed:
            return nil
        case .restoreConnectionError:
            return "Restoring your subscription failed because of a network error."
        case .unauthorised:
            return nil
        default:
            return nil
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .failed:
            return "Windmill will try again sometime later.\nOptionally, you can contact qnoid@windmill.io"
        case .connectionError:
            return "Windmill will try again sometime later.\nOptionally, under your Account, you can choose to Refresh later."
        case .restoreFailed:
            return "You can try again some time later or contact qnoid@windmill.io."
        case .restoreConnectionError:
            return nil
        case .unauthorised(let reason):
            switch reason {
            case (.expired?):
                return "In the latter case, Windmill will try again sometime later. Optionally, under your Account, you can choose to Refresh now."
            default:
                return "You can purchase a new subscription or contact qnoid@windmill.io"
            }
        default:
            return nil
        }
    }
    
    public var isUnauthorised: Bool {
        switch self {
        case .unauthorised:
            return true
        default:
            return false
        }
    }
    
    public var isExpired: Bool {
        switch self {
        case .unauthorised(let reason?):
            return reason == .expired
        default:
            return false
        }
    }
}
