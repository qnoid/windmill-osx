//
//  PathComponent.swift
//  windmill
//
//  Created by Markos Charatzas on 13/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation

struct PathComponent : RawRepresentable
{
    typealias RawValue = String
    
    let rawValue: String
    
    init?(rawValue: String)
    {
        self.rawValue = rawValue
    }
    
    static var MobileDeviceProvisioningProfiles: PathComponent {
        return PathComponent(rawValue: "/MobileDevice/Provisioning Profiles")!
    }
}