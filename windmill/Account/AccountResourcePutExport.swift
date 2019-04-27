//
//  ResourcePutExport.swift
//  windmill
//
//  Created by Markos Charatzas on 20/04/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation
import Alamofire

class AccountResourcePutExport: NSObject {
    
    weak var sessionManager: SessionManager?
    
    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }
    
    func make(next: Resource? = nil, export: Export, completion: @escaping AccountResource.ExportCompletion) -> Resource {
        return { context in
            
            guard let location = context["Content-Location"] as? URL else {
                preconditionFailure("ResourcePutExport expects a `URL` under the context[\"Content-Location\"] for a succesful callback")
            }
            
            guard let export_identifier = context["export_identifier"] as? String else {
                preconditionFailure("ResourcePutExport expects a `String` under the context[\"export_identifier\"] for a succesful callback")
            }
            
            let upload = try! Data(contentsOf: export.url)
            
            let sha256 = SHA256().hash(data: upload)
            let headers: HTTPHeaders = [
                "Content-Type": "application/octet-stream ipa",
                "x-amz-content-sha256": "\(sha256.map { String(format: "%02x", $0) }.joined())"
            ]
            
            self.sessionManager?.upload(upload, to: location, method: .put, headers: headers).validate().responseData{ response in
                switch response.result {
                case .failure(let error):
                    DispatchQueue.main.async{
                        completion(nil, error)
                    }
                case .success:
                    next?(["export_identifier":export_identifier])
                }
            }
        }
    }
    
    func success(export: Export, completion: @escaping AccountResource.ExportCompletion) -> ResourceSuccess {
        return { next in
            return self.make(next: next, export: export, completion: completion)
        }
    }
}
