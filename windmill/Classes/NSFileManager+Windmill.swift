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

    var trashDirectoryURL: URL {
        return self.urls(for: .trashDirectory, in: .userDomainMask)[0]
    }
    
    var windmillHomeDirectoryURL: URL  {
        return URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(".windmill")
    }
    
    func buildDirectoryURL(forProject name: String) -> URL {
        return windmillHomeDirectoryURL.appendingPathComponent(name).appendingPathComponent("build")
    }

    func archiveURL(forProject projectName: String, inArchive archiveName: String) -> URL {
        return buildDirectoryURL(forProject: projectName).appendingPathComponent("\(archiveName).xcarchive")
    }

    func archiveInfoURL(forProject projectName: String, inArchive archiveName: String) -> URL {
        return self.archiveURL(forProject: projectName, inArchive: archiveName).appendingPathComponent("Info.plist")
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

    func fileExists(_ filename: String, atURL URL:Foundation.URL) -> Bool {
        return self.fileExists(atPath: (URL.path as NSString).appendingPathComponent(filename))
    }
}
