//
//  PrettyFormatter.swift
//  windmill
//
//  Created by Markos Charatzas on 12/4/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation

class StandardOutPrettyFormatter: Formatter {
    
    let cloningFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let checkoutSuccessFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let buildTargetFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let writeAuxiliaryfilesFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let createProductStructureFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let compileSwiftSourcesFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let swiftCodeGenerationFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let mergeModulesCommandFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let compileFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let compileNoteFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCompileNote()
    let compileErrorFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let clangErrorFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let globalErrorFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let xcodeBuildErrorFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let libraryNotFoundFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let noteFormatter = RegularExpressionMatchesFormatter<String>.makeNote()
    let reasonFormatter = RegularExpressionMatchesFormatter<String>.makeReason()
    let copyUsingDittoFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let createUniversalBinaryFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let compileXIBFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let compileStoryboardFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let compileAssetCatalogFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let processInfoPlistFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let pbxcpFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let stripFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let setOwnerAndGroupFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let setModeFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let symLinkFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let cpHeaderFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let generateDSYMFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let linkStoryboardsFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let phaseScriptExecutionFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let copyStandardLibrariesFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let touchFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let processProductPackagingFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let linkingFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let linkRelativeFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let codeSignFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let phaseSuccessFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let phaseFailureFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let testSuiteAllTestsStartedFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let testSuiteXctestStartedFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let testSuiteStartedFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let testCasePassedFormatter: RegularExpressionMatchesFormatter<NSAttributedString>
    let testCaseFailedFormatter: RegularExpressionMatchesFormatter<NSAttributedString>

    let descender: CGFloat
    
