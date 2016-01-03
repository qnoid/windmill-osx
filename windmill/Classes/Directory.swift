//
//  Directory.swift
//  windmill
//
//  Created by Markos Charatzas on 13/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation

public protocol DirectoryType
{
    var URL : NSURL { get }
    
    func file(filename: String) -> DirectoryType
    
    func fileExists(filename: String) -> Bool
    
    func traverse(pathComponent: PathComponent) -> DirectoryType
    
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
    let applicationName = NSBundle.mainBundle().CFBundleName()
    let applicationDirectoryPathComponent = PathComponent(rawValue: "\(applicationName)")!
    let applicationDirectory = NSFileManager.defaultManager().userApplicationSupportDirectoryView().directory.traverse(applicationDirectoryPathComponent)
    
    let created = applicationDirectory.create()
    
    Windmill.logger.log(.DEBUG, "Was <windmill> application directory created?: \(created)")

    return applicationDirectory
}

public struct Directory : DirectoryType, UserLibraryDirectory, ApplicationSupportDirectory
{
    static let logger : ConsoleLog = ConsoleLog()

    public let URL : NSURL
    let fileManager : NSFileManager
    
    public func file(filename: String) -> DirectoryType
    {
        let URLForFilename = NSURL(fileURLWithPath: (self.URL.path! as NSString).stringByAppendingPathComponent(filename), isDirectory: false)
        
        return Directory(URL:URLForFilename, fileManager: self.fileManager)
    }
    
    public func fileExists(filename: String) -> Bool {
        return self.fileManager.fileExistsAtPath((self.URL.path! as NSString).stringByAppendingPathComponent(filename))
    }
    
    public func traverse(pathComponent: PathComponent) -> DirectoryType
    {
        let path = (self.URL.path! as NSString).stringByExpandingTildeInPath
        
        let URLForPathComponent = NSURL(fileURLWithPath: (path as NSString).stringByAppendingPathComponent(pathComponent.rawValue), isDirectory: true)
        
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
            try self.fileManager.createDirectoryAtURL(self.URL, withIntermediateDirectories:false, attributes: nil)
            created = true
        } catch let error as NSError {
            Directory.logger.log(.ERROR, error)
            created = false
        }
        
        
        return created
    }
}