//
//  Xcodebuild.swift
//  windmill
//
//  Created by Markos Charatzas on 18/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation

typealias BashScript = String

struct Xcodebuild
{
    struct Development
    {
        static let BUILD : BashScript = "scripts/xcodebuild/development/build"
        static let TEST : BashScript = "scripts/xcodebuild/development/test"
        static let PACKAGE : BashScript = "scripts/xcodebuild/development/package"
        static let DEPLOY : BashScript = "scripts/xcodebuild/development/deploy"
    }
}

struct Git
{
    struct Development
    {
        static let CHECKOUT : BashScript = "scripts/xcodebuild/development/checkout"
    }
}
