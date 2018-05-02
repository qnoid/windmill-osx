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
        
        static let LIST_CONFIGURATION : BashScript = "Scripts/xcodebuild/list_configuration"
        static let SHOW_BUILD_SETTINGS : BashScript = "Scripts/xcodebuild/showBuildSettings"
        static let SHOW_PROJECT_BUILD_SETTINGS : BashScript = "Scripts/xcodebuild/showBuildSettings-project"
        static let SHOW_WORKSPACE_BUILD_SETTINGS : BashScript = "Scripts/xcodebuild/showBuildSettings-workspace"
        static let BUILD : BashScript = "Scripts/xcodebuild/build"
        static let BUILD_PROJECT : BashScript = "Scripts/xcodebuild/build-project"
        static let BUILD_WORKSPACE : BashScript = "Scripts/xcodebuild/build-workspace"
        static let BUILD_FOR_TESTING : BashScript = "Scripts/xcodebuild/build-for-testing"
        static let BUILD_PROJECT_FOR_TESTING : BashScript = "Scripts/xcodebuild/build-project-for-testing"
        static let BUILD_WORKSPACE_FOR_TESTING : BashScript = "Scripts/xcodebuild/build-workspace-for-testing"
        static let TEST_SKIP : BashScript = "Scripts/xcodebuild/test-skip"
        static let TEST_WITHOUT_BUILDING : BashScript = "Scripts/xcodebuild/test-without-building"
        static let TEST_PROJECT_WITHOUT_BUILDING : BashScript = "Scripts/xcodebuild/test-project-without-building"
        static let TEST_WORKSPACE_WITHOUT_BUILDING : BashScript = "Scripts/xcodebuild/test-workspace-without-building"
        static let ARCHIVE : BashScript = "Scripts/xcodebuild/archive"
        static let ARCHIVE_PROJECT : BashScript = "Scripts/xcodebuild/archive-project"
        static let ARCHIVE_WORKSPACE : BashScript = "Scripts/xcodebuild/archive-workspace"
        static let EXPORT : BashScript = "Scripts/xcodebuild/export"
        static let DEPLOY : BashScript = "Scripts/xcodebuild/deploy"
    }

    struct Git {
        static let CHECKOUT : BashScript = "Scripts/git/checkout"
        static let CHECKOUT_DONT_RESET_HARD : BashScript = "Scripts/git/checkout_dont_reset_hard"
        static let POLL : BashScript = "Scripts/git/poll"
        static let POLL_DONT_RESET_HARD : BashScript = "Scripts/git/poll_dont_reset_hard"
    }
    
    struct CommandLineTools {
        static let FIND_PROJECT_DIRECTORY : BashScript = "Scripts/commandlinetools/find_project_directory"
    }
    
    struct Simctl {
        static let LIST_DEVICES : BashScript = "Scripts/simctl/list_devices"
        static let BOOT : BashScript = "Scripts/simctl/boot"
        static let INSTALL : BashScript = "Scripts/simctl/install"
        static let LAUNCH : BashScript = "Scripts/simctl/launch"
        static let RECORD_VIDEO : BashScript = "Scripts/simctl/recordVideo"
    }
}
