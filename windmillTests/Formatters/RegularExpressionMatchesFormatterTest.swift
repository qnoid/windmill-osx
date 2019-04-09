//
//  RegularExpressionMatchesFormatterTest.swift
//  windmillTests
//
//  Created by Markos Charatzas on 10/4/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import XCTest

@testable import Windmill

class RegularExpressionMatchesFormatterTest: XCTestCase {
    
    let attachmentCharacter = UnicodeScalar(NSAttachmentCharacter)!
    lazy var padding = CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: attachmentCharacter...attachmentCharacter))
    
    func testBuildTarget() {
        let output = "=== BUILD TARGET helloworld OF PROJECT helloworld WITH CONFIGURATION Debug ==="
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeBuildTarget(descender: 0.0)
        
        XCTAssertEqual("Build target helloworld", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    func testCodeSigning() {
        let output = """
        CodeSign /Users/qnoid/.Trash/DerivedData/helloworld/Build/Products/Debug-iphonesimulator/helloworld.app
        cd /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-fezcvdrmroaraabfbnktjikmxgvk/Build/Products/Debug/Windmill.app/Contents/PlugIns/windmillTests.xctest/Contents/Resources/helloworld
        export CODESIGN_ALLOCATE=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/codesign_allocate
        export PATH=\"/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin\"
        
        Signing Identity:     \"-\"

        /usr/bin/codesign --force --sign - --entitlements /Users/qnoid/.Trash/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/helloworld.app.xcent --timestamp=none /Users/qnoid/.Trash/DerivedData/helloworld/Build/Products/Debug-iphonesimulator/helloworld.app
        """
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCodeSign(descender: 0.0)
        
        XCTAssertEqual("Sign helloworld.app ...in /Users/qnoid/.Trash/DerivedData/helloworld/Build/Products/Debug-iphonesimulator/helloworld.app", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    func testCompileSwiftSources() {
        let output = """
        CompileSwiftSources normal x86_64 com.apple.xcode.tools.swift.compiler
        cd /Users/qnoid/Developer/workspace/swift/windmill-osx/windmillTests/Resources/projects/helloworld
        export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
        export PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/local/opt/postgresql@9.4/bin:/Users/qnoid/.rbenv/shims:/Users/qnoid/.rbenv/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        export SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator11.3.sdk
        /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc -incremental -module-name helloworld -Onone -enforce-exclusivity=checked -DDEBUG -sdk /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator11.3.sdk -target x86_64-apple-ios10.2 -g -module-cache-path /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/ModuleCache.noindex -Xfrontend -serialize-debugging-options -enable-testing -index-store-path /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Index/DataStore -swift-version 4 -I /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Products/Debug-iphonesimulator -F /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Products/Debug-iphonesimulator -c -j8 /Users/qnoid/Developer/workspace/swift/windmill-osx/windmillTests/Resources/projects/helloworld/helloworld/ViewController.swift /Users/qnoid/Developer/workspace/swift/windmill-osx/windmillTests/Resources/projects/helloworld/helloworld/AppDelegate.swift -output-file-map /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld-OutputFileMap.json -parseable-output -serialize-diagnostics -emit-dependencies -emit-module -emit-module-path /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld.swiftmodule -Xcc -I/Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/swift-overrides.hmap -Xcc -iquote -Xcc /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/helloworld-generated-files.hmap -Xcc -I/Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/helloworld-own-target-headers.hmap -Xcc -I/Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/helloworld-all-target-headers.hmap -Xcc -iquote -Xcc /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/helloworld-project-headers.hmap -Xcc -I/Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Products/Debug-iphonesimulator/include -Xcc -I/Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/DerivedSources/x86_64 -Xcc -I/Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/DerivedSources -Xcc -DDEBUG=1 -emit-objc-header -emit-objc-header-path /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld-Swift.h -Xcc -working-directory/Users/qnoid/Developer/workspace/swift/windmill-osx/windmillTests/Resources/projects/helloworld
        """
        
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCompileSwiftSources(descender: 0.0)
        
        XCTAssertEqual("Compile Swift source files", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    func testCompileSwift() {
        
        let output = """
        CompileSwift normal x86_64 /Users/qnoid/Developer/workspace/swift/windmill-osx/windmillTests/Resources/projects/helloworld/helloworld/ViewController.swift
        cd /Users/qnoid/Developer/workspace/swift/windmill-osx/windmillTests/Resources/projects/helloworld
        /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift -frontend -c -primary-file /Users/qnoid/Developer/workspace/swift/windmill-osx/windmillTests/Resources/projects/helloworld/helloworld/ViewController.swift /Users/qnoid/Developer/workspace/swift/windmill-osx/windmillTests/Resources/projects/helloworld/helloworld/AppDelegate.swift -target x86_64-apple-ios10.2 -enable-objc-interop -sdk /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator11.3.sdk -I /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Products/Debug-iphonesimulator -F /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Products/Debug-iphonesimulator -enable-testing -g -module-cache-path /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/ModuleCache.noindex -swift-version 4 -enforce-exclusivity=checked -Onone -D DEBUG -serialize-debugging-options -Xcc -I/Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/swift-overrides.hmap -Xcc -iquote -Xcc /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/helloworld-generated-files.hmap -Xcc -I/Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/helloworld-own-target-headers.hmap -Xcc -I/Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/helloworld-all-target-headers.hmap -Xcc -iquote -Xcc /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/helloworld-project-headers.hmap -Xcc -I/Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Products/Debug-iphonesimulator/include -Xcc -I/Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/DerivedSources/x86_64 -Xcc -I/Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/DerivedSources -Xcc -DDEBUG=1 -Xcc -working-directory/Users/qnoid/Developer/workspace/swift/windmill-osx/windmillTests/Resources/projects/helloworld -emit-module-doc-path /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/ViewController~partial.swiftdoc -serialize-diagnostics-path /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/ViewController.dia -module-name helloworld -emit-module-path /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/ViewController~partial.swiftmodule -emit-dependencies-path /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/ViewController.d -emit-reference-dependencies-path /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/ViewController.swiftdeps -o /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/ViewController.o -index-store-path /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/helloworld/Index/DataStore -index-system-modules
        """
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCompile(descender: 0.0)
        
        XCTAssertEqual("Compile ViewController.swift ...in /Users/qnoid/Developer/workspace/swift/windmill-osx/windmillTests/Resources/projects/helloworld/helloworld/ViewController.swift", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    func testCompileStoryboard() {
        let output = """
        CompileStoryboard helloworld/Base.lproj/Main.storyboard
        cd /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-fezcvdrmroaraabfbnktjikmxgvk/Build/Products/Debug/Windmill.app/Contents/PlugIns/windmillTests.xctest/Contents/Resources/helloworld
        export PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        export XCODE_DEVELOPER_USR_PATH=/Applications/Xcode.app/Contents/Developer/usr/bin/..
        /Applications/Xcode.app/Contents/Developer/usr/bin/ibtool --errors --warnings --notices --module helloworld --output-partial-info-plist /Users/qnoid/.Trash/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Main-SBPartialInfo.plist --auto-activate-custom-fonts --target-device iphone --target-device ipad --minimum-deployment-target 10.2 --output-format human-readable-text --compilation-directory /Users/qnoid/.Trash/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Base.lproj /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-fezcvdrmroaraabfbnktjikmxgvk/Build/Products/Debug/Windmill.app/Contents/PlugIns/windmillTests.xctest/Contents/Resources/helloworld/helloworld/Base.lproj/Main.storyboard
        """
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCompileStoryboard(descender: 0.0)
        
        XCTAssertEqual("Compile Storyboard file Main.storyboard ...in helloworld/Base.lproj/Main.storyboard", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    func testGenerateDSYM() {
        let output = """
        GenerateDSYMFile /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/project-not-at-root/Build/Intermediates.noindex/ArchiveIntermediates/project-not-at-root/BuildProductsPath/Release-iphoneos/project-not-at-root.app.dSYM /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/project-not-at-root/Build/Intermediates.noindex/ArchiveIntermediates/project-not-at-root/InstallationBuildProductsLocation/Applications/project-not-at-root.app/project-not-at-root
        cd /Users/qnoid/Library/Caches/io.windmill.windmill/Sources/project-not-at-root/iOS
        export PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/dsymutil /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/project-not-at-root/Build/Intermediates.noindex/ArchiveIntermediates/project-not-at-root/InstallationBuildProductsLocation/Applications/project-not-at-root.app/project-not-at-root -o /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/project-not-at-root/Build/Intermediates.noindex/ArchiveIntermediates/project-not-at-root/BuildProductsPath/Release-iphoneos/project-not-at-root.app.dSYM
        """
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeGenerateDSYM(descender: 0.0)
        
        XCTAssertEqual("Generate project-not-at-root.app.dSYM", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    func testProcessInfoPlist() {
        let output = """
        ProcessInfoPlistFile /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Products/Release-iphonesimulator/windmill.app/Info.plist windmill/Info.plist
        cd /Users/qnoid/Developer/workspace/swift/windmill-ios
        export PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        builtin-infoPlistUtility /Users/qnoid/Developer/workspace/swift/windmill-ios/windmill/Info.plist -genpkginfo /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Products/Release-iphonesimulator/windmill.app/PkgInfo -expandbuildsettings -format binary -platform iphonesimulator -additionalcontentfile /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Intermediates.noindex/windmill.build/Release-iphonesimulator/windmill.build/NotificationsAuthorizedTableViewHeaderView-PartialInfo.plist -additionalcontentfile /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Intermediates.noindex/windmill.build/Release-iphonesimulator/windmill.build/InstallTableViewFooterView-PartialInfo.plist -additionalcontentfile /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Intermediates.noindex/windmill.build/Release-iphonesimulator/windmill.build/WindmillTableViewCell-PartialInfo.plist -additionalcontentfile /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Intermediates.noindex/windmill.build/Release-iphonesimulator/windmill.build/NotificationsNotDeterminedTableViewHeaderView-PartialInfo.plist -additionalcontentfile /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Intermediates.noindex/windmill.build/Release-iphonesimulator/windmill.build/NotificationsDeniedTableViewHeaderView-PartialInfo.plist -additionalcontentfile /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Intermediates.noindex/windmill.build/Release-iphonesimulator/windmill.build/LaunchScreen-SBPartialInfo.plist -additionalcontentfile /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Intermediates.noindex/windmill.build/Release-iphonesimulator/windmill.build/assetcatalog_generated_info.plist -additionalcontentfile /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Intermediates.noindex/windmill.build/Release-iphonesimulator/windmill.build/Main-SBPartialInfo.plist -o /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Products/Release-iphonesimulator/windmill.app/Info.plist
        """
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeProcessInfoPlist(descender: 0.0)
        
        XCTAssertEqual("Process Info.plist ...in windmill/Info.plist", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    func testLink() {
        let output: String = """
        Ld /Users/qnoid/.Trash/DerivedData/helloworld/Build/Products/Debug-iphonesimulator/helloworld.app/helloworld normal x86_64
        cd /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-fezcvdrmroaraabfbnktjikmxgvk/Build/Products/Debug/Windmill.app/Contents/PlugIns/windmillTests.xctest/Contents/Resources/helloworld
        export IPHONEOS_DEPLOYMENT_TARGET=10.2
        export PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -arch x86_64 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator11.3.sdk -L/Users/qnoid/.Trash/DerivedData/helloworld/Build/Products/Debug-iphonesimulator -F/Users/qnoid/.Trash/DerivedData/helloworld/Build/Products/Debug-iphonesimulator -filelist /Users/qnoid/.Trash/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld.LinkFileList -Xlinker -rpath -Xlinker @executable_path/Frameworks -mios-simulator-version-min=10.2 -dead_strip -Xlinker -object_path_lto -Xlinker /Users/qnoid/.Trash/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld_lto.o -Xlinker -export_dynamic -Xlinker -no_deduplicate -Xlinker -objc_abi_version -Xlinker 2 -fobjc-link-runtime -L/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/iphonesimulator -Xlinker -add_ast_path -Xlinker /Users/qnoid/.Trash/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld.swiftmodule -Xlinker -sectcreate -Xlinker __TEXT -Xlinker __entitlements -Xlinker /Users/qnoid/.Trash/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/helloworld.app-Simulated.xcent -Xlinker -dependency_info -Xlinker /Users/qnoid/.Trash/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld_dependency_info.dat -o /Users/qnoid/.Trash/DerivedData/helloworld/Build/Products/Debug-iphonesimulator/helloworld.app/helloworld
        """
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeLinking(descender: 0.0)
        
        XCTAssertEqual("Link helloworld ...in /DerivedData/helloworld/Build/Products/Debug-iphonesimulator/helloworld.app/helloworld", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    func testRelativeLinking() {
        let output: String = """
        Ld ../Build/Products/Debug-iphonesimulator/helloworld.app/helloworld normal x86_64
        cd /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-fezcvdrmroaraabfbnktjikmxgvk/Build/Products/Debug/Windmill.app/Contents/PlugIns/windmillTests.xctest/Contents/Resources/helloworld
        export IPHONEOS_DEPLOYMENT_TARGET=10.2
        export PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -arch x86_64 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator11.3.sdk -L/Users/qnoid/.Trash/DerivedData/helloworld/Build/Products/Debug-iphonesimulator -F/Users/qnoid/.Trash/DerivedData/helloworld/Build/Products/Debug-iphonesimulator -filelist /Users/qnoid/.Trash/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld.LinkFileList -Xlinker -rpath -Xlinker @executable_path/Frameworks -mios-simulator-version-min=10.2 -dead_strip -Xlinker -object_path_lto -Xlinker /Users/qnoid/.Trash/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld_lto.o -Xlinker -export_dynamic -Xlinker -no_deduplicate -Xlinker -objc_abi_version -Xlinker 2 -fobjc-link-runtime -L/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/iphonesimulator -Xlinker -add_ast_path -Xlinker /Users/qnoid/.Trash/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld.swiftmodule -Xlinker -sectcreate -Xlinker __TEXT -Xlinker __entitlements -Xlinker /Users/qnoid/.Trash/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/helloworld.app-Simulated.xcent -Xlinker -dependency_info -Xlinker /Users/qnoid/.Trash/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld_dependency_info.dat -o /Users/qnoid/.Trash/DerivedData/helloworld/Build/Products/Debug-iphonesimulator/helloworld.app/helloworld
        """
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeLinkRelative(descender: 0.0)
        
        XCTAssertEqual("Link helloworld ...in ../Build/Products/Debug-iphonesimulator/helloworld.app/helloworld", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    func testPhaseSuccess() {
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makePhaseSuccess(descender: 0.0)
        
        XCTAssertEqual("Build succeeded\n\tNo issues", formatter.format(for: "** BUILD SUCCEEDED **")?.string.trimmingCharacters(in: padding))
        XCTAssertEqual("Clean succeeded\n\tNo issues", formatter.format(for: "** CLEAN SUCCEEDED **")?.string.trimmingCharacters(in: padding))
        XCTAssertEqual("Test build succeeded\n\tNo issues", formatter.format(for: "** TEST BUILD SUCCEEDED **")?.string.trimmingCharacters(in: padding))
    }
    
    func testPhaseScriptExecution() {
        let output: String = "PhaseScriptExecution Run\\ Script /Users/qnoid/Library/Caches/io.windmill.windmill/DerivedData/windmill/Build/Intermediates.noindex/windmill.build/Debug-iphonesimulator/windmill.build/Script-BD4B00CF1F0E300D004025F3.sh"
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makePhaseScriptExecution(descender: 0.0)
        
        XCTAssertEqual("Run custom shell script \'Run\\ Script\'", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    func testWriteAuxiliaryfiles() {
        let output = "Write auxiliary files"
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeWriteAuxiliaryfiles(descender: 0.0)
        
        XCTAssertEqual("Write auxiliary files", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    func testHeaderCopyUsingDitto() {
        let output = """
        Ditto /Users/qnoid/.Trash/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/DerivedSources/helloworld-Swift.h /Users/qnoid/.Trash/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld-Swift.h
        cd /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-fezcvdrmroaraabfbnktjikmxgvk/Build/Products/Debug/Windmill.app/Contents/PlugIns/windmillTests.xctest/Contents/Resources/helloworld
        export PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        /usr/bin/ditto -rsrc /Users/qnoid/.Trash/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld-Swift.h /Users/qnoid/.Trash/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/DerivedSources/helloworld-Swift.h
        """
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCopyUsingDitto(descender: 0.0)
        
        XCTAssertEqual("Copy helloworld-Swift.h ...at /Users/qnoid/.Trash/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld-Swift.h", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    func testModuleCopyUsingDitto() {
        let output = """
        Ditto /Users/qnoid/.Trash/DerivedData/helloworld/Build/Products/Debug-iphonesimulator/helloworld.swiftmodule/x86_64.swiftmodule /Users/qnoid/.Trash/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld.swiftmodule
        cd /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-fezcvdrmroaraabfbnktjikmxgvk/Build/Products/Debug/Windmill.app/Contents/PlugIns/windmillTests.xctest/Contents/Resources/helloworld
        export PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        /usr/bin/ditto -rsrc /Users/qnoid/.Trash/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld.swiftmodule /Users/qnoid/.Trash/DerivedData/helloworld/Build/Products/Debug-iphonesimulator/helloworld.swiftmodule/x86_64.swiftmodule
        """
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCopyUsingDitto(descender: 0.0)
        
        XCTAssertEqual("Copy helloworld.swiftmodule ...at /Users/qnoid/.Trash/DerivedData/helloworld/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld.swiftmodule", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    func testDocCopyUsingDitto() {
        let output = """
        Ditto /Users/qnoid/Library/Developer/Xcode/DerivedData/helloworld-aapmrrhhegvcwgestrsyqfjctwdk/Build/Products/Debug-iphonesimulator/helloworld.swiftmodule/x86_64.swiftdoc /Users/qnoid/Library/Developer/Xcode/DerivedData/helloworld-aapmrrhhegvcwgestrsyqfjctwdk/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld.swiftdoc
        cd /Users/qnoid/Developer/workspace/swift/windmill-osx/windmillTests/Resources/projects/helloworld
        export PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        /usr/bin/ditto -rsrc /Users/qnoid/Library/Developer/Xcode/DerivedData/helloworld-aapmrrhhegvcwgestrsyqfjctwdk/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld.swiftdoc /Users/qnoid/Library/Developer/Xcode/DerivedData/helloworld-aapmrrhhegvcwgestrsyqfjctwdk/Build/Products/Debug-iphonesimulator/helloworld.swiftmodule/x86_64.swiftdoc
        """
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCopyUsingDitto(descender: 0.0)
        
        XCTAssertEqual("Copy helloworld.swiftdoc ...at /Users/qnoid/Library/Developer/Xcode/DerivedData/helloworld-aapmrrhhegvcwgestrsyqfjctwdk/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld.swiftdoc", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    func testModulemapCopyUsingDitto() {
        let output = """
        Ditto /Users/qnoid/Library/Developer/Xcode/DerivedData/Charts-bsfuaegntwehlaacthatbzsarmee/Build/Intermediates.noindex/ArchiveIntermediates/ChartsDemo-iOS-Swift/IntermediateBuildFilesPath/Charts.build/Release-iphoneos/Charts.build/module.modulemap /Users/qnoid/Library/Developer/Xcode/DerivedData/Charts-bsfuaegntwehlaacthatbzsarmee/Build/Intermediates.noindex/ArchiveIntermediates/ChartsDemo-iOS-Swift/IntermediateBuildFilesPath/UninstalledProducts/iphoneos/Charts.framework/Modules/module.modulemap
        cd /Users/qnoid/Library/Caches/io.windmill.windmill/Sources/Charts
        export PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        builtin-copy -exclude .DS_Store -exclude CVS -exclude .svn -exclude .git -exclude .hg -strip-debug-symbols -strip-tool /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip -resolve-src-symlinks /Users/qnoid/Library/Developer/Xcode/DerivedData/Charts-bsfuaegntwehlaacthatbzsarmee/Build/Intermediates.noindex/ArchiveIntermediates/ChartsDemo-iOS-Swift/IntermediateBuildFilesPath/Charts.build/Release-iphoneos/Charts.build/module.modulemap /Users/qnoid/Library/Developer/Xcode/DerivedData/Charts-bsfuaegntwehlaacthatbzsarmee/Build/Intermediates.noindex/ArchiveIntermediates/ChartsDemo-iOS-Swift/IntermediateBuildFilesPath/UninstalledProducts/iphoneos/Charts.framework/Modules
        """
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCopyUsingDitto(descender: 0.0)
        
        XCTAssertEqual("Copy module.modulemap ...at /Users/qnoid/Library/Developer/Xcode/DerivedData/Charts-bsfuaegntwehlaacthatbzsarmee/Build/Intermediates.noindex/ArchiveIntermediates/ChartsDemo-iOS-Swift/IntermediateBuildFilesPath/UninstalledProducts/iphoneos/Charts.framework/Modules/module.modulemap", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    func testCreateUniversalBinary() {
        let output = """
        CreateUniversalBinary /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Products/Release-iphonesimulator/windmill.app/windmill normal i386 x86_64
        cd /Users/qnoid/Developer/workspace/swift/windmill-ios
        export PATH=\"/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin\"
        /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/lipo -create /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Intermediates.noindex/windmill.build/Release-iphonesimulator/windmill.build/Objects-normal/i386/windmill /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Intermediates.noindex/windmill.build/Release-iphonesimulator/windmill.build/Objects-normal/x86_64/windmill -output /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Products/Release-iphonesimulator/windmill.app/windmill
        """
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCreateUniversalBinary(descender: 0.0)
        
        XCTAssertEqual("Create universal binary ...in /DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Products/Release-iphonesimulator/windmill.app/windmill", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    func testProcessProductPackaging() {
        let output = """
        ProcessProductPackaging "" /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Intermediates.noindex/windmill.build/Release-iphonesimulator/windmill.build/windmill.app-Simulated.xcent
        cd /Users/qnoid/Developer/workspace/swift/windmill-ios
        export PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"


        Entitlements:

        {
        "application-identifier" = "AQ2US2UQQ7.io.windmill.windmill";
        "aps-environment" = development;
        }


        builtin-productPackagingUtility -entitlements -format xml -o /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Intermediates.noindex/windmill.build/Release-iphonesimulator/windmill.build/windmill.app-Simulated.xcent

        """
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeProcessProductPackaging(descender: 0.0)
        
        XCTAssertEqual("Process product packaging", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    func testCompileAssetCatalog() {
        let output = """
        CompileAssetCatalog /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Products/Release-iphonesimulator/windmill.app windmill/Assets.xcassets
        cd /Users/qnoid/Developer/workspace/swift/windmill-ios
        export PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        /Applications/Xcode.app/Contents/Developer/usr/bin/actool --output-format human-readable-text --notices --warnings --export-dependency-info /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Intermediates.noindex/windmill.build/Release-iphonesimulator/windmill.build/assetcatalog_dependencies --output-partial-info-plist /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Intermediates.noindex/windmill.build/Release-iphonesimulator/windmill.build/assetcatalog_generated_info.plist --app-icon AppIcon --compress-pngs --enable-on-demand-resources YES --filter-for-device-model iPhone6,1 --filter-for-device-os-version 10.3.1 --sticker-pack-identifier-prefix io.windmill.windmill.sticker-pack. --target-device iphone --minimum-deployment-target 10.3 --platform iphonesimulator --product-type com.apple.product-type.application --compile /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Products/Release-iphonesimulator/windmill.app /Users/qnoid/Developer/workspace/swift/windmill-ios/windmill/Assets.xcassets

        /* com.apple.actool.compilation-results */
        /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Products/Release-iphonesimulator/windmill.app/AppIcon20x20@2x.png
        /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Products/Release-iphonesimulator/windmill.app/AppIcon20x20@3x.png
        /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Products/Release-iphonesimulator/windmill.app/AppIcon29x29@2x.png
        /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Products/Release-iphonesimulator/windmill.app/AppIcon29x29@3x.png
        /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Products/Release-iphonesimulator/windmill.app/AppIcon40x40@2x.png
        /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Products/Release-iphonesimulator/windmill.app/AppIcon40x40@3x.png
        /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Products/Release-iphonesimulator/windmill.app/AppIcon60x60@2x.png
        /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Products/Release-iphonesimulator/windmill.app/AppIcon60x60@3x.png
        /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Products/Release-iphonesimulator/windmill.app/Assets.car
        /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Intermediates.noindex/windmill.build/Release-iphonesimulator/windmill.build/assetcatalog_generated_info.plist
        """
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCompileAssetCatalog(descender: 0.0)
        
        XCTAssertEqual("Compile asset catalogs", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    func testLinkStoryboards() {
        let output = """
        LinkStoryboards
        cd /Users/qnoid/Developer/workspace/swift/windmill-ios
        export PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        export XCODE_DEVELOPER_USR_PATH=/Applications/Xcode.app/Contents/Developer/usr/bin/..
        /Applications/Xcode.app/Contents/Developer/usr/bin/ibtool --errors --warnings --notices --module windmill --target-device iphone --minimum-deployment-target 10.3 --output-format human-readable-text --link /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Products/Release-iphonesimulator/windmill.app /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Intermediates.noindex/windmill.build/Release-iphonesimulator/windmill.build/Base.lproj/LaunchScreen.storyboardc /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-dkymippxvovcscbprykkdhmpyysy/Build/Intermediates.noindex/windmill.build/Release-iphonesimulator/windmill.build/Base.lproj/Main.storyboardc
        """
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeLinkStoryboards(descender: 0.0)
        
        XCTAssertEqual("Link Storyboards", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    
    func testCopySwiftStandardsLibraries() {
        let output = """
        CopySwiftLibs /Users/qnoid/.Trash/DerivedData/helloworld/Build/Products/Debug-iphonesimulator/helloworld.app
        cd /Users/qnoid/Library/Developer/Xcode/DerivedData/windmill-fezcvdrmroaraabfbnktjikmxgvk/Build/Products/Debug/Windmill.app/Contents/PlugIns/windmillTests.xctest/Contents/Resources/helloworld
        export CODESIGN_ALLOCATE=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/codesign_allocate
        export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
        export PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        export SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator11.3.sdk
        builtin-swiftStdLibTool --copy --verbose --sign - --scan-executable /Users/qnoid/.Trash/DerivedData/helloworld/Build/Products/Debug-iphonesimulator/helloworld.app/helloworld --scan-folder /Users/qnoid/.Trash/DerivedData/helloworld/Build/Products/Debug-iphonesimulator/helloworld.app/Frameworks --scan-folder /Users/qnoid/.Trash/DerivedData/helloworld/Build/Products/Debug-iphonesimulator/helloworld.app/PlugIns --platform iphonesimulator --toolchain /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain --destination /Users/qnoid/.Trash/DerivedData/helloworld/Build/Products/Debug-iphonesimulator/helloworld.app/Frameworks --strip-bitcode --resource-destination /Users/qnoid/.Trash/DerivedData/helloworld/Build/Products/Debug-iphonesimulator/helloworld.app --resource-library libswiftRemoteMirror.dylib
        """
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCopyStandardLibraries(descender: 0.0)
        
        XCTAssertEqual("Copy Swift standard libraries helloworld.app ...at /Users/qnoid/.Trash/DerivedData/helloworld/Build/Products/Debug-iphonesimulator/helloworld.app", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    func testCreateProductStructure() {
        let output = """
        Create product structure

        /bin/mkdir -p /Users/qnoid/Library/Developer/Xcode/DerivedData/helloworld-aapmrrhhegvcwgestrsyqfjctwdk/Build/Products/Debug-iphonesimulator/helloworld.app
        """
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCreateProductStructure(descender: 0.0)
        
        XCTAssertEqual("Create product structure", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    func testMergeModulesCommand() {
        let output = """
        MergeSwiftModule normal x86_64 /Users/qnoid/Library/Developer/Xcode/DerivedData/helloworld-aapmrrhhegvcwgestrsyqfjctwdk/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld.swiftmodule
        cd /Users/qnoid/Developer/workspace/swift/windmill-osx/windmillTests/Resources/projects/helloworld
        /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift -frontend -merge-modules -emit-module /Users/qnoid/Library/Developer/Xcode/DerivedData/helloworld-aapmrrhhegvcwgestrsyqfjctwdk/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/ViewController~partial.swiftmodule /Users/qnoid/Library/Developer/Xcode/DerivedData/helloworld-aapmrrhhegvcwgestrsyqfjctwdk/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/AppDelegate~partial.swiftmodule -parse-as-library -sil-merge-partial-modules -disable-diagnostic-passes -disable-sil-perf-optzns -target x86_64-apple-ios10.2 -enable-objc-interop -sdk /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator11.3.sdk -I /Users/qnoid/Library/Developer/Xcode/DerivedData/helloworld-aapmrrhhegvcwgestrsyqfjctwdk/Build/Products/Debug-iphonesimulator -F /Users/qnoid/Library/Developer/Xcode/DerivedData/helloworld-aapmrrhhegvcwgestrsyqfjctwdk/Build/Products/Debug-iphonesimulator -enable-testing -g -module-cache-path /Users/qnoid/Library/Developer/Xcode/DerivedData/ModuleCache.noindex -swift-version 4 -enforce-exclusivity=checked -Onone -D DEBUG -serialize-debugging-options -Xcc -I/Users/qnoid/Library/Developer/Xcode/DerivedData/helloworld-aapmrrhhegvcwgestrsyqfjctwdk/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/swift-overrides.hmap -Xcc -iquote -Xcc /Users/qnoid/Library/Developer/Xcode/DerivedData/helloworld-aapmrrhhegvcwgestrsyqfjctwdk/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/helloworld-generated-files.hmap -Xcc -I/Users/qnoid/Library/Developer/Xcode/DerivedData/helloworld-aapmrrhhegvcwgestrsyqfjctwdk/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/helloworld-own-target-headers.hmap -Xcc -I/Users/qnoid/Library/Developer/Xcode/DerivedData/helloworld-aapmrrhhegvcwgestrsyqfjctwdk/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/helloworld-all-target-headers.hmap -Xcc -iquote -Xcc /Users/qnoid/Library/Developer/Xcode/DerivedData/helloworld-aapmrrhhegvcwgestrsyqfjctwdk/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/helloworld-project-headers.hmap -Xcc -I/Users/qnoid/Library/Developer/Xcode/DerivedData/helloworld-aapmrrhhegvcwgestrsyqfjctwdk/Build/Products/Debug-iphonesimulator/include -Xcc -I/Users/qnoid/Library/Developer/Xcode/DerivedData/helloworld-aapmrrhhegvcwgestrsyqfjctwdk/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/DerivedSources/x86_64 -Xcc -I/Users/qnoid/Library/Developer/Xcode/DerivedData/helloworld-aapmrrhhegvcwgestrsyqfjctwdk/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/DerivedSources -Xcc -DDEBUG=1 -Xcc -working-directory/Users/qnoid/Developer/workspace/swift/windmill-osx/windmillTests/Resources/projects/helloworld -emit-module-doc-path /Users/qnoid/Library/Developer/Xcode/DerivedData/helloworld-aapmrrhhegvcwgestrsyqfjctwdk/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld.swiftdoc -module-name helloworld -emit-objc-header-path /Users/qnoid/Library/Developer/Xcode/DerivedData/helloworld-aapmrrhhegvcwgestrsyqfjctwdk/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld-Swift.h -o /Users/qnoid/Library/Developer/Xcode/DerivedData/helloworld-aapmrrhhegvcwgestrsyqfjctwdk/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld.swiftmodule
        """
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeMergeModulesCommand(descender: 0.0)
        
        XCTAssertEqual("Merge helloworld.swiftmodule ...in /Users/qnoid/Library/Developer/Xcode/DerivedData/helloworld-aapmrrhhegvcwgestrsyqfjctwdk/Build/Intermediates.noindex/helloworld.build/Debug-iphonesimulator/helloworld.build/Objects-normal/x86_64/helloworld.swiftmodule", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    func testSetOwnerAndGroup() {
        let output = """
        SetOwnerAndGroup qnoid:staff /Users/qnoid/Library/Developer/Xcode/DerivedData/Charts-bsfuaegntwehlaacthatbzsarmee/Build/Intermediates.noindex/ArchiveIntermediates/ChartsDemo-iOS-Swift/InstallationBuildProductsLocation/Applications/ChartsDemo-iOS-Swift.app
        cd /Users/qnoid/Library/Caches/io.windmill.windmill/Sources/Charts/ChartsDemo-iOS
        export PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        /usr/sbin/chown -RH qnoid:staff /Users/qnoid/Library/Developer/Xcode/DerivedData/Charts-bsfuaegntwehlaacthatbzsarmee/Build/Intermediates.noindex/ArchiveIntermediates/ChartsDemo-iOS-Swift/InstallationBuildProductsLocation/Applications/ChartsDemo-iOS-Swift.app
        """
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeSetOwnerAndGroup(descender: 0.0)
        
        XCTAssertEqual("Set owner and group of ChartsDemo-iOS-Swift.app ...in /DerivedData/Charts-bsfuaegntwehlaacthatbzsarmee/Build/Intermediates.noindex/ArchiveIntermediates/ChartsDemo-iOS-Swift/InstallationBuildProductsLocation/Applications/ChartsDemo-iOS-Swift.app", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    func testSetMode() {
        let output = """
        SetMode u+w,go-w,a+rX /Users/qnoid/Library/Developer/Xcode/DerivedData/Charts-bsfuaegntwehlaacthatbzsarmee/Build/Intermediates.noindex/ArchiveIntermediates/ChartsDemo-iOS-Swift/InstallationBuildProductsLocation/Applications/ChartsDemo-iOS-Swift.app
        cd /Users/qnoid/Library/Caches/io.windmill.windmill/Sources/Charts/ChartsDemo-iOS
        export PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        /bin/chmod -RH u+w,go-w,a+rX /Users/qnoid/Library/Developer/Xcode/DerivedData/Charts-bsfuaegntwehlaacthatbzsarmee/Build/Intermediates.noindex/ArchiveIntermediates/ChartsDemo-iOS-Swift/InstallationBuildProductsLocation/Applications/ChartsDemo-iOS-Swift.app
        """
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeSetMode(descender: 0.0)
        
        XCTAssertEqual("Set mode of ChartsDemo-iOS-Swift.app ...in /DerivedData/Charts-bsfuaegntwehlaacthatbzsarmee/Build/Intermediates.noindex/ArchiveIntermediates/ChartsDemo-iOS-Swift/InstallationBuildProductsLocation/Applications/ChartsDemo-iOS-Swift.app", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    func testSymLink() {
        let output = """
        SymLink /Users/qnoid/Library/Developer/Xcode/DerivedData/Charts-bsfuaegntwehlaacthatbzsarmee/Build/Intermediates.noindex/ArchiveIntermediates/ChartsDemo-iOS-Swift/BuildProductsPath/Release-iphoneos/Charts.framework /Users/qnoid/Library/Developer/Xcode/DerivedData/Charts-bsfuaegntwehlaacthatbzsarmee/Build/Intermediates.noindex/ArchiveIntermediates/ChartsDemo-iOS-Swift/IntermediateBuildFilesPath/UninstalledProducts/iphoneos/Charts.framework
        cd /Users/qnoid/Library/Caches/io.windmill.windmill/Sources/Charts
        export PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        /bin/ln -sfh /Users/qnoid/Library/Developer/Xcode/DerivedData/Charts-bsfuaegntwehlaacthatbzsarmee/Build/Intermediates.noindex/ArchiveIntermediates/ChartsDemo-iOS-Swift/IntermediateBuildFilesPath/UninstalledProducts/iphoneos/Charts.framework /Users/qnoid/Library/Developer/Xcode/DerivedData/Charts-bsfuaegntwehlaacthatbzsarmee/Build/Intermediates.noindex/ArchiveIntermediates/ChartsDemo-iOS-Swift/BuildProductsPath/Release-iphoneos/Charts.framework

        """
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeSymLink(descender: 0.0)
        
        XCTAssertEqual("Make symlink Charts.framework ...in /DerivedData/Charts-bsfuaegntwehlaacthatbzsarmee/Build/Intermediates.noindex/ArchiveIntermediates/ChartsDemo-iOS-Swift/IntermediateBuildFilesPath/UninstalledProducts/iphoneos/Charts.framework", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }
    
    func testCpHeader() {
        let output = """
        CpHeader Source/Supporting Files/Charts.h /Users/qnoid/Library/Developer/Xcode/DerivedData/Charts-bsfuaegntwehlaacthatbzsarmee/Build/Intermediates.noindex/ArchiveIntermediates/ChartsDemo-iOS-Swift/IntermediateBuildFilesPath/UninstalledProducts/iphoneos/Charts.framework/Headers/Charts.h
        cd /Users/qnoid/Library/Caches/io.windmill.windmill/Sources/Charts
        export PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        builtin-copy -exclude .DS_Store -exclude CVS -exclude .svn -exclude .git -exclude .hg -strip-debug-symbols -strip-tool /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip -resolve-src-symlinks /Users/qnoid/Library/Caches/io.windmill.windmill/Sources/Charts/Source/Supporting Files/Charts.h /Users/qnoid/Library/Developer/Xcode/DerivedData/Charts-bsfuaegntwehlaacthatbzsarmee/Build/Intermediates.noindex/ArchiveIntermediates/ChartsDemo-iOS-Swift/IntermediateBuildFilesPath/UninstalledProducts/iphoneos/Charts.framework/Headers
        
        """
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCpHeader(descender: 0.0)
        
        XCTAssertEqual("Copy Charts.h ...in /Users/qnoid/Library/Caches/io.windmill.windmill/Sources/Charts/Source/Supporting Files/Charts.h", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }

    func testSwiftCodeGeneration() {
        let output = """
        SwiftCodeGeneration normal armv7 /Users/qnoid/Library/Developer/Xcode/DerivedData/Charts-bsfuaegntwehlaacthatbzsarmee/Build/Intermediates.noindex/ArchiveIntermediates/ChartsDemo-iOS-Swift/IntermediateBuildFilesPath/Charts.build/Release-iphoneos/Charts.build/Objects-normal/armv7/Animator.bc
        cd /Users/qnoid/Library/Caches/io.windmill.windmill/Sources/Charts
        /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift -frontend -c -primary-file /Users/qnoid/Library/Developer/Xcode/DerivedData/Charts-bsfuaegntwehlaacthatbzsarmee/Build/Intermediates.noindex/ArchiveIntermediates/ChartsDemo-iOS-Swift/IntermediateBuildFilesPath/Charts.build/Release-iphoneos/Charts.build/Objects-normal/armv7/Animator.bc -embed-bitcode -target armv7-apple-ios8.0 -O -disable-llvm-optzns -module-name Charts -o /Users/qnoid/Library/Developer/Xcode/DerivedData/Charts-bsfuaegntwehlaacthatbzsarmee/Build/Intermediates.noindex/ArchiveIntermediates/ChartsDemo-iOS-Swift/IntermediateBuildFilesPath/Charts.build/Release-iphoneos/Charts.build/Objects-normal/armv7/Animator.o

        """
        
        let formatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeSwiftCodeGeneration(descender: 0.0)
        
        XCTAssertEqual("Code Generation Animator.bc ...in /DerivedData/Charts-bsfuaegntwehlaacthatbzsarmee/Build/Intermediates.noindex/ArchiveIntermediates/ChartsDemo-iOS-Swift/IntermediateBuildFilesPath/Charts.build/Release-iphoneos/Charts.build/Objects-normal/armv7/Animator.bc", formatter.format(for: output)?.string.trimmingCharacters(in: padding))
    }

}
