//
//  ResourcePatchExport.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 20/04/2019.
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
