//
//  SubscriptionResource.swift
//  windmill
//
//  Created by Markos Charatzas on 06/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation
import os
import Alamofire
import CloudKit

class SubscriptionResource {
    
    typealias SubscriptionCompletion = (_ token: SubscriptionAuthorizationToken?, _ error: Error?) -> Void
    public static let SubscriptionCompletionIgnore: SubscriptionCompletion = { token, error in
        
    }
    

    let queue = DispatchQueue(label: "io.windmill.manager")
    
    let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        
        return URLSession(configuration: configuration)
    }()
    
    let sessionManager = SessionManager()
    
    @discardableResult func requestIsSubscriber(forAccount account: Account, claim: SubscriptionClaim, completion: @escaping SubscriptionCompletion = SubscriptionCompletionIgnore) -> DataRequest {
        
        var urlRequest = try! URLRequest(url: "\(WINDMILL_BASE_URL)/subscription/\(account.identifier)", method: .post)
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(claim.value)", forHTTPHeaderField: "Authorization")
        urlRequest.timeoutInterval = 10 //seconds
        
        return sessionManager.request(urlRequest).validate().responseData(queue: self.queue) { response in
            
            switch (response.result, response.result.value) {
            case (.failure(let error), _):
                switch error {
                case let error as AFError where error.isResponseValidationError:
                    switch (error.responseCode, response.data) {
                    case (401, let data?):
                        if let response = String(data: data, encoding: .utf8), let reason = SubscriptionError.UnauthorisationReason(rawValue: response) {
                            DispatchQueue.main.async{
                                completion(nil, SubscriptionError.unauthorised(reason:reason))
                            }
                        } else {
                            DispatchQueue.main.async{
                                completion(nil, SubscriptionError.unauthorised(reason: nil))
                            }
                        }
                    default:
                        DispatchQueue.main.async{
                            completion(nil, error)
                        }
                    }
                default:
                    DispatchQueue.main.async{
                        completion(nil, error)
                    }
                }
            case (.success, let data?):
                let decoder = JSONDecoder()
                
                do {
                    let subscriptionAuthorizationToken = try decoder.decode(SubscriptionAuthorizationToken.self, from: data)
                    
                    DispatchQueue.main.async{
                        completion(subscriptionAuthorizationToken, nil)
                    }
                } catch {
                    DispatchQueue.main.async{
                        completion(nil, error)
                    }
                }
                
                return
            default:
                DispatchQueue.main.async{
                    completion(nil, response.error)
                }
            }
        }
    }
}
