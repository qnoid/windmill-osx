//
//  Account.swift
//  windmill
//
//  Created by Markos Charatzas on 06/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

public struct Account: Codable {
    
    enum CodingKeys: String, CodingKey {
        case identifier = "account_identifier"
    }
    
    let identifier: String
}
