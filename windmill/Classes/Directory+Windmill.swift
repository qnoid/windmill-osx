//
//  Directory+Windmill.swift
//  windmill
//
//  Created by Markos Charatzas on 19/2/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation
import os

public protocol UserLibraryDirectory : DirectoryType
{
    func mobileDeviceProvisioningProfiles() -> DirectoryType
}

public protocol ApplicationSupportDirectory : DirectoryType
{
    func buildResultBundle(at pathComponent: String) -> ResultBundle
}

extension ApplicationSupportDirectory {
    
    public func resultBundleDirectory() -> Directory {
        let directory = self.fileManager.directory(self.URL.appendingPathComponent("ResultBundle"))
        
        directory.create()
        
        return directory
    }
    
    fileprivate func resultBundleURL(name: String, at pathComponent: String) -> URL {
        let directory = self.fileManager.directory(self.resultBundleDirectory().URL.appendingPathComponent(name).appendingPathComponent(pathComponent))
        
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

public protocol ApplicationCachesDirectory : DirectoryType
{
    func sourcesURL() -> URL
    func respositoryDirectory(at pathComponent: String) -> RepositoryDirectory
    func derivedData(at pathComponent: String) -> DerivedDataDirectory
}

extension ApplicationCachesDirectory {
    
    public func sourcesURL() -> URL {
        let directory = self.fileManager.directory(self.URL.appendingPathComponent("Sources"))
        
        directory.create()
        
        return directory.URL
    }
    
    public func respositoryDirectory(at pathComponent: String) -> RepositoryDirectory {
        
        let directory = self.fileManager.directory(self.sourcesURL().appendingPathComponent(pathComponent))
        
        return directory
    }
    
    public func derivedData(at pathComponent: String) -> DerivedDataDirectory {
        let directory = self.fileManager.directory(self.URL.appendingPathComponent("DerivedData").appendingPathComponent(pathComponent))
        
        directory.create(withIntermediateDirectories: true)
        
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
    func appBundle(derivedData: DerivedDataDirectory, name: String) -> AppBundle
    func archive(name: String) -> Archive
    func appBundle(archive: Archive, name: String) -> AppBundle
    func distributionSummary() -> DistributionSummary
    func manifest() -> Manifest
    func metadata(project: Project, location: Project.Location, configuration: Configuration, applicationProperties: AppBundle.Info) -> Export.Metadata
    func export(name: String) -> Export
}

extension ProjectDirectory {

    public func logDirectoryURL() -> URL {

        let directory = self.fileManager.directory(self.URL.appendingPathComponent("log"))

        directory.create()
        
        return directory.URL
    }
    
    public func log(name: String) -> URL {
        let log = logDirectoryURL().appendingPathComponent("\(name).log")
        
        self.fileManager.createFile(atPath: log.path, contents: nil, attributes: nil)
        
        return log
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

    public func appBundle(derivedData: DerivedDataDirectory, name: String) -> AppBundle {
        
        let appBundleURL = derivedData.URL.appendingPathComponent("Build/Products/Debug-iphonesimulator/\(name).app")
        let appBundleInfoURL = appBundleURL.appendingPathComponent("Info.plist")
        
        return AppBundle(url: appBundleURL, info: AppBundle.Info.make(at: appBundleInfoURL))
    }

    public func appBundle(archive: Archive, name: String) -> AppBundle {
        
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
    
    public func metadata(project: Project, location: Project.Location, configuration: Configuration, applicationProperties: AppBundle.Info) -> Export.Metadata {
        let buildSettings = self.buildSettings()
        let distributionSummary = self.distributionSummary()

        return Export.Metadata(project: project, buildSettings: buildSettings.for(project: project.name), location: location, distributionSummary: distributionSummary, configuration: configuration, applicationProperties: applicationProperties)
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
