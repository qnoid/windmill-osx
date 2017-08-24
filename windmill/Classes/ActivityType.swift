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
    case deploy
    case poll
    
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
        case .deploy:
            return "windmill-activity-indicator-deploy"
        case .poll:
            return "windmill-activity-indicator"
        }
    }
    
    var imageNameLights: String {
        switch (self){
        case .checkout:
            return "lights-checkout"
        case .build:
            return "lights-build"
        case .test:
            return "lights-test"
        case .archive:
            return "lights-archive"
        case .export:
            return "lights-export"
        case .deploy:
            return "lights-deploy"
        case .poll:
            return ""
        }
    }
    
    public var description: String {
        switch (self){
        case .checkout:
            return "checking out"
        case .build:
            return "building"
        case .test:
            return "testing"
        case .archive:
            return "archiving"
        case .export:
            return "exporting"
        case .deploy:
            return "deploying"
        case .poll:
            return "monitoring"
        }
    }    
}
