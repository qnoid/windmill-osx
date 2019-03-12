//
//  SubscriptionAuthorizationToken.swift
//  windmill
//
//  Created by Markos Charatzas on 06/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

struct SubscriptionAuthorizationToken: Codable {
    
    enum CodingKeys: String, CodingKey {
        case value = "access_token"
    }
    
    let value: String
}