    init(descender: CGFloat, compileFormatter: RegularExpressionMatchesFormatter<NSAttributedString>, cpHeaderFormatter: RegularExpressionMatchesFormatter<NSAttributedString>) {
        self.descender = descender
        self.cloningFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCloning(descender: descender)
        self.checkoutSuccessFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCheckoutSuccess(descender: descender)
        self.buildTargetFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeBuildTarget(descender: descender)
        self.writeAuxiliaryfilesFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeWriteAuxiliaryfiles(descender: descender)
        self.createProductStructureFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCreateProductStructure(descender: descender)
        self.compileFormatter = compileFormatter
        self.compileErrorFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCompileError(descender: descender)
        self.clangErrorFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeClangError(descender: descender)
        self.globalErrorFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeGlobalError(descender: descender)
        self.xcodeBuildErrorFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeXcodeBuildError(descender: descender)
        self.libraryNotFoundFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeLibraryNotFound(descender: descender)
        self.compileSwiftSourcesFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCompileSwiftSources(descender: descender)
        self.swiftCodeGenerationFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeSwiftCodeGeneration(descender: descender)
        self.compileXIBFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCompileXIB(descender: descender)
        self.compileStoryboardFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCompileStoryboard(descender: descender)
        self.compileAssetCatalogFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCompileAssetCatalog(descender: descender)
        self.processInfoPlistFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeProcessInfoPlist(descender: descender)
        self.mergeModulesCommandFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeMergeModulesCommand(descender: descender)
        self.copyUsingDittoFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCopyUsingDitto(descender: descender)
        self.createUniversalBinaryFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCreateUniversalBinary(descender: descender)
        self.pbxcpFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makePBXCP(descender: descender)
        self.stripFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeStrip(descender: descender)
        self.setOwnerAndGroupFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeSetOwnerAndGroup(descender: descender)
        self.setModeFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeSetMode(descender: descender)
        self.symLinkFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeSymLink(descender: descender)
        self.cpHeaderFormatter = cpHeaderFormatter
        self.generateDSYMFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeGenerateDSYM(descender: descender)
        self.linkStoryboardsFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeLinkStoryboards(descender: descender)
        self.phaseScriptExecutionFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makePhaseScriptExecution(descender: descender)
        self.copyStandardLibrariesFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCopyStandardLibraries(descender: descender)
        self.touchFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeTouch(descender: descender)
        self.processProductPackagingFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeProcessProductPackaging(descender: descender)
        self.linkingFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeLinking(descender: descender)
        self.linkRelativeFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeLinking(descender: descender)
        self.codeSignFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCodeSign(descender: descender)
        self.phaseSuccessFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makePhaseSuccess(descender: descender)
        self.phaseFailureFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makePhaseFailure(descender: descender)
        self.testSuiteAllTestsStartedFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeTestSuiteAllTestsStarted(descender: descender)
        self.testSuiteXctestStartedFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeTestSuiteXctestStarted(descender: descender)
        self.testSuiteStartedFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeTestSuiteStarted(descender: descender)
        self.testCasePassedFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeTestCasePassed(descender: descender)
        self.testCaseFailedFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeTestCaseFailed(descender: descender)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.descender = 0.0
        self.cloningFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCloning(descender: descender)
        self.checkoutSuccessFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCheckoutSuccess(descender: descender)
        self.buildTargetFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeBuildTarget(descender: descender)
        self.writeAuxiliaryfilesFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeWriteAuxiliaryfiles(descender: descender)
        self.createProductStructureFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCreateProductStructure(descender: descender)
        self.compileFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCompile(descender: descender)
        self.compileErrorFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCompileError(descender: descender)
        self.clangErrorFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeClangError(descender: descender)
        self.globalErrorFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeGlobalError(descender: descender)
        self.xcodeBuildErrorFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeXcodeBuildError(descender: descender)
        self.libraryNotFoundFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeLibraryNotFound(descender: descender)
        self.compileXIBFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCompileXIB(descender: descender)
        self.compileStoryboardFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCompileStoryboard(descender: descender)
        self.compileAssetCatalogFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCompileAssetCatalog(descender: descender)
        self.processInfoPlistFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeProcessInfoPlist(descender: descender)
        self.mergeModulesCommandFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeMergeModulesCommand(descender: descender)
        self.compileSwiftSourcesFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCompileSwiftSources(descender: descender)
        self.swiftCodeGenerationFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeSwiftCodeGeneration(descender: descender)
        self.copyUsingDittoFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCopyUsingDitto(descender: descender)
        self.createUniversalBinaryFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCreateUniversalBinary(descender: descender)
        self.pbxcpFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makePBXCP(descender: descender)
        self.stripFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeStrip(descender: descender)
        self.setOwnerAndGroupFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeSetOwnerAndGroup(descender: descender)
        self.setModeFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeSetMode(descender: descender)
        self.symLinkFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeSymLink(descender: descender)
        self.cpHeaderFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCpHeader(descender: descender)
        self.generateDSYMFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeGenerateDSYM(descender: descender)
        self.linkStoryboardsFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeLinkStoryboards(descender: descender)
        self.phaseScriptExecutionFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makePhaseScriptExecution(descender: descender)
        self.copyStandardLibrariesFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCopyStandardLibraries(descender: descender)
        self.touchFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeTouch(descender: descender)
        self.processProductPackagingFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeProcessProductPackaging(descender: descender)
        self.linkingFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeLinking(descender: descender)
        self.linkRelativeFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeLinking(descender: descender)
        self.codeSignFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeCodeSign(descender: descender)
        self.phaseSuccessFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makePhaseSuccess(descender: descender)
        self.phaseFailureFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makePhaseFailure(descender: descender)
        self.testSuiteAllTestsStartedFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeTestSuiteAllTestsStarted(descender: descender)
        self.testSuiteXctestStartedFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeTestSuiteXctestStarted(descender: descender)
        self.testSuiteStartedFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeTestSuiteStarted(descender: descender)
        self.testCasePassedFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeTestCasePassed(descender: descender)
        self.testCaseFailedFormatter = RegularExpressionMatchesFormatter<NSAttributedString>.makeTestCaseFailed(descender: descender)
        super.init(coder: aDecoder)
    }
    
    override func string(for obj: Any?) -> String? {
        if let note = noteFormatter.format(for: obj) {
            return note
        } else if let reason = reasonFormatter.format(for: obj) {
            return reason
        } else {
            return nil
        }
    }
    
