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
        static let BUILD_PROJECT : BashScript = "scripts/xcodebuild/development/build_project"
        static let BUILD_WORKSPACE : BashScript = "scripts/xcodebuild/development/build_workspace"
    }
}

struct Git
{
    struct Development
    {
        static let CHECKOUT : BashScript = "scripts/xcodebuild/development/checkout"
    }
}
