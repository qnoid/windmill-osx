//
//  CloudKitManager.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 13/05/2019.
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
import CloudKit
import os

extension CKError {
    
    
    /**
     A fatal server error.
     
     You should correct the CKOperation before trying again.
     */
    func isFatalServerError() -> Bool {
        
        return self.code == CKError.internalError ||
            self.code == CKError.serverRejectedRequest ||
            self.code == CKError.invalidArguments ||
            self.code == CKError.permissionFailure
    }
    /**
     A retry server error.
     
     Reinitialise the same CLOperation, with the same arguments and retry.
     You should try again after 'x' seconds in CKRetryErrorRetryAfterKey as Double in error's userInfo dictionary.
     
     Alternatively, add a `CKOperation` to the `CKDatabase` which automatically retries.
     */
    func isRetryServerError() -> Bool {
        return self.code == CKError.Code.zoneBusy ||
            self.code == CKError.Code.serviceUnavailable ||
            self.code == CKError.Code.requestRateLimited
    }
}

class CloudKitManager {
    
    typealias SubscriptionClaimCompletion = (_ account: Account?, _ claim: SubscriptionClaim?, _ error: Error?) -> Void
    typealias FetchRecordCompletion = (_ record: CKRecord?, _ error: Error?) -> Void
    
    enum RecordType: CodingKey, CustomStringConvertible {
        case Account
        case Subscription
        
        static func isSubscription(recordType: CKRecord.RecordType) -> Bool {
            return recordType == Subscription.stringValue
        }
    }
    
    enum ZoneName: CodingKey, CustomStringConvertible {
        case Windmill
    }


    static let shared: CloudKitManager = CloudKitManager()
    
    let container = CKContainer(identifier: "iCloud.io.windmill.windmill.macos")
    lazy var database = container.privateCloudDatabase

    //MARK: private
    private func fetch(zoneId: CKRecordZone.ID = CKRecordZone.ID(zoneName: ZoneName.Windmill.stringValue, ownerName: CKCurrentUserDefaultName), recordName: String, completion: @escaping FetchRecordCompletion) {
        
        self.database.fetch(withRecordID: CKRecord.ID(recordName: recordName, zoneID: zoneId), completionHandler: { record, error in
            switch (record, error) {
            case (_, let error?):
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            case (let record?, _):
                DispatchQueue.main.async {
                    completion(record, nil)
                }
            case (.none, .none):
                preconditionFailure("Must have either record returned or an error")
            }
        })
    }
    
    private func registerForSubscriptionNotifications(zoneId: CKRecordZone.ID = CKRecordZone.ID(zoneName: ZoneName.Windmill.stringValue, ownerName: CKCurrentUserDefaultName), desiredKeys: [CKRecord.FieldKey]? = [CKRecord.FieldKey("account"), CKRecord.FieldKey("claim")], completionHandler: @escaping (CKSubscription?, Error?) -> Void) {
        
        let predicate = NSPredicate(value: true)
        let querySubscription =
            CKQuerySubscription(recordType: RecordType.Subscription.stringValue, predicate: predicate, options: [.firesOnRecordCreation, .firesOnRecordUpdate])
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.desiredKeys = desiredKeys
        querySubscription.notificationInfo = notificationInfo
        querySubscription.zoneID = zoneId
        
        let recordZone = CKRecordZone(zoneName: zoneId.zoneName)
        let modifyRecordZonesOperation = CKModifyRecordZonesOperation(recordZonesToSave: [recordZone])
        let modifySubscriptionsOperation = CKModifySubscriptionsOperation(subscriptionsToSave: [querySubscription])

        modifySubscriptionsOperation.modifySubscriptionsCompletionBlock = { subscriptions, subscriptionID, error in
            
            switch(subscriptions, error) {
            case(_, let error?):
                os_log("Error while creating query subscription in zone: '%{public}@'", log: .default, type: .debug, error.localizedDescription)
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            case (let subscriptions?, _):
                DispatchQueue.main.async {
                    completionHandler(subscriptions.first, nil)
                }
            case (.none, .none):
                preconditionFailure("Must have either subscriptions returned or an error")
            }
        }
        
        modifySubscriptionsOperation.addDependency(modifyRecordZonesOperation)
        self.database.add(modifyRecordZonesOperation)
        self.database.add(modifySubscriptionsOperation)
    }
    
    //MARK: module
    func subscriptionNotification(userInfo: [String : Any], completion: @escaping SubscriptionClaimCompletion) {
        
        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)
        
        guard notification?.notificationType == .query, let queryNotification = notification as? CKQueryNotification else {
            preconditionFailure("Can only handle query notifications. If you have since created a new notification, you must update this code.")
        }// check on the subscriptionID to confirm the notification fired rather than assume its the subscription one.
        
        let recordFields = queryNotification.recordFields
        
        guard let recordName = recordFields?["account"] as? String, let claim = recordFields?["claim"] as? String else {
            os_log("error reading values from recordfields '%{public}@'", log: .default, type: .error, recordFields ?? "empty")
            return
        }
        
        self.fetch(recordName: recordName) { (record, error) in
            
            switch error {
            case .some(let error):
                os_log("Error while processing subscription notification: '%{public}@'", log: .default, type: .error, error.localizedDescription)
                completion(nil, nil, error)
            case .none:
                guard let account = record, let identifier = account["identifier"] as? String else {
                    return
                }

                Keychain.default.write(value: claim, key: .subscriptionClaim)
                Keychain.default.write(value: identifier, key: .account)

                completion(Account(identifier: identifier), SubscriptionClaim(value: claim), nil)
            }
        }
    }
    
    func registerForSubscriptionNotifications(completion: @escaping (Result<CKSubscription, Error>) -> Swift.Void) {
        
        self.registerForSubscriptionNotifications { (subscription, error) in
            
            switch (subscription, error) {
            case (_, let error?):
                os_log("error while registering for subscription notifications: '%{public}@'", log: .default, type: .error, error.localizedDescription)
                completion(.failure(error))
            case (let subscription?, _):
                os_log("subscription: '%{public}@'", log: .default, type: .debug, subscription)
                completion(.success(subscription))
            default:
                return
            }
        }
    }
    
    public func fetchSubscription(completion: @escaping (Result<Void, Error>) -> Swift.Void) {
        
        let fetchRecordZoneChangesOperation = CKFetchRecordZoneChangesOperation()
        fetchRecordZoneChangesOperation.recordZoneIDs = [CKRecordZone.ID(zoneName: ZoneName.Windmill.stringValue, ownerName: CKCurrentUserDefaultName)]
        
        fetchRecordZoneChangesOperation.recordChangedBlock = { record in
            
            switch record.recordType {
            case RecordType.Account.stringValue:
                if let identifier = record["identifier"] as? String {
                    Keychain.default.write(value: identifier, key: .account)
                }
            case RecordType.Subscription.stringValue:
                if let claim = record["claim"] as? String {
                    Keychain.default.write(value: claim, key: .subscriptionClaim)
                }
            default:
               return
            }
        }
        
        fetchRecordZoneChangesOperation.recordZoneFetchCompletionBlock = { (zoneId, serverChangeToken, _, _, error) in
            
            switch error {
            case let error as CKError where error.isRetryServerError():
                os_log("Error while fetching subscription information: '%{public}@'; Will retry.", log: .default, type: .debug, error.localizedDescription)
            case let error as CKError where error.isFatalServerError():
                os_log("Fatal while fetching subscription information: '%{public}@'.", log: .default, type: .error, error.localizedDescription)
            default:
                break
            }

            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
        
        self.database.add(fetchRecordZoneChangesOperation)
        
    }

}

