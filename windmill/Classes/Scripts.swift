//
//  Scripts.swift
//  windmill
//
//  Created by Markos Charatzas on 18/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation

typealias BashScript = String

struct Scripts
{
    struct Xcodebuild {
        
        static let BUILD : BashScript = "Scripts/xcodebuild/build"
        static let TEST : BashScript = "Scripts/xcodebuild/test"
        static let ARCHIVE : BashScript = "Scripts/xcodebuild/archive"
        static let EXPORT : BashScript = "Scripts/xcodebuild/export"
        static let DEPLOY : BashScript = "Scripts/xcodebuild/deploy"
    }

    struct Git {
        static let CHECKOUT : BashScript = "Scripts/git/checkout"
        static let POLL : BashScript = "Scripts/git/poll"
    }
    
    struct CommandLineTools {
        static let READ_BUILD_SETTINGS : BashScript = "Scripts/commandlinetools/read_build_settings"
        static let READ_DEVICES : BashScript = "Scripts/commandlinetools/read_devices"
    }
}
