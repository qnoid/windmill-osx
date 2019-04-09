//
//  RegularExpressionMatchesFormatter+AttributedString.swift
//  windmill
//
//  Created by Markos Charatzas on 13/4/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import AppKit

extension RegularExpressionMatchesFormatter {
    
    static func buildInProgressStatus(descender: CGFloat) -> NSMutableAttributedString {
        let buildInProgressStatus = NSAttributedString(attachment: NSTextAttachment.Windmill.make(image: #imageLiteral(resourceName: "Status-BuildInProgress"))) as! NSMutableAttributedString
        
        buildInProgressStatus.addAttribute(.baselineOffset, value: descender, range: NSMakeRange(0, buildInProgressStatus.length))
        
        return buildInProgressStatus
    }
    
    static func failedBuildStatus(descender: CGFloat) -> NSMutableAttributedString {
        let failedBuildStatus = NSAttributedString(attachment: NSTextAttachment.Windmill.make(image: #imageLiteral(resourceName: "error"))) as! NSMutableAttributedString
        
        failedBuildStatus.addAttribute(.baselineOffset, value: descender, range: NSMakeRange(0, failedBuildStatus.length))
        
        return failedBuildStatus
    }
    
    static func successBuildStatus(descender: CGFloat) -> NSMutableAttributedString {
        let successBuildStatus = NSAttributedString(attachment: NSTextAttachment.Windmill.make(image: #imageLiteral(resourceName: "Success"))) as! NSMutableAttributedString
        
        successBuildStatus.addAttribute(.baselineOffset, value: descender, range: NSMakeRange(0, successBuildStatus.length))
        
        return successBuildStatus
    }
    
    static func failedTestStatus(descender: CGFloat) -> NSMutableAttributedString {
        let failedTestStatus = NSAttributedString(attachment: NSTextAttachment.Windmill.make(image: #imageLiteral(resourceName: "test-failure"))) as! NSMutableAttributedString
        
        failedTestStatus.addAttribute(.baselineOffset, value: descender, range: NSMakeRange(0, failedTestStatus.length))
        
        return failedTestStatus
    }
    
    static func makeCloning(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.CLONING_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return double(match: regularExpression) { path, name in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Cloning into ", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string:  "\(name)\n", attributes: [.foregroundColor : NSColor.textColor]))
            return attributedString
        }
    }
    
    static func makeCheckoutSuccess(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.CHECKOUT_SUCCESS_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return double(match: regularExpression) { commit, log in
            let attributedString = successBuildStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " Checkout", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " succeeded\n\tNo issues", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "\n\t\t \(commit) (", attributes: [.foregroundColor : NSColor.systemYellow]))
            attributedString.append(NSAttributedString(string: "HEAD ->", attributes: [.font: NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular), .foregroundColor : NSColor.systemBlue]))
            attributedString.append(NSAttributedString(string: " master", attributes: [.font: NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular), .foregroundColor : NSColor.systemGreen]))
            attributedString.append(NSAttributedString(string: ")", attributes: [.foregroundColor : NSColor.systemYellow]))
            attributedString.append(NSAttributedString(string: " \(log)\n", attributes: [.font: NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular), .foregroundColor : NSColor.textColor]))
            return attributedString
        }
    }
    
    static func makeBuildTarget(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.BUILD_TARGET_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return triple(match: regularExpression) { target, project, configuration in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Build target", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " \(target)\n", attributes: [.foregroundColor : NSColor.textColor]))
            return attributedString
        }
    }
    
    static func makeLinkStoryboards(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.LINK_STORYBOARDS_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return match(regularExpression) {
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Link", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " Storyboards\n", attributes: [.foregroundColor : NSColor.textColor]))
            return attributedString
        }
    }
    
    static func makeWriteAuxiliaryfiles(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.WRITE_AUXILIARY_FILES_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return match(regularExpression) {
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Write", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " auxiliary files\n", attributes: [.foregroundColor : NSColor.textColor]))
            return attributedString
        }
    }

    static func makeWriteAuxiliaryfile(descender: CGFloat, cachesDirectoryURL: URL = Directory.Windmill.ApplicationCachesDirectory().URL, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.WRITE_AUXILIARY_FILE_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return triple(match: regularExpression) { path, file, target in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Write", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " \(file)", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string:  " ...at \(path.replacingOccurrences(of: cachesDirectoryURL.path, with: ""))\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }

    static func makePhaseScriptExecution(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.PHASE_SCRIPT_EXECUTION_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return single(match: regularExpression) { script in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Run custom shell script ", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "'\(script)'\n", attributes: [.foregroundColor : NSColor.textColor]))
            return attributedString
        }
    }
    
    static func makeCreateProductStructure(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.CREATE_PRODUCT_STRUCTURE_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return match(regularExpression) {
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Create", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " product structure\n", attributes: [.foregroundColor : NSColor.textColor]))
            return attributedString
        }
    }
    
    static func makeCompileSwiftSources(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.COMPILE_SWIFT_SOURCES_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return match(regularExpression) {
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Compile", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " Swift source files\n", attributes: [.foregroundColor : NSColor.textColor]))
            return attributedString
        }
    }
    
    static func makeCreateUniversalBinary(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.CREATE_UNIVERSAL_BINARY_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return single(match: regularExpression) { path in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Create", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " universal binary ...in \(path)\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }
    
    static func makeCreateBuildDirectory(descender: CGFloat, cachesDirectoryURL: URL = Directory.Windmill.ApplicationCachesDirectory().URL, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.CREATE_BUILD_DIRECTORY_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return triple(match: regularExpression) { path, filename, target in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "CreateBuildDirectory", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " \(filename)", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string:  " ...at \(path.replacingOccurrences(of: cachesDirectoryURL.path, with: ""))\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }

    static func makeCreateAppDirectory(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.CREATE_APP_DIRECTORY_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return single(match: regularExpression) { filename in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Create Directory", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " \"\(filename)\"\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }

    static func makeCopyUsingDitto(descender: CGFloat, cachesDirectoryURL: URL = Directory.Windmill.ApplicationCachesDirectory().URL, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.COPY_USING_DITTO_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return triple(match: regularExpression) { source, destination, filename in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Copy ", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: filename, attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string:  " ...at \(destination.replacingOccurrences(of: cachesDirectoryURL.path, with: ""))\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }
    
    static func makePhaseSuccess(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.PHASE_SUCCESS_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return single(match: regularExpression) { phase in
            let attributedString = successBuildStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: phase.prefix(1).uppercased() + phase.lowercased().dropFirst(), attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " succeeded\n\tNo issues\n", attributes: [.foregroundColor : NSColor.textColor]))
            return attributedString
        }
    }
    
    static func makeCompileError(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.COMPILE_ERROR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return triple(match: regularExpression) { path, file, error in
            let attributedString = NSMutableAttributedString(string: "\t", attributes: [.foregroundColor : NSColor.textColor])
            attributedString.append(failedBuildStatus(descender: descender))
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "\(error)\n", attributes: [.foregroundColor : NSColor.systemRed]))
            return attributedString
        }
    }
    
    static func makeClangError(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.CLANG_ERROR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return single(match: regularExpression) { error in
            let attributedString = NSMutableAttributedString(string: "\t", attributes: [.foregroundColor : NSColor.textColor])
            attributedString.append(failedBuildStatus(descender: descender))
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "\(error)\n", attributes: [.foregroundColor : NSColor.systemRed]))
            return attributedString
        }
    }
    
    static func makeGlobalError(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.GLOBAL_ERROR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return single(match: regularExpression) { error in
            let attributedString = NSMutableAttributedString(string: "\t", attributes: [.foregroundColor : NSColor.textColor])
            attributedString.append(failedBuildStatus(descender: descender))
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "\(error)\n", attributes: [.foregroundColor : NSColor.systemRed]))
            return attributedString
        }
    }
    
    static func makeXcodeBuildError(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.XCODEBUILD_ERROR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return single(match: regularExpression) { error in
            let attributedString = failedBuildStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "\(error)\n", attributes: [.foregroundColor : NSColor.systemRed]))
            return attributedString
        }
    }
    
