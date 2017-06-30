//
//  NSFileManager+WindmillFileManager.swift
//  windmill
//
//  Created by Markos Charatzas on 12/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation

public extension FileManager
{
    public typealias UserLibraryDirectoryView = (URL:URL, directory:UserLibraryDirectory)
    public typealias UserApplicationSupportDirectoryView = (URL:URL, directory:ApplicationSupportDirectory)
    
    func directory(_ URL:Foundation.URL) -> Directory {
    return Directory(URL: URL, fileManager: self)
    }
    
    func userLibraryDirectoryView() -> UserLibraryDirectoryView
    {
        let URLForUserLibraryDirectory = try! self.url(for: .libraryDirectory, in:FileManager.SearchPathDomainMask.userDomainMask, appropriateFor:nil, create:false)
        
        return (URL: URLForUserLibraryDirectory, directory:directory(URLForUserLibraryDirectory))
    }
    
    func userApplicationSupportDirectoryView() -> UserApplicationSupportDirectoryView
    {
        let URLForUserApplicationSupportDirectory = try! self.url(for: .applicationSupportDirectory, in:FileManager.SearchPathDomainMask.userDomainMask, appropriateFor:nil, create:false)
        
        return (URL: URLForUserApplicationSupportDirectory, directory:directory(URLForUserApplicationSupportDirectory))
    }

    func fileExists(_ filename: String, atURL URL:Foundation.URL) -> Bool {
        return self.fileExists(atPath: (URL.path as NSString).appendingPathComponent(filename))
    }
}
