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
    typealias UserLibraryDirectoryView = (URL:URL, directory:UserLibraryDirectory)
    typealias UserApplicationSupportDirectoryView = (URL:URL, directory:ApplicationSupportDirectory)

    var trashDirectoryURL: URL {
        return self.urls(for: .trashDirectory, in: .userDomainMask).first!
    }

    var userDirectoryURL: URL {
        return self.urls(for: .userDirectory, in: .userDomainMask).first!
    }

    var desktopDirectoryURL: URL {
        return self.urls(for: .desktopDirectory, in: .userDomainMask).first!
    }

    var windmillHomeDirectory: WindmillHomeDirectory  {
        
        let url = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(".windmill")
        
        let directory = Directory(URL: url, fileManager: self)
        
        directory.create()
        
        return directory
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
