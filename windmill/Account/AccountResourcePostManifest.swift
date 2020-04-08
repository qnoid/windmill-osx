//
//  ResourcePostManifest.swift
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