    override func attributedString(for obj: Any, withDefaultAttributes attrs: [NSAttributedString.Key : Any]? = nil) -> NSAttributedString? {
        if let cloning = self.cloningFormatter.format(for: obj) {
            return cloning
        } else if let checkoutSuccess = self.checkoutSuccessFormatter.format(for: obj) {
            return checkoutSuccess
        } else if let buildTarget = self.buildTargetFormatter.format(for: obj) {
            return buildTarget
        } else if let compile = self.compileFormatter.format(for: obj) {
            return compile
        } else if let compileNote = self.compileNoteFormatter.format(for: obj) {
            return compileNote
        } else if let writeAuxiliaryfiles = self.writeAuxiliaryfilesFormatter.format(for: obj) {
            return writeAuxiliaryfiles
        } else if let createProductStructure = self.createProductStructureFormatter.format(for: obj) {
            return createProductStructure
        } else if let compileSwiftSources = self.compileSwiftSourcesFormatter.format(for: obj) {
            return compileSwiftSources
        } else if let copyUsingDitto = self.copyUsingDittoFormatter.format(for: obj) {
            return copyUsingDitto
        } else if let compileAssetCatalog = self.compileAssetCatalogFormatter.format(for: obj) {
            return compileAssetCatalog
        } else if let symLink = self.symLinkFormatter.format(for: obj) {
            return symLink
        } else if let swiftCodeGeneration = self.swiftCodeGenerationFormatter.format(for: obj) {
            return swiftCodeGeneration
        } else if let cpHeader = self.cpHeaderFormatter.format(for: obj) {
            return cpHeader
        } else if let processInfoPlist = self.processInfoPlistFormatter.format(for: obj) {
            return processInfoPlist
        } else if let createUniversalBinary = self.createUniversalBinaryFormatter.format(for: obj) {
            return createUniversalBinary
        } else if let phaseSuccess = self.phaseSuccessFormatter.format(for: obj) {
            return phaseSuccess
        } else if let compileError = self.compileErrorFormatter.format(for: obj) {
            return compileError
        } else if let clangError = self.clangErrorFormatter.format(for: obj) {
            return clangError
        } else if let globalError = self.globalErrorFormatter.format(for: obj) {
            return globalError
        } else if let xcodeBuildError = self.xcodeBuildErrorFormatter.format(for: obj) {
            return xcodeBuildError
        } else if let libraryNotFound = self.libraryNotFoundFormatter.format(for: obj) {
            return libraryNotFound
        } else if let mergeModulesCommand = self.mergeModulesCommandFormatter.format(for: obj) {
            return mergeModulesCommand
        } else if let compileXIB = self.compileXIBFormatter.format(for: obj) {
            return compileXIB
        } else if let compileStoryboard = self.compileStoryboardFormatter.format(for: obj) {
            return compileStoryboard
        } else if let pbxcp = self.pbxcpFormatter.format(for: obj) {
            return pbxcp
        } else if let strip = self.stripFormatter.format(for: obj) {
            return strip
        } else if let setOwnerAndGroup = self.setOwnerAndGroupFormatter.format(for: obj) {
            return setOwnerAndGroup
        } else if let setMode = self.setModeFormatter.format(for: obj) {
            return setMode
        } else if let touch = self.touchFormatter.format(for: obj) {
            return touch
        } else if let codeSign = self.codeSignFormatter.format(for: obj) {
            return codeSign
        } else if let generateDSYM = self.generateDSYMFormatter.format(for: obj) {
            return generateDSYM
        } else if let linkStoryboards = self.linkStoryboardsFormatter.format(for: obj) {
            return linkStoryboards
        } else if let phaseScriptExecution = self.phaseScriptExecutionFormatter.format(for: obj) {
            return phaseScriptExecution
        } else if let copyStandardLibraries = self.copyStandardLibrariesFormatter.format(for: obj) {
            return copyStandardLibraries
        } else if let processProductPackaging = self.processProductPackagingFormatter.format(for: obj) {
            return processProductPackaging
        } else if let linking = self.linkingFormatter.format(for: obj) {
            return linking
        } else if let linkRelative = self.linkRelativeFormatter.format(for: obj) {
            return linkRelative
        } else if let phaseFailure = self.phaseFailureFormatter.format(for: obj) {
            return phaseFailure
        } else if let testSuiteAllTestsStarted = self.testSuiteAllTestsStartedFormatter.format(for: obj) {
            return testSuiteAllTestsStarted
        } else if let testSuiteXctestStarted = self.testSuiteXctestStartedFormatter.format(for: obj) {
            return testSuiteXctestStarted
        } else if let testSuiteStarted = self.testSuiteStartedFormatter.format(for: obj) {
            return testSuiteStarted
        } else if let testCasePassed = self.testCasePassedFormatter.format(for: obj) {
            return testCasePassed
        } else if let testCaseFailed = self.testCaseFailedFormatter.format(for: obj) {
            return testCaseFailed
        } else {
            return nil
        }
    }
}