    static func makeLibraryNotFound(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.LIBRARY_NOT_FOUND_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return single(match: regularExpression) { library in
            let attributedString = NSMutableAttributedString(string: "\t", attributes: [.foregroundColor : NSColor.textColor])
            attributedString.append(NSAttributedString(string: " Library not found for ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "\(library)\n", attributes: [.foregroundColor : NSColor.textColor]))
            return attributedString
        }
    }
    
    
    static func makeMergeModulesCommand(descender: CGFloat, cachesDirectoryURL: URL = Directory.Windmill.ApplicationCachesDirectory().URL, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.MERGE_MODULES_COMMAND_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return double(match: regularExpression) { path, filename in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Merge ", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: filename, attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " ...in \(path.replacingOccurrences(of: cachesDirectoryURL.path, with: ""))\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }
    
    static func makePBXCP0900(descender: CGFloat, cachesDirectoryURL: URL = Directory.Windmill.ApplicationCachesDirectory().URL, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.PBXCP_REGULAR_EXPRESSION_XCODE_0900) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return double(match: regularExpression) { filename, path in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Copy ", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: filename, attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string:  " ...at \(path.replacingOccurrences(of: cachesDirectoryURL.path, with: ""))\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }

    static func makePBXCP(descender: CGFloat, cachesDirectoryURL: URL = Directory.Windmill.ApplicationCachesDirectory().URL, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.PBXCP_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return triple(match: regularExpression) { path, filename, target in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Copy ", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "\(filename)\n", attributes: [.foregroundColor : NSColor.textColor]))
            return attributedString
        }
    }
    
    static func makeGenerateDSYM(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.GENERATE_DSYM_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return single(match: regularExpression) { dsym in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Generate ", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "\(dsym)\n", attributes: [.foregroundColor : NSColor.textColor]))
            return attributedString
        }
    }
    
    static func makeCopyStandardLibraries(descender: CGFloat, cachesDirectoryURL: URL = Directory.Windmill.ApplicationCachesDirectory().URL, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.COPY_SWIFT_STANDARD_LIBRARIES_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return double(match: regularExpression) { path, filename in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Copy Swift standard libraries ", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: filename, attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string:  " ...at \(path.replacingOccurrences(of: cachesDirectoryURL.path, with: ""))\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }
    
    static func makePhaseFailure(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.PHASE_FAILURE_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return single(match: regularExpression) { phase in
            let attributedString = failedBuildStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: phase.prefix(1).uppercased() + phase.lowercased().dropFirst(), attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " failed\n", attributes: [.foregroundColor : NSColor.textColor]))
            return attributedString
        }
    }
    
    static func makeTestSuiteAllTestsStarted(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.TEST_SUITE_ALL_TESTS_STARTED_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return match(regularExpression) {
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " Run test suite", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " All Tests\n", attributes: [.foregroundColor : NSColor.textColor]))
            return attributedString
        }
    }
    
