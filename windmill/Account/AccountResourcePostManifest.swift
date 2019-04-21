//
//  ResourcePostManifest.swift
//  windmill
//
//  Created by Markos Charatzas on 20/04/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation
import Alamofire

class AccountResourcePostManifest: NSObject {
    
    let queue: DispatchQueue
    
    init(queue: DispatchQueue) {
        self.queue = queue
    }
    
    func make(next: Resource? = nil, request upload: UploadRequest, completion: @escaping AccountResource.ExportCompletion, failureCase: @escaping AccountResource.FailureCase) -> Resource {
        return { context in
            upload.validate().responseData(queue: self.queue) { response in
                switch (response.result) {
                case .failure(let error):
                    failureCase(error, response)
                case .success:
                    switch (response.response?.statusCode, response.response?.allHeaderFields) {
                    case (204, let allHeaderFields?):
                        guard let location = allHeaderFields["Content-Location"] as? String, let url = URL(string: location) else {
                            return
                        }
                        
                        guard let export_identifier = allHeaderFields["x-content-identifier"] else {
                            return
                        }
                        
                        next?(["export_identifier":export_identifier, "Content-Location":url])
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func success(request upload: UploadRequest, completion: @escaping AccountResource.ExportCompletion, failureCase: @escaping AccountResource.FailureCase) -> ResourceSuccess {
        return { next in
            return self.make(next: next, request: upload, completion: completion, failureCase: failureCase)
        }
    }    
}
