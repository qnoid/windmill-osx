//
//  Foo.swift
//  windmill
//
//  Created by Markos Charatzas on 10/4/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation

extension NSRegularExpression {

    struct Windmill {
        
        // capture groups
        // $1 commit
        // $2 log
        static let CHECKOUT_SUCCESS = try! NSRegularExpression(pattern: "^HEAD is now at (.*?)\\s(.*)")
        
        // capture groups
        // $1 target
        // $2 project
        // $3 configuration
        static let BUILD_TARGET_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^=== BUILD TARGET\\s(.*)\\sOF PROJECT\\s(.*)\\sWITH.*CONFIGURATION\\s(.*)\\s===")
        
        // capture groups
        // $1 path
        // $2 file
        static let CODESIGN_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^CodeSign\\s(.*/(.*.(?:app|xctest)))\\s*")
        
        static let COMPILE_SWIFT_SOURCES_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^CompileSwiftSources")
        
        // capture groups
        // $1 path
        // $2 file
        static let COMPILE_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^Compile[\\w]+\\s.+?\\s((?:\\.|[^ ])+\\/((?:\\.|[^ ])+\\.(?:m|mm|c|cc|cpp|cxx|swift)))")
        
        // capture groups
        // $1 path
        // $2 file
        static let COMPILE_XIB_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^CompileXIB\\s(.*\\/(.*\\.xib))")
        
        // capture groups
        // $1 path
        // $2 file
        static let COMPILE_STORYBOARD_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^CompileStoryboard\\s(.*\\/([^\\/].*\\.storyboard))")
        
        // capture groups
        // $1 path
        // $2 file
        static let COPY_SWIFT_STANDARD_LIBRARIES_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^CopySwiftLibs\\s(.*\\/(.*\\.app))")
        
        // capture groups
        // $1 source
        // $2 destination
        // $3 filename
        static let COPY_USING_DITTO_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^Ditto\\s(.*\\.(?:h|swiftmodule|swiftdoc))\\s(.*\\/(.*\\.(?:h|swiftmodule|swiftdoc)))")
        
        // capture groups
        // $1 path
        static let CREATE_UNIVERSAL_BINARY_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^CreateUniversalBinary\\s(.*?)\\s")
        
        static let COMPILE_ASSET_CATALOG_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^CompileAssetCatalog")
        
        static let CREATE_PRODUCT_STRUCTURE_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^Create product structure")
        
        static let PROCESS_PRODUCT_PACKAGINGREGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^ProcessProductPackaging")
        
        // capture groups
        // $1 dsym
        static let GENERATE_DSYM_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^GenerateDSYMFile \\/.*\\/(.*\\.dSYM)")
        
        // capture groups
        // $1 path
        // $2 filename
        // $3 variant
        // $4 architecture
        static let LINKING_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^Ld\\s(.*\\/.*.app\\/([^\\s]+))\\s([^\\s]+)\\s([^\\s]+)")
        
        // capture groups
        // $1 path
        // $2 file
        static let MERGE_MODULES_COMMAND_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^MergeSwiftModule\\s.+?\\s((?:\\.|[^ ])+/((?:\\.|[^ ])+\\.(?:swiftmodule)))")
        
        static let LINK_STORYBOARDS_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^LinkStoryboards")
        
        // capture groups
        // $1 phase
        static let PHASE_SUCCESS_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^\\*\\*\\s(.*)\\sSUCCEEDED\\s\\*\\*")
        
        // capture groups
        // $1 phase
        static let PHASE_FAILURE_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^\\*\\*\\s(.*)\\sFAILED\\s\\*\\*")
        
        // capture groups
        // $1 name
        static let PHASE_SCRIPT_EXECUTION_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^PhaseScriptExecution\\s((\\\\ |\\S)*)\\s")
        
        // capture groups
        // $1 path
        // $2 filename
        static let PBXCP_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^PBXCp\\s.*\\/(.*.framework) (.*)")
        
        // capture groups
        // $1 path
        // $2 filename
        static let PROCESS_INFO_PLIST_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^ProcessInfoPlistFile\\s.*\\.plist\\s(.*\\/+(.*\\.plist))")
        
        // capture groups
        // $1 suite
        // $2 test_case
        // $3 duration (in seconds)
        static let TEST_CASE_PASSED_MATCHER = try! NSRegularExpression(pattern: "^\\s*Test Case\\s'-\\[(.*)\\s(.*)\\]'\\spassed\\s\\((\\d*\\.\\d{3})\\sseconds\\)")
        
        static let TEST_SUITE_ALL_TESTS_STARTED_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^Test Suite 'All tests' started")
        
        // capture groups
        // $1 suite
        static let TEST_SUITE_XCTEST_STARTED_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^Test Suite '(?:.*\\/)?(.*xctest)' started")
        
