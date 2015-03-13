//
//  Directory.swift
//  windmill
//
//  Created by Markos Charatzas on 13/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation

protocol DirectoryType
{
    func fileExists(filename: String) -> Bool
    func traverse(pathComponent: PathComponent) -> DirectoryType
}

protocol UserLibraryDirectory
{
    func mobileDeviceProvisioningProfiles() -> DirectoryType
}

struct Directory : DirectoryType, UserLibraryDirectory
{
    let URL : NSURL
    let fileManager : NSFileManager
    
    func fileExists(filename: String) -> Bool {
        return self.fileManager.fileExistsAtPath(self.URL.path!.stringByAppendingPathComponent(filename))
    }
    
    func traverse(pathComponent: PathComponent) -> DirectoryType
    {
        let path = self.URL.path!.stringByExpandingTildeInPath
        
        let URLForPathComponent = NSURL(fileURLWithPath: path.stringByAppendingPathComponent(pathComponent.rawValue), isDirectory: true)!
        
        return Directory(URL: URLForPathComponent, fileManager: self.fileManager)
    }
    
    func mobileDeviceProvisioningProfiles() -> DirectoryType {
        return self.traverse(PathComponent.MobileDeviceProvisioningProfiles)
    }
}