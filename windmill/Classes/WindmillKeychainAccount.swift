//
//  Foo.swift
//  windmill
//
//  Created by Markos Charatzas on 07/09/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import Foundation

struct WindmillKeychainAccount
{
    let users = KeychainAccount(serviceName: "io.windmill", name: "io.windmill.users")
}