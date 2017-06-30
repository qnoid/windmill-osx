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
    func create() -> Bool
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
    
    public func create() -> Bool
    {
        let created: Bool
        do {
            try self.fileManager.createDirectory(at: self.URL, withIntermediateDirectories:false, attributes: nil)
            created = true
        } catch let error as NSError {
            os_log("%{public}@", log: .default, type: .error, error)
            created = false
        }
        
        
        return created
    }
}
