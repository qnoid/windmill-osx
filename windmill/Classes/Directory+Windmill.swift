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
    
}

public protocol ApplicationCachesDirectory : DirectoryType
{
    func projectSourceDirectory(at pathComponent: String) -> ProjectSourceDirectory
}

extension ApplicationCachesDirectory {
    
    public func projectSourceDirectory(at pathComponent: String) -> ProjectSourceDirectory {
        return projectSourceDirectory(at: pathComponent, create: true)
    }
    
    public func projectSourceDirectory(at pathComponent: String, create: Bool = true) -> ProjectSourceDirectory {
        
        let directory = self.fileManager.directory(self.URL.appendingPathComponent(pathComponent))
        
        if create {
            directory.create()
        }
        
        return directory
    }
}

public protocol ProjectSourceDirectory: DirectoryType {
    
    func remove() -> Bool
}

extension ProjectSourceDirectory {
    
    public func remove() -> Bool {
        
        do {
            try FileManager.default.removeItem(at: self.URL)
            return true
        } catch let error as CocoaError {
            guard let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? POSIXError, underlyingError.code == POSIXError.ENOTEMPTY else {
                return false
            }
            
            try? FileManager.default.removeItem(at: self.URL)
            return true
        } catch let error as NSError {
            os_log("%{public}@", log:.default, type: .error, error)
            return false
        }
        
    }
}

public protocol WindmillHomeDirectory: DirectoryType {
    
    func projectHomeDirectory(at pathComponent: String, create: Bool) -> ProjectHomeDirectory
}

extension WindmillHomeDirectory {
    
    public func projectHomeDirectory(at pathComponent: String, create: Bool = true) -> ProjectHomeDirectory {
        
        let directory = self.fileManager.directory(self.URL.appendingPathComponent(pathComponent))
        
        if create {
            directory.create()
        }
        
        return directory
    }
}

public protocol ProjectHomeDirectory : DirectoryType
{
    func configuration() -> Project.Configuration
    func buildSettings() -> BuildSettings
    func devices() -> Devices
    func archive(name: String) -> Archive
    func appBundle(archive: Archive, name: String) -> AppBundle
    func distributionSummary() -> Export.DistributionSummary
    func manifest() -> Export.Manifest
    func export(name: String) -> Export
    
    func removeDerivedData() -> Bool
}

extension ProjectHomeDirectory {
    
    public func derivedDataURL() -> URL {
        let directory = self.fileManager.directory(self.URL.appendingPathComponent("DerivedData"))
        
        directory.create()
        
        return directory.URL
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
        let url = self.testDirectoryURL().appendingPathComponent("settings.json")
        
        return Devices.make(at: url)
    }
    
    public func archive(name: String) -> Archive {
        let archiveURL = archiveDirectoryURL().appendingPathComponent("\(name).xcarchive")
        let archiveInfoURL = archiveURL.appendingPathComponent("Info.plist")
        
        return Archive(url: archiveURL, info: Archive.Info.make(at: archiveInfoURL))
    }
    
    public func appBundle(archive: Archive, name: String) -> AppBundle {
        
        let appBundleURL = archive.url.appendingPathComponent("Products/Applications/\(name).app")
        let info = AppBundle.Info.make(appBundleURL: appBundleURL)
        
        return AppBundle(url: appBundleURL, info: info)
    }

    public func distributionSummary() -> Export.DistributionSummary {
        let url = self.exportDirectoryURL().appendingPathComponent("DistributionSummary.plist")
        
        return Export.DistributionSummary.make(at: url)
    }
    
    public func manifest() -> Export.Manifest {
        let url = self.exportDirectoryURL().appendingPathComponent("manifest.plist")
        
        return Export.Manifest.make(at: url)
    }
    
    public func export(name: String) -> Export {
        let url = exportDirectoryURL().appendingPathComponent("\(name).ipa")
        
        return Export.make(at: url, manifest: manifest(), distributionSummary: distributionSummary())
    }
    
    public func removeDerivedData() -> Bool {
        do {
            try FileManager.default.removeItem(at: derivedDataURL())
            return true
        } catch let error as NSError {
            os_log("%{public}@", log:.default, type: .error, error)
            return false
        }
    }
}

extension Directory {
    
    struct Windmill {
        
        static func ApplicationDirectory() -> DirectoryType
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
