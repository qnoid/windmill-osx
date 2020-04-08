//
//  Directory+Windmill.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 19/2/18.
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
import os

extension DirectoryType {

    func directory(at pathComponent: String) -> Directory {
        
        let directory = self.fileManager.directory(self.URL.appendingPathComponent(pathComponent))
        
        directory.create()
        
        return directory
    }
    
    public func builds() -> Directory {
        let directory = self.fileManager.directory(self.URL.appendingPathComponent("Builds"))
        
        directory.create()
        
        return directory
    }
}


public protocol UserLibraryDirectory : DirectoryType
{
    func mobileDeviceProvisioningProfiles() -> DirectoryType
}

public protocol ApplicationSupportDirectory : DirectoryType
{
    func resultBundleDirectory(at: Directory?) -> ResultBundleDirectory
}

public protocol ResultBundleDirectory : DirectoryType {
    
    func buildResultBundle(at name: String) -> ResultBundle
    func testResultBundle(at name: String) -> ResultBundle
    func archiveResultBundle(at name: String) -> ResultBundle
    func exportResultBundle(at name: String) -> ResultBundle
}

extension ResultBundleDirectory {
    
    func resultBundleURL(name: String, at pathComponent: String) -> URL {
        let directory = self.fileManager.directory(self.URL.appendingPathComponent(name).appendingPathComponent(pathComponent))
        
        directory.create(withIntermediateDirectories: true)
        
        do {
            try self.fileManager.removeItem(at: directory.URL.appendingPathComponent("\(name).bundle"))
        } catch let error as NSError {
            os_log("%{public}@", log:.default, type: .debug, error)
        }
        
        return directory.URL.appendingPathComponent("\(name).bundle")
    }

    public func buildResultBundle(at name: String) -> ResultBundle {
        
        let buildResultBundleURL = self.resultBundleURL(name: name, at: "build")
        let bundleResultInfoURL = buildResultBundleURL.appendingPathComponent("Info.plist")
        
        return ResultBundle.make(at: buildResultBundleURL, info: ResultBundle.Info.make(at: bundleResultInfoURL))
    }
    
    public func testResultBundle(at name: String) -> ResultBundle {
        
        let testResultBundleURL = self.resultBundleURL(name: name, at: "test")
        let testResultInfoURL = testResultBundleURL.appendingPathComponent("Info.plist")
        let testSummariesURL = testResultBundleURL.appendingPathComponent("TestSummaries.plist")
        
        return ResultBundle.make(at: testResultBundleURL, info: ResultBundle.Info.make(at: testResultInfoURL), testSummaries: TestSummaries.make(at: testSummariesURL))
    }
    
    public func archiveResultBundle(at name: String) -> ResultBundle {
        
        let archiveResultBundleURL = self.resultBundleURL(name: name, at: "archive")
        let archiveResultInfoURL = archiveResultBundleURL.appendingPathComponent("Info.plist")
        
        return ResultBundle.make(at: archiveResultBundleURL, info: ResultBundle.Info.make(at: archiveResultInfoURL))
    }
    
    public func exportResultBundle(at name: String) -> ResultBundle {
        
        let archiveResultBundleURL = self.resultBundleURL(name: name, at: "export")
        let archiveResultInfoURL = archiveResultBundleURL.appendingPathComponent("Info.plist")
        
        return ResultBundle.make(at: archiveResultBundleURL, info: ResultBundle.Info.make(at: archiveResultInfoURL))
    }
}

extension ApplicationSupportDirectory {
    
    public func resultBundleDirectory(at: Directory? = nil) -> ResultBundleDirectory {
        
        let location = at?.URL ?? self.URL

        let directory = self.fileManager.directory(location.appendingPathComponent("ResultBundle"))
        
        directory.create()
        
        return directory
    }
}

public protocol ApplicationCachesDirectory : DirectoryType
{
    func sources(at: Directory?) -> Directory
    func respositoryDirectory(at: Directory?, pathComponent: String) -> RepositoryDirectory
    func derivedData(at: Directory?) -> Directory
    func derivedData(at: Directory?, pathComponent: String) -> DerivedDataDirectory
}

