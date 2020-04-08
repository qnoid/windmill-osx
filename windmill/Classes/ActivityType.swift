//
//  ActivityType.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 01/08/2017.
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

public enum ActivityType: String, Codable, CustomStringConvertible
{
    case checkout
    case build
    case test
    case archive
    case export
    case distribute
    
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
        case .distribute:
            return "windmill-activity-indicator-distribute"
        case .showBuildSettings, .devices, .readProjectConfiguration:
            return "windmill-activity-indicator"
        }
    }
    
    public var description: String {
        return NSLocalizedString("windmill.activity.\(self.rawValue).description", comment: "")
    }    
}
