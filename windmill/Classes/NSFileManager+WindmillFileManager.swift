//
//  NSFileManager+WindmillFileManager.swift
//  windmill
//
//  Created by Markos Charatzas on 12/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation

public extension NSFileManager
{
    public typealias UserLibraryDirectoryView = (URL:NSURL, directory:UserLibraryDirectory)
    public typealias UserApplicationSupportDirectoryView = (URL:NSURL, directory:ApplicationSupportDirectory)
    
    func directory(URL:NSURL) -> Directory {
    return Directory(URL: URL, fileManager: self)
    }
    
    func userLibraryDirectoryView() -> UserLibraryDirectoryView
    {
        let URLForUserLibraryDirectory = self.URLForDirectory(.LibraryDirectory, inDomain:NSSearchPathDomainMask.UserDomainMask, appropriateForURL:nil, create:false, error:nil)!
        
        return (URL: URLForUserLibraryDirectory, directory:directory(URLForUserLibraryDirectory))
    }
    
    func userApplicationSupportDirectoryView() -> UserApplicationSupportDirectoryView
    {
        let URLForUserApplicationSupportDirectory = self.URLForDirectory(.ApplicationSupportDirectory, inDomain:NSSearchPathDomainMask.UserDomainMask, appropriateForURL:nil, create:false, error:nil)!
        
        return (URL: URLForUserApplicationSupportDirectory, directory:directory(URLForUserApplicationSupportDirectory))
    }

    func fileExists(filename: String, atURL URL:NSURL) -> Bool {
        return self.fileExistsAtPath(URL.path!.stringByAppendingPathComponent(filename))
    }
}