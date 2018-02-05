//
//  Directory.swift
//  windmill
//
//  Created by Markos Charatzas on 13/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation
import os

public protocol DirectoryType
{
    var URL : Foundation.URL { get }
    
    func file(_ filename: String) -> DirectoryType
    
    func fileExists(_ filename: String) -> Bool
    
    func traverse(_ pathComponent: PathComponent) -> DirectoryType
    
    /**
    Creates the directory that returned as part of calling #traverse:
    
    - returns: true if created, false otherwise
    */
    @discardableResult func create() -> Bool
    
    @discardableResult func create(withIntermediateDirectories: Bool) -> Bool
}

public protocol UserLibraryDirectory : DirectoryType
{
    func mobileDeviceProvisioningProfiles() -> DirectoryType
}

public protocol ApplicationSupportDirectory : DirectoryType
{
    
}

func ApplicationDirectory() -> DirectoryType
{
    let applicationName = Bundle.main.bundleIdentifier!
    let applicationDirectoryPathComponent = PathComponent(rawValue: "\(applicationName)")!
    let applicationDirectory = FileManager.default.userApplicationSupportDirectoryView().directory.traverse(applicationDirectoryPathComponent)
    
    let created = applicationDirectory.create()
    
    os_log("%{public}@", log: .default, type: .debug, "Was <windmill> application directory created?: \(created)")

    return applicationDirectory
}

public func ApplicationCachesDirectory() -> DirectoryType
{
    let applicationName = Bundle.main.bundleIdentifier!
    let applicationDirectoryPathComponent = PathComponent(rawValue: "\(applicationName)")!
    let applicationDirectory = FileManager.default.userApplicationCachesDirectoryView().directory.traverse(applicationDirectoryPathComponent)
    
    let created = applicationDirectory.create()
    
    let log = OSLog(subsystem: "io.windmill.windmill", category: "filemanager")
    os_log("%{public}@", log: log, type: .debug, "Was <windmill> application caches directory created?: \(created)")
    
    return applicationDirectory
}

public struct Directory : DirectoryType, UserLibraryDirectory, ApplicationSupportDirectory
{
    public let URL : Foundation.URL
    let fileManager : FileManager
    
    public func file(_ filename: String) -> DirectoryType
    {
        let URLForFilename = Foundation.URL(fileURLWithPath: (self.URL.path as NSString).appendingPathComponent(filename), isDirectory: false)
        
        return Directory(URL:URLForFilename, fileManager: self.fileManager)
    }
    
    public func fileExists(_ filename: String) -> Bool {
        return self.fileManager.fileExists(atPath: (self.URL.path as NSString).appendingPathComponent(filename))
    }
    
    public func traverse(_ pathComponent: PathComponent) -> DirectoryType
    {
        let path = (self.URL.path as NSString).expandingTildeInPath
        
        let URLForPathComponent = Foundation.URL(fileURLWithPath: (path as NSString).appendingPathComponent(pathComponent.rawValue), isDirectory: true)
        
        return Directory(URL: URLForPathComponent, fileManager: self.fileManager)
    }
    
    /// UserLibraryDirectory
    public func mobileDeviceProvisioningProfiles() -> DirectoryType {
        return self.traverse(PathComponent.MobileDeviceProvisioningProfiles)
    }
    
    /// ApplicationSupportDirectory
    
    @discardableResult public func create() -> Bool {
        return self.create(withIntermediateDirectories: false)
    }
    
    @discardableResult public func create(withIntermediateDirectories: Bool = false) -> Bool
    {
        let created: Bool
        do {
            try self.fileManager.createDirectory(at: self.URL, withIntermediateDirectories:withIntermediateDirectories, attributes: nil)
            created = true
        } catch let error as NSError {
            let log = OSLog(subsystem: "io.windmill.windmill", category: "filemanager")
            os_log("%{public}@", log: log, type: .debug, error)
            created = false
        }
        
        
        return created
    }
}
