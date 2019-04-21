//
//  Resource.swift
//  windmill
//
//  Created by Markos Charatzas on 20/04/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

let WINDMILL_BASE_URL_PRODUCTION = "https://api.windmill.io"
let WINDMILL_BASE_URL_DEVELOPMENT = "http://192.168.1.2:8080"

#if DEBUG
let WINDMILL_BASE_URL = WINDMILL_BASE_URL_DEVELOPMENT
#else
let WINDMILL_BASE_URL = WINDMILL_BASE_URL_PRODUCTION
#endif

typealias ResourceContext = [AnyHashable : Any]
typealias ResourceSuccess = (_ next: Resource?) -> Resource
typealias Resource = (_ context: ResourceContext) -> Swift.Void
