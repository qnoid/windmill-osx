//
//  SubscriptionManager.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 12/03/2019.
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

import AppKit
import Alamofire
import CloudKit
import os

class SubscriptionManager: NSObject {

    typealias ResultCompletion = (Swift.Result<Void, Error>) -> Swift.Void
    public static let FetchResultCompletionIgnore: ResultCompletion = { result in
        
    }
    
    public static let SubscriptionActive = Notification.Name("io.windmill.windmill.subscription.active")
    public static let SubscriptionFailed = Notification.Name("io.windmill.windmill.subscription.failed")
    public static let SubscriptionExpired = Notification.Name("io.windmill.windmill.subscription.expired")

    static let shared: SubscriptionManager = SubscriptionManager()
    
    let preferences = Preferences.shared
    
    let cloudKitManager = CloudKitManager()
    let subscriptionResource = SubscriptionResource()
    let accountResource = AccountResource()
    
    //MARK: module
    func subscriptionNotification(userInfo: [String : Any]) {
        self.cloudKitManager.subscriptionNotification(userInfo: userInfo) { account, claim, error in
            
            if let error = error {
                os_log("Error while qyering CloudKit for Account/Subscription: '%{public}@'.", log: .default, type: .error, error.localizedDescription)
            } else {
                os_log("Successfully retrieved Account/Subscription from CloudKit.", log: .default, type: .debug)
            }

            if let account = account, let claim = claim {
                self.requestSubscription(account: account, claim: claim)
            }
        }
    }

    func registerForSubscriptionNotifications() {
        
        NSApplication.shared.registerForRemoteNotifications()

        guard !self.preferences.registerForSubscriptionNotifications else {
            os_log("SubscriptionManager has already registered for subscription for notifications.", log: .default, type: .debug)
            return
        }
        
        self.cloudKitManager.registerForSubscriptionNotifications { result in
            if case .success = result {
                self.preferences.registerForSubscriptionNotifications = true
            }
        }
    }
    
    public func fetchSubscription(completion: @escaping ResultCompletion = FetchResultCompletionIgnore) {
        self.cloudKitManager.fetchSubscription { result in
            switch result {
            case .failure(let error as CKError) where error.code == .zoneNotFound:
                completion(.failure(SubscriptionError.notFound))
            case .failure(let error):
                completion(.failure(error))
            case .success:
                if let account = try? Keychain.default.read(key: .account), let claim = try? Keychain.default.read(key: .subscriptionClaim) {
                    self.requestSubscription(account: Account(identifier: account), claim: SubscriptionClaim(value: claim))
                }
                
                completion(.success(()))
            }
        }
    }
    
    //MARK: public
    func requestSubscription(account: Account, claim: SubscriptionClaim, completion: @escaping SubscriptionResource.SubscriptionCompletion = SubscriptionResource.SubscriptionCompletionIgnore) {
        self.subscriptionResource.requestIsSubscriber(forAccount: account, claim: claim, completion: { token, error in
            
            switch error {
            case let error as AFError where error.isResponseValidationError:
                switch error.responseCode {
                case 403:
                    os_log("The claim was invalid: '%{public}@'", log: .default, type: .error, error.localizedDescription)
                default:
                    NotificationCenter.default.post(name: SubscriptionManager.SubscriptionFailed, object: self, userInfo: ["error": SubscriptionError.failed])
                }
            case let error as URLError:
                NotificationCenter.default.post(name: SubscriptionManager.SubscriptionFailed, object: self, userInfo: ["error": SubscriptionError.connectionError(error: error)])
            case .some(let error):
                NotificationCenter.default.post(name: SubscriptionManager.SubscriptionFailed, object: self, userInfo: ["error": error])
            case .none:
                if let token = token?.value {
                    Keychain.default.write(value: token, key: .subscriptionAuthorizationToken)
                }
                
                NotificationCenter.default.post(name: SubscriptionManager.SubscriptionActive, object: self)
            }
            
            completion(token, error)
        })
    }
    
    func distribute(export: Export, metadata: Export.Metadata, authorizationToken: SubscriptionAuthorizationToken, forAccount account: Account, completion: @escaping AccountResource.ExportCompletion) {
        
        self.accountResource.requestExport(export: export, metadata: metadata, forAccount: account, authorizationToken: authorizationToken, completion: { itms, error in
            
            if case let error as SubscriptionError = error, error.isExpired {
                NotificationCenter.default.post(name: SubscriptionManager.SubscriptionExpired, object: self, userInfo: ["error": error])
                completion(nil, error)
            } else {
                completion(itms, error)
            }
        })
    }
}
