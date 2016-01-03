//
//  PathComponent.swift
//  windmill
//
//  Created by Markos Charatzas on 13/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation

public struct PathComponent : RawRepresentable
{
    public typealias RawValue = String
    
    public let rawValue: String
    
    public init?(rawValue: String)
    {
        self.rawValue = rawValue
    }
    
    static var MobileDeviceProvisioningProfiles: PathComponent {
        return PathComponent(rawValue: "/MobileDevice/Provisioning Profiles")!
    }
}