        static let TEST_SUITE_STARTED_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^Test Suite '(.*Test)' started at")
        
        // capture groups
        // $1 suite
        // $2 testcase
        // $3 duration (in seconds)
        static let TEST_CASE_PASSED_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^Test Case\\s'-\\[.*\\.(.*)\\s(.*)\\]'\\spassed\\s\\((\\d*\\.\\d{3})\\sseconds\\)")
        
        // capture groups
        // $1 path
        // $2 testsuite
        // $3 testcase
        // $4 message
        static let FAILING_TEST_CASE_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^(\\/.+\\/.*):.*\\serror:\\s-(?:\\[.*\\.(.*)\\s(.*)\\])\\s:\\s(.*)")
        
        // capture groups
        // $1 path
        // $2 file
        static let TOUCH_REGULAR_EXPRESSION = try! NSRegularExpression(pattern: "^Touch\\s(.*\\/(.+))")
        
        // capture groups
        static let WRITE_AUXILIARY_FILES_EXPRESSION = try! NSRegularExpression(pattern: "^Write auxiliary files")
        
        // capture groups
        // $1 path
        // $2 file
        // $3 = error
        static let COMPILE_ERROR_EXPRESSION = try! NSRegularExpression(pattern: "^(\\/.+\\/(.*):).*:.*:\\s(?:fatal\\s)?(?:warning|error):\\s(.*)")
        
        // capture groups
        // $1 note
        static let NOTE_EXPRESSION = try! NSRegularExpression(pattern: "\\snote:\\s(.*)")
    }
}

class RegularExpressionMatchesFormatter<T>: Formatter {
    
    static func quadriple<T>(match regularExpression: NSRegularExpression, format: @escaping (String, String, String, String) -> T) -> RegularExpressionMatchesFormatter<T> {
        return RegularExpressionMatchesFormatter<T>( formatter: { output in
            
            let matches = regularExpression.matches(in: output, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: output.utf16.count))
            
            let string = output as NSString
            
            for match in matches {
                let first = string.substring(with: match.range(at: 1))
                let second = string.substring(with: match.range(at: 2))
                let third = string.substring(with: match.range(at: 3))
                let fourth = string.substring(with: match.range(at: 4))
                
                return format(first, second, third, fourth)
            }
            
            return nil
        })
    }
    
    static func triple<T>(match regularExpression: NSRegularExpression, format: @escaping (String, String, String) -> T) -> RegularExpressionMatchesFormatter<T> {
        return RegularExpressionMatchesFormatter<T>( formatter: { output in
            
            let matches = regularExpression.matches(in: output, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: output.utf16.count))
            
            let string = output as NSString
            
            for match in matches {
                let first = string.substring(with: match.range(at: 1))
                let second = string.substring(with: match.range(at: 2))
                let third = string.substring(with: match.range(at: 3))
                
                return format(first, second, third)
            }
            
            return nil
        })
    }

    static func double<T>(match regularExpression: NSRegularExpression, format: @escaping (String, String) -> T) -> RegularExpressionMatchesFormatter<T> {
        return RegularExpressionMatchesFormatter<T>( formatter: { output in
            
            let matches = regularExpression.matches(in: output, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: output.utf16.count))
            let string = output as NSString
            
            for match in matches {
                let first = string.substring(with: match.range(at: 1))
                let second = string.substring(with: match.range(at: 2))
                return format(first, second)
            }
            
            return nil
        })
    }

    static func single<T>(match regularExpression: NSRegularExpression, format: @escaping (String) -> T) -> RegularExpressionMatchesFormatter<T> {
        return RegularExpressionMatchesFormatter<T>( formatter: { output in
            
            let matches = regularExpression.matches(in: output, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: output.utf16.count))
            let string = output as NSString
            
            for match in matches {
                let first = string.substring(with: match.range(at: 1))
                return format(first)
            }
            
            return nil
        })
    }
    
    static func match<T>(_ regularExpression: NSRegularExpression, format: @escaping () -> T ) -> RegularExpressionMatchesFormatter<T> {
        return RegularExpressionMatchesFormatter<T>( formatter: { output in
            let matches = regularExpression.matches(in: output, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: output.utf16.count))
            return matches.count == 0 ? nil : format()
        })
    }
    
    typealias StandardOutputFormatter = (String) -> T?
    
    let formatter: StandardOutputFormatter
    
    init(formatter: @escaping StandardOutputFormatter) {
        self.formatter = formatter
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.formatter = { _ in return nil }
        super.init(coder: aDecoder)
    }
    
    func format(for obj: Any?) -> T? {
        guard let output = obj as? String else {
            return nil
        }
        
        return formatter(output)
    }
}
