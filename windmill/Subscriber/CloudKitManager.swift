//
//  CloudKitManager.swift
//  windmill
//
//  Created by Markos Charatzas on 13/05/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
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

