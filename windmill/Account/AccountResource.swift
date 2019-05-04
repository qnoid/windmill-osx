//
//  AccountResource.swift
//  windmill
//
//  Created by Markos Charatzas on 06/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

import Foundation
import os
import Alamofire

class AccountResource {
    
    typealias ExportCompletion = (_ itms: String?, _ error: Error?) -> Void
    typealias FailureCase = (_ error: Error, _ response: Alamofire.DataResponse<Data>) -> Swift.Void

    let queue = DispatchQueue(label: "io.windmill.windmill.manager")
    
    let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        
        return URLSession(configuration: configuration)
    }()
    
    let sessionManager = SessionManager()
    
    func failureCase(completion: @escaping AccountResource.ExportCompletion) -> FailureCase {
        return { error, response in
            switch error {
            case let error as AFError where error.isResponseSerializationError:
                DispatchQueue.main.async{
                    completion(nil, error.underlyingError)
                }
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
        }
    }

    func requestExport(export: Export, metadata: Export.Metadata, forAccount account: Account, authorizationToken: SubscriptionAuthorizationToken, completion: @escaping ExportCompletion) {
        
        var urlRequest = try! URLRequest(url: "\(WINDMILL_BASE_URL)/account/\(account.identifier)/export", method: .post)
        urlRequest.addValue("Bearer \(authorizationToken.value)", forHTTPHeaderField: "Authorization")
        urlRequest.timeoutInterval = 10 //seconds
        
        return sessionManager.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(export.manifest.url, withName: "plist")
        }, with: urlRequest, queue: self.queue, encodingCompletion: { result in
            switch result {
            case .success(let upload, _, _):                
                let postManifest =
                    AccountResourcePostManifest(queue: self.queue).success(request: upload, completion: completion, failureCase: self.failureCase(completion: completion))
                let putExport =
                    AccountResourcePutExport(sessionManager: self.sessionManager).success(export: export, completion: completion)
                let patchExport =
                    AccountResourcePatchExport(sessionManager: self.sessionManager)
                        .make(account: account, metadata: metadata, authorizationToken: authorizationToken, completion: completion, failureCase: self.failureCase(completion: completion))

                let uploadExport = postManifest(putExport(patchExport))
                
                uploadExport([:])
            case .failure(let error):
                DispatchQueue.main.async{
                    completion(nil, error)
                }
            }
        })
    }
}
