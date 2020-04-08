//
//  ResourcePutExport.swift
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
