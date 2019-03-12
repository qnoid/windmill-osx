//
//  ActivityType.swift
//  windmill
//
//  Created by Markos Charatzas on 01/08/2017.
//  Copyright © 2017 qnoid.com. All rights reserved.
//

import Foundation

public enum ActivityType: String, CustomStringConvertible
{
    case checkout
    case build
    case test
    case archive
    case export
    case publish
    
    case showBuildSettings
    case devices
    case readProjectConfiguration
    
    var imageName: String {
        switch (self){
        case .checkout:
            return "windmill-activity-indicator-checkout"
        case .build:
            return "windmill-activity-indicator-build"
        case .test:
            return "windmill-activity-indicator-test"
        case .archive:
            return "windmill-activity-indicator-archive"
        case .export:
            return "windmill-activity-indicator-export"
        case .publish:
            return "windmill-activity-indicator-publish"
        case .showBuildSettings, .devices, .readProjectConfiguration:
            return "windmill-activity-indicator"
        }
    }
    
    public var description: String {
        return NSLocalizedString("windmill.activity.\(self.rawValue).description", comment: "")
    }    
}
