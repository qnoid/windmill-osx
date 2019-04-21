//
//  CryptographicHashFunction.swift
//  windmill
//
//  Created by Markos Charatzas on 19/04/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

protocol CryptographicHashFunction {

    func hash(base64EncodedString value: String) throws -> String?
    
    func hash(data: Data) -> Data
}
