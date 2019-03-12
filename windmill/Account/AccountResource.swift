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

let WINDMILL_BASE_URL_PRODUCTION = "https://api.windmill.io"
let WINDMILL_BASE_URL_DEVELOPMENT = "http://192.168.1.2:8080"

#if DEBUG
let WINDMILL_BASE_URL = WINDMILL_BASE_URL_DEVELOPMENT
#else
let WINDMILL_BASE_URL = WINDMILL_BASE_URL_PRODUCTION
#endif

class AccountResource {
    
    typealias ExportCompletion = (_ itms: String?, _ error: Error?) -> Void
    
    let queue = DispatchQueue(label: "io.windmill.manager")
    
    let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        
        return URLSession(configuration: configuration)
    }()
    
    let sessionManager = SessionManager()
    
    func requestExport(export: Export, forAccount account: String, authorizationToken: SubscriptionAuthorizationToken, completion: @escaping ExportCompletion) {
        
        var urlRequest = try! URLRequest(url: "\(WINDMILL_BASE_URL)/account/\(account)/export", method: .post)
        urlRequest.addValue("Bearer \(authorizationToken.value)", forHTTPHeaderField: "Authorization")
        urlRequest.timeoutInterval = 10 * 60 //seconds
        
        return sessionManager.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(export.url, withName: "ipa")
            multipartFormData.append(export.manifest.url, withName: "plist")
        }, with: urlRequest, queue: self.queue, encodingCompletion: { result in
            
            switch result {
            case .success(let upload, _, _):
                upload.validate().responseData(queue: self.queue) { response in
                    switch (response.result, response.result.value) {
                    case (.failure(let error), _):
                        switch error {
                        case let error as AFError where error.isResponseSerializationError:
                            DispatchQueue.main.async{
                                completion(nil, nil)
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
                    case (.success, let data?):
                        let itms = String(data: data, encoding: .utf8) ?? ""
                        os_log("See other", log: .default, type: .debug, itms)
                        DispatchQueue.main.async{
                            completion(itms, nil)
                        }
                    default:
                        DispatchQueue.main.async{
                            completion(nil, response.error)
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async{
                    completion(nil, error)
                }
            }
        })
    }
}
