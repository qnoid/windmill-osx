//
//  NSFileManager+WindmillFileManager.swift
//  windmill
//
//  Created by Markos Charatzas on 12/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation
import os

public extension FileManager
{
    public typealias UserLibraryDirectoryView = (URL:URL, directory:UserLibraryDirectory)
    public typealias UserApplicationSupportDirectoryView = (URL:URL, directory:ApplicationSupportDirectory)

    var trashDirectoryURL: URL {
        return self.urls(for: .trashDirectory, in: .userDomainMask)[0]
    }

    var windmillHomeDirectory: WindmillHomeDirectory  {
        
        let url = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(".windmill")
        
        return Directory(URL: url, fileManager: self)
    }

    /**
     - returns: ~/Library/Caches/io.windmill.windmill/{name}
    */
    func cachesDirectoryURL(forProject name: String) -> URL {
        let applicationCachesDirectory = Directory.Windmill.ApplicationCachesDirectory().traverse(PathComponent(rawValue: name)!)
        return applicationCachesDirectory.URL
    }

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
    
    func userApplicationCachesDirectoryView() -> UserApplicationSupportDirectoryView
    {
        let URLForUserApplicationCachesDirectory = self.urls(for: .cachesDirectory, in:.userDomainMask)[0]
        
        return (URL: URLForUserApplicationCachesDirectory, directory:directory(URLForUserApplicationCachesDirectory))
    }


    func fileExists(_ filename: String, atURL URL:Foundation.URL) -> Bool {
        return self.fileExists(atPath: (URL.path as NSString).appendingPathComponent(filename))
    }
}