    static func makeTestSuiteXctestStarted(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.TEST_SUITE_XCTEST_STARTED_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return single(match: regularExpression) { xctest in
            let attributedString = NSMutableAttributedString(string: "\t", attributes: [.foregroundColor : NSColor.textColor])
            attributedString.append(buildInProgressStatus(descender: descender))
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Test Suite", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " '\(xctest)'\n", attributes: [.foregroundColor : NSColor.textColor]))
            return attributedString
        }
    }
    
    static func makeTestSuiteStarted(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.TEST_SUITE_STARTED_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return single(match: regularExpression) { testsuite in
            let attributedString = NSMutableAttributedString(string: "\t\t", attributes: [.foregroundColor : NSColor.textColor])
            attributedString.append(buildInProgressStatus(descender: descender))
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Test Suite", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " '\(testsuite)'\n", attributes: [.foregroundColor : NSColor.textColor]))
            return attributedString
        }
    }
    
    static func makeTestCasePassed(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.TEST_CASE_PASSED_MATCHER) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return triple(match: regularExpression) { suite, testcase, duration in
            let attributedString = NSMutableAttributedString(string: "\t\t\t", attributes: [.foregroundColor : NSColor.textColor])
            attributedString.append(successBuildStatus(descender: descender))
            attributedString.append(NSAttributedString(string: " Run test case", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " '\(testcase)()'", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " \(duration) seconds\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }
    
    static func makeTestCaseFailed(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.FAILING_TEST_CASE_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return quadriple(match: regularExpression) { path, suite, testcase, message in
            let attributedString = NSMutableAttributedString(string: "\t\t", attributes: [.foregroundColor : NSColor.textColor])
            attributedString.append(failedTestStatus(descender: descender))
            attributedString.append(NSAttributedString(string: " Run test case", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " '\(testcase)()'", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "\n\t\t\t", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(failedTestStatus(descender: descender))
            attributedString.append(NSAttributedString(string: " \(message)\n", attributes: [.foregroundColor : NSColor.systemRed]))
            return attributedString
        }
    }
    
    static func makeCodeSign(descender: CGFloat, cachesDirectoryURL: URL = Directory.Windmill.ApplicationCachesDirectory().URL, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.CODESIGN_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return double(match: regularExpression) { path, filename in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Sign ", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: filename, attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string:  " ...in \(path.replacingOccurrences(of: cachesDirectoryURL.path, with: ""))\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }
    
    static func makeLinking(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.LINKING_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return quadriple(match: regularExpression) { path, filename, variant, architecture in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Link", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " \(filename)", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string:  " ...in \(path)\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }
    
    static func makeLinkRelative(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.LINK_RELATIVE_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return quadriple(match: regularExpression) { path, filename, variant, architecture in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Link", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " \(filename)", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string:  " ...in \(path)\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }
    
    static func makeProcessProductPackaging(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.PROCESS_PRODUCT_PACKAGINGREGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return match(regularExpression) {
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Process", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " product packaging\n", attributes: [.foregroundColor : NSColor.textColor]))
            return attributedString
        }
    }
    
    static func makeTouch0900(descender: CGFloat, cachesDirectoryURL: URL = Directory.Windmill.ApplicationCachesDirectory().URL, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.TOUCH_REGULAR_EXPRESSION_XCODE_0900) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return double(match: regularExpression) { path, filename in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Touch ", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: filename, attributes: [.foregroundColor : NSColor.textColor]))
            return attributedString
        }
    }
    
    static func makeTouch(descender: CGFloat, cachesDirectoryURL: URL = Directory.Windmill.ApplicationCachesDirectory().URL, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.TOUCH_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return triple(match: regularExpression) { path, filename, target in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Touch ", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: filename, attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string:  " ...in \(path.replacingOccurrences(of: cachesDirectoryURL.path, with: ""))\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }
    
    static func makeProcessInfoPlist(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.PROCESS_INFO_PLIST_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return double(match: regularExpression) { path, filename in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Process", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " \(filename)", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string:  " ...in \(path)\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }
    
    
    static func makeCompileAssetCatalog(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.COMPILE_ASSET_CATALOG_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return match(regularExpression) {
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Compile", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " asset catalogs\n", attributes: [.foregroundColor : NSColor.textColor]))
            return attributedString
        }
    }
    
    static func makeCompileXIB(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.COMPILE_XIB_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return double(match: regularExpression) { path, filename in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Compile XIB file ", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: filename, attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string:  " ...in \(path)\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }
    
    static func makeCompileStoryboard(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.COMPILE_STORYBOARD_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return double(match: regularExpression) { path, filename in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Compile Storyboard file ", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: filename, attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string:  " ...in \(path)\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }
    
    static func makeCompile(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.COMPILE_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return double(match: regularExpression) { path, filename in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Compile ", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: filename, attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string:  " ...in \(path)\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }
    
    static func makeCompile(descender: CGFloat, baseDirectoryURL: URL, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.COMPILE_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return double(match: regularExpression) { path, filename in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Compile ", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: filename, attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string:  " ...in \(path.replacingOccurrences(of: baseDirectoryURL.path, with: ""))\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }
    
    static func makeCompileNote(regularExpression: NSRegularExpression = NSRegularExpression.Windmill.COMPILE_NOTE_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return single(match: regularExpression) { note in
            return NSAttributedString(string: "\t\t\t\(note)\n", attributes: [.foregroundColor : NSColor.textColor])
        }
    }
    
    static func makeStrip0900(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.STRIP_REGULAR_EXPRESSION_XCODE_0900) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return double(match: regularExpression) { path, name in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Strip ", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: name, attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string:  " ...in \(path)\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }
    
    static func makeStrip(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.STRIP_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return triple(match: regularExpression) { path, filename, target in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Strip ", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "\(filename)", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " \(path)\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }
    
    static func makeSetOwnerAndGroup(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.SET_OWNER_AND_GROUP_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return double(match: regularExpression) { path, filename in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Set owner and group of ", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: filename, attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string:  " ...in \(path)\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }
    
    static func makeSetMode(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.SET_MODE_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return double(match: regularExpression) { path, filename in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Set mode of ", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: filename, attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string:  " ...in \(path)\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }
    
    static func makeSymLink(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.SYMLINK_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return double(match: regularExpression) { path, filename in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Make symlink ", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: filename, attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string:  " ...in \(path)\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }
    
    static func makeCpHeader(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.CPHEADER_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return double(match: regularExpression) { filename, path in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Copy ", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: filename, attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string:  " ...in \(path)\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }
    
    static func makeCpHeader(descender: CGFloat, baseDirectoryURL: URL, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.CPHEADER_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return double(match: regularExpression) { path, filename in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Copy ", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: filename, attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string:  "...in \(path.replacingOccurrences(of: baseDirectoryURL.path, with: ""))\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }
    
    static func makeSwiftCodeGeneration(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.SWIFT_CODE_GENERATION_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return double(match: regularExpression) { path, filename in
            let attributedString = buildInProgressStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: "Code Generation ", attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: filename, attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string:  " ...in \(path)\n", attributes: [.foregroundColor : NSColor.systemGray]))
            return attributedString
        }
    }
    
    static func makeErrorFailureReason(regularExpression: NSRegularExpression = NSRegularExpression.Windmill.ERROR_FAILURE_REASON_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return single(match: regularExpression) { failureReason in
            return NSAttributedString(string: "\t\t\(failureReason)\n", attributes: [.foregroundColor : NSColor.textColor])
        }
    }

    static func makeErrorRecoverySuggestion(regularExpression: NSRegularExpression = NSRegularExpression.Windmill.ERROR_RECOVERY_SUGGESTION_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return single(match: regularExpression) { recoverySuggestion in
            return NSAttributedString(string: "\t\t\(recoverySuggestion)\n", attributes: [.foregroundColor : NSColor.textColor])
        }
    }

    static func makeErrorTitle(descender: CGFloat, regularExpression: NSRegularExpression = NSRegularExpression.Windmill.ERROR_TITLE_REGULAR_EXPRESSION) -> RegularExpressionMatchesFormatter<NSAttributedString> {
        return double(match: regularExpression) { primary, secondary in
            let attributedString = failedBuildStatus(descender: descender)
            attributedString.append(NSAttributedString(string: " ", attributes: [.foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: primary.prefix(1).uppercased() + primary.lowercased().dropFirst(), attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor : NSColor.textColor]))
            attributedString.append(NSAttributedString(string: " \(secondary)\n", attributes: [.foregroundColor : NSColor.textColor]))
            return attributedString
        }
    }

}
