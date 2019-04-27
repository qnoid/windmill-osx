//
//  ResourcePatchExport.swift
//  windmill
//
//  Created by Markos Charatzas on 20/04/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation
import Alamofire

class AccountResourcePatchExport: NSObject {
    
    weak var sessionManager: SessionManager?

    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }
    
    func make(next: Resource? = nil, account: Account, metadata: Export.Metadata, authorizationToken: SubscriptionAuthorizationToken, completion: @escaping AccountResource.ExportCompletion, failureCase: @escaping AccountResource.FailureCase) -> Resource {
        return { context in
            
            guard let export_identifier = context["export_identifier"] as? String else {
                preconditionFailure("ResourcePatchExport expects a `String` under the context[\"export_identifier\"] for a succesful callback")
            }
            
            var urlRequest = try! URLRequest(url: "\(WINDMILL_BASE_URL)/account/\(account.identifier)/export/\(export_identifier)", method: .patch)
            urlRequest.addValue("Bearer \(authorizationToken.value)", forHTTPHeaderField: "Authorization")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let encoder = JSONEncoder()
            
            encoder.dateEncodingStrategy = .secondsSince1970

            urlRequest.httpBody = try? encoder.encode(metadata)
            urlRequest.timeoutInterval = 10 //seconds
            
            self.sessionManager?.request(urlRequest).validate().responseData{ response in
                switch (response.result, response.result.value) {
                case (.failure(let error), _):
                    failureCase(error, response)
                case (.success, let data?):
                    let json = String(data: data, encoding: .utf8)
                    DispatchQueue.main.async{
                        completion(json, nil)
                    }
                default:
                    break
                }
            }
        }
    }
}
