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
    var fileManager : FileManager { get }
    var URL : Foundation.URL { get }
    
    func file(_ filename: String) -> Self
    
    func fileExists(_ filename: String) -> Bool
    
    func traverse(_ pathComponent: PathComponent) -> Self
    
    /**
    Creates the directory that returned as part of calling #traverse:
    
    - returns: true if created, false otherwise
    */
    @discardableResult func create() -> Bool
    
    @discardableResult func create(withIntermediateDirectories: Bool) -> Bool
}

public struct Directory : DirectoryType, UserLibraryDirectory, ApplicationSupportDirectory, ApplicationCachesDirectory, WindmillHomeDirectory, ProjectHomeDirectory, ProjectSourceDirectory
{
    public let URL : Foundation.URL
    public let fileManager : FileManager
    
    public func file(_ filename: String) -> Directory
    {
        let URLForFilename = Foundation.URL(fileURLWithPath: (self.URL.path as NSString).appendingPathComponent(filename), isDirectory: false)
        
        return Directory(URL:URLForFilename, fileManager: self.fileManager)
    }
    
    public func fileExists(_ filename: String) -> Bool {
        return self.fileManager.fileExists(atPath: (self.URL.path as NSString).appendingPathComponent(filename))
    }
    
    public func traverse(_ pathComponent: PathComponent) -> Directory
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
        do {
            try self.fileManager.createDirectory(at: self.URL, withIntermediateDirectories:withIntermediateDirectories, attributes: nil)
            return true
        } catch let error as CocoaError {
            
            if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? POSIXError, underlyingError.code == POSIXError.EEXIST {
                return false
            }

            let log = OSLog(subsystem: "io.windmill.windmill", category: "filemanager")
            os_log("%{public}@", log: log, type: .debug, error.localizedDescription)
            return false
        } catch let error as NSError {
            let log = OSLog(subsystem: "io.windmill.windmill", category: "filemanager")
            os_log("%{public}@", log: log, type: .debug, error)
            return false
        }
    }
}
