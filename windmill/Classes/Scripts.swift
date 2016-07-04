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
        
        static let BUILD : BashScript = "scripts/xcodebuild/build"
        static let TEST : BashScript = "scripts/xcodebuild/test"
        static let ARCHIVE : BashScript = "scripts/xcodebuild/archive"
        static let EXPORT : BashScript = "scripts/xcodebuild/export"
        static let DEPLOY : BashScript = "scripts/xcodebuild/deploy"
    }

    struct Git {
        static let CHECKOUT : BashScript = "scripts/git/checkout"
        static let POLL : BashScript = "scripts/git/poll"
    }
}
