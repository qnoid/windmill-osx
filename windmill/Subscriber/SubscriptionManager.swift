//
//  SubscriptionManager.swift
//  windmill
//
//  Created by Markos Charatzas on 12/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import AppKit
import Alamofire
import CloudKit
import os

class SubscriptionManager: NSObject {

    typealias SubscriptionClaimCompletion = (_ account: Account?, _ claim: SubscriptionClaim?, _ error: Error?) -> Void

    public static let SubscriptionActive = Notification.Name("io.windmill.windmill.subscription.active")
    public static let SubscriptionFailed = Notification.Name("io.windmill.windmill.subscription.failed")
    public static let SubscriptionExpired = Notification.Name("io.windmill.windmill.subscription.expired")

    static let shared: SubscriptionManager = SubscriptionManager()
    
    let preferences = Preferences.shared
    
    let subscriptionResource = SubscriptionResource()
    let accountResource = AccountResource()
    let database: CKDatabase = CKContainer(identifier: "iCloud.io.windmill.windmill.macos").privateCloudDatabase

    //MARK: private
    private func subscriptionNotification(userInfo: [String : Any], zoneId: CKRecordZone.ID = CKRecordZone.ID(zoneName: "Windmill", ownerName: CKCurrentUserDefaultName), recordName: String = "account", value: String = "claim", completion: @escaping SubscriptionClaimCompletion) {
        
        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)
        
        guard notification?.notificationType == .query, let queryNotification = notification as? CKQueryNotification else {
            preconditionFailure("Can only handle query notifications. If you have since created a new notification, you must update this code.")
        }// check on the subscriptionID to confirm the notification fired rather than assume its the subscription one.
        
        let recordFields = queryNotification.recordFields
        
        guard let recordName = recordFields?[recordName] as? String, let claim = recordFields?[value] as? String else {
            os_log("error reading values from recordfields '%{public}@'", log: .default, type: .error, recordFields ?? "empty")
            return
        }
        
        self.database.fetch(withRecordID: CKRecord.ID(recordName: recordName, zoneID: zoneId), completionHandler: { record, error in
            switch error {
            case .some(let error):
                DispatchQueue.main.async {
                    completion(nil, nil, error)
                }
            case .none:
                if let account = record?["identifier"] as? String {
                    DispatchQueue.main.async {
                        completion(Account(identifier: account), SubscriptionClaim(value: claim), nil)
                    }
                }
            }
        })
    }

    private func registerForSubscriptionNotifications(zoneId: CKRecordZone.ID = CKRecordZone.ID(zoneName: "Windmill", ownerName: CKCurrentUserDefaultName), desiredKeys: [CKRecord.FieldKey]? = [CKRecord.FieldKey("account"), CKRecord.FieldKey("claim")], completionHandler: @escaping (CKSubscription?, Error?) -> Void) {

        let predicate = NSPredicate(value: true)
        let querySubscription =
            CKQuerySubscription(recordType: "Subscription", predicate: predicate, options: [.firesOnRecordCreation, .firesOnRecordUpdate])
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.desiredKeys = desiredKeys
        querySubscription.notificationInfo = notificationInfo
        
        self.database.fetch(withRecordZoneID: zoneId) { (recordZone, error) in
            
            switch(recordZone, error){
            case(let recordZone?, _):
                querySubscription.zoneID = recordZone.zoneID
                self.database.save(querySubscription) { (subscription, error) in
                    DispatchQueue.main.async {
                        completionHandler(subscription, error)
                    }
                }
            case(_, let error?):
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            case (.none, .none):
                preconditionFailure("Must have either recordZone returned or an error")
            }
            
        }
    }
    
    //MARK: module
    func subscriptionNotification(userInfo: [String : Any]) {
        self.subscriptionNotification(userInfo: userInfo) { (account, claim, error) in
            
            switch error {
            case .some(let error):
                os_log("Error while processing subscription notification: '%{public}@'", log: .default, type: .error, error.localizedDescription)
            case .none:
                if let account = account, let claim = claim {
                    Keychain.default.write(value: claim.value, key: .subscriptionClaim)
                    Keychain.default.write(value: account.identifier, key: .account)
                    
                    self.requestSubscription(account: account, claim: claim) { token, error in
                        if let error = error {
                            os_log("Error while asking for subscription authorization token: '%{public}@'.", log: .default, type: .error, error.localizedDescription)
                        } else {
                            os_log("Successfully retrieved subscription authorization token.", log: .default, type: .debug)
                        }
                    }
                }
            }
        }
    }

    func registerForSubscriptionNotifications() {
        
        NSApplication.shared.registerForRemoteNotifications()

        guard !self.preferences.registerForSubscriptionNotifications else {
            os_log("SubscriptionManager has already registered for subscription for notifications.", log: .default, type: .debug)
            return
        }
        
        self.registerForSubscriptionNotifications { (subscription, error) in
            
            switch (subscription, error) {
            case (_, let error?):
                os_log("error while registering for subscription notifications: '%{public}@'", log: .default, type: .error, error.localizedDescription)
            case (let subscription?, _):
                os_log("subscription: '%{public}@'", log: .default, type: .debug, subscription)
                self.preferences.registerForSubscriptionNotifications = true
            default:
                return
            }
        }
    }
    
    //MARK: public
    func requestSubscription(account: Account, claim: SubscriptionClaim, completion: @escaping SubscriptionResource.SubscriptionAuthorizationTokenCompletion) {
        self.subscriptionResource.requestSubscriptionAuthorizationToken(forAccount: account, claim: claim, completion: { token, error in
            
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
    
    func distribute(export: Export, authorizationToken: SubscriptionAuthorizationToken, forAccount account: Account, completion: @escaping AccountResource.ExportCompletion) {
        
        self.accountResource.requestExport(export: export, forAccount: account, authorizationToken: authorizationToken, completion: { itms, error in
            
            if case let error as SubscriptionError = error, error.isExpired {
                NotificationCenter.default.post(name: SubscriptionManager.SubscriptionExpired, object: self, userInfo: ["error": error])
                completion(nil, error)
            } else {
                completion(itms, error)
            }
        })
    }

    public func refreshSubscription(completion: @escaping SubscriptionResource.SubscriptionAuthorizationTokenCompletion) {
        if let account = try? Keychain.default.read(key: .account), let claim = try? Keychain.default.read(key: .subscriptionClaim) {
            self.requestSubscription(account: Account(identifier: account), claim: SubscriptionClaim(value: claim), completion: completion)
        }
    }
}