extension ApplicationCachesDirectory {
    
    public func sources(at: Directory? = nil) -> Directory {
        
        let location = at?.URL ?? self.URL

        let directory = self.fileManager.directory(location.appendingPathComponent("Sources"))
        
        directory.create()
        
        return directory
    }
    
    /**
     
     at: must exist
    */
    public func respositoryDirectory(at: Directory? = nil, pathComponent: String) -> RepositoryDirectory {
        
        let location = at?.URL ?? self.sources().URL
        
        return self.fileManager.directory( location.appendingPathComponent(pathComponent))
    }
    
    public func derivedData(at: Directory? = nil) -> Directory {
        let location = at?.URL ?? self.URL
        
        let directory = self.fileManager.directory(location.appendingPathComponent("DerivedData"))
        
        directory.create()
        
        return directory
    }
    
    public func derivedData(at: Directory? = nil, pathComponent: String) -> DerivedDataDirectory {
        
        let location = at?.URL ?? self.derivedData().URL

        let directory = self.fileManager.directory(location.appendingPathComponent(pathComponent))
        
        directory.create()
        
        return directory
    }
}

public protocol RepositoryDirectory: DirectoryType {
    func location(project: Project) -> Project.Location
}

extension RepositoryDirectory {
    
    public func location(project: Project) -> Project.Location {
        return Project.Location(project: project, url: self.URL)
    }
}

public protocol DerivedDataDirectory: DirectoryType {
    
    func derivedAppBundle(name: String) -> AppBundle
}

extension DerivedDataDirectory {
    
    public func derivedAppBundle(name: String) -> AppBundle {
        
        let appBundleURL = self.URL.appendingPathComponent("Build/Products/Debug-iphonesimulator/\(name).app")
        let appBundleInfoURL = appBundleURL.appendingPathComponent("Info.plist")
        
        return AppBundle(url: appBundleURL, info: AppBundle.Info.make(at: appBundleInfoURL))
    }
}

public protocol WindmillDirectory: DirectoryType {
    
    func directory(for project: Project, create: Bool) -> ProjectDirectory
}

extension WindmillDirectory {
    
    public func directory(for project: Project, create: Bool = true) -> ProjectDirectory {
        
        let directory = self.fileManager.directory(self.URL.appendingPathComponent(project.name))
        
        if create {
            directory.create()
        }
        
        return directory
    }
}

public protocol ProjectDirectory : DirectoryType
{
    
    func log(name: String) -> URL
    func configuration() -> Project.Configuration
    func buildSettings() -> BuildSettings
    func devices() -> Devices
    func appBundle(name: String) -> AppBundle
    func archive(name: String) -> Archive
    func archivedAppBundle(archive: Archive, name: String) -> AppBundle
    func distributionSummary() -> DistributionSummary
    func manifest() -> Manifest
    func metadata(project: Project, projectAt: Project.Location, configuration: Configuration, applicationProperties: AppBundle.Info) -> Export.Metadata
    func export(name: String) -> Export
}

extension ProjectDirectory {

    public func logDirectoryURL() -> URL {

        let directory = self.fileManager.directory(self.URL.appendingPathComponent("log"))

        directory.create(withIntermediateDirectories: true)
        
        return directory.URL
    }
    
    public func log(name: String) -> URL {
        return logDirectoryURL().appendingPathComponent("\(name).log")
    }
    
    public func buildDirectoryURL() -> URL {
        let directory = self.fileManager.directory(self.URL.appendingPathComponent("build"))
        
        directory.create()
        
        return directory.URL
    }
    
    public func testDirectoryURL() -> URL {
        let directory = self.fileManager.directory(self.URL.appendingPathComponent("test"))
        
        directory.create()
        
        return directory.URL
    }
    
    func archiveDirectoryURL() -> URL {
        let directory = self.fileManager.directory(self.URL.appendingPathComponent("archive"))
        
        directory.create()
        
        return directory.URL
    }
    
    func exportDirectoryURL() -> URL {
        let directory = self.fileManager.directory(self.URL.appendingPathComponent("export"))
        
        directory.create()
        
        return directory.URL
    }
    
    
    func pollURL() -> URL {
        let directory = self.fileManager.directory(self.URL.appendingPathComponent("poll"))
        
        directory.create()
        
        return directory.URL
    }
    
    public func configuration() -> Project.Configuration {
        let url = self.URL.appendingPathComponent("configuration.json")
        
        return Project.Configuration.make(at: url)
    }
    
    public func buildSettings() -> BuildSettings {
        let url = self.buildDirectoryURL().appendingPathComponent("settings.json")
        
        return BuildSettings.make(at: url)
    }
    
    public func devices() -> Devices {
        let url = self.URL.appendingPathComponent("devices.json")
        
        return Devices.make(at: url)
    }
    
    public func archive(name: String) -> Archive {
        let archiveURL = archiveDirectoryURL().appendingPathComponent("\(name).xcarchive")
        let archiveInfoURL = archiveURL.appendingPathComponent("Info.plist")
        
        return Archive(url: archiveURL, info: Archive.Info.make(at: archiveInfoURL))
    }
    
    public func appBundle(name: String) -> AppBundle {
        let appBundleURL = buildDirectoryURL().appendingPathComponent("\(name).app")
        let appBundleInfoURL = appBundleURL.appendingPathComponent("Info.plist")
        
        return AppBundle(url: appBundleURL, info: AppBundle.Info.make(at: appBundleInfoURL))
    }

    public func archivedAppBundle(archive: Archive, name: String) -> AppBundle {
        
        let appBundleURL = archive.url.appendingPathComponent("Products/Applications/\(name)")
        let appBundleInfoURL = appBundleURL.appendingPathComponent("Info.plist")

        return AppBundle(url: appBundleURL, info: AppBundle.Info.make(at: appBundleInfoURL))
    }

    public func distributionSummary() -> DistributionSummary {
        let url = self.exportDirectoryURL().appendingPathComponent("DistributionSummary.plist")
        
        return DistributionSummary.make(at: url)
    }
    
    public func manifest() -> Manifest {
        let url = self.exportDirectoryURL().appendingPathComponent("manifest.plist")
        
        return Manifest.make(at: url)
    }
    
    public func metadata(project: Project, projectAt: Project.Location, configuration: Configuration, applicationProperties: AppBundle.Info) -> Export.Metadata {
        let buildSettings = self.buildSettings()
        let distributionSummary = self.distributionSummary()

        return Export.Metadata(project: project, buildSettings: buildSettings, projectAt: projectAt, distributionSummary: distributionSummary, configuration: configuration, applicationProperties: applicationProperties)
    }
    
    public func export(name: String) -> Export {
        let url = exportDirectoryURL().appendingPathComponent("\(name).ipa")
        
        return Export.make(at: url, manifest: manifest(), distributionSummary: distributionSummary())
    }
}

extension Directory {
    
    struct Windmill {
        
        static func ApplicationSupportDirectory() -> ApplicationSupportDirectory
        {
            let applicationName = Bundle.main.bundleIdentifier!
            let applicationDirectoryPathComponent = PathComponent(rawValue: "\(applicationName)")!
            let applicationDirectory = FileManager.default.userApplicationSupportDirectoryView().directory.traverse(applicationDirectoryPathComponent)
            
            applicationDirectory.create()
            
            return applicationDirectory
        }
        
        static func ApplicationCachesDirectory() -> ApplicationCachesDirectory {
            
            let applicationName = Bundle.main.bundleIdentifier!
            let applicationDirectoryPathComponent = PathComponent(rawValue: "\(applicationName)")!
            let applicationDirectory = FileManager.default.userApplicationCachesDirectoryView().directory.traverse(applicationDirectoryPathComponent)
            
            applicationDirectory.create()
            
            return Directory(URL: applicationDirectory.URL, fileManager: FileManager.default)
        }
    }
}
