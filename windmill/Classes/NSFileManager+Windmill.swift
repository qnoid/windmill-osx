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

    var windmillHomeDirectoryURL: URL  {
        return URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(".windmill")
    }
    
    /**
     - returns: ~/Library/Caches/io.windmill.windmill/{name}
    */
    func cachesDirectoryURL(forProject name: String) -> URL {
        let applicationCachesDirectory = ApplicationCachesDirectory().traverse(PathComponent(rawValue: name)!)
        return applicationCachesDirectory.URL
    }

    func buildDirectoryURL(forProject name: String) -> URL {
        let directory = self.directory(windmillHomeDirectoryURL.appendingPathComponent(name).appendingPathComponent("build"))
        directory.create(withIntermediateDirectories: true)
        return directory.URL
    }

    func testDirectoryURL(forProject name: String) -> URL {
        let directory = self.directory(windmillHomeDirectoryURL.appendingPathComponent(name).appendingPathComponent("test"))
        directory.create(withIntermediateDirectories: true)
        return directory.URL
    }
    
    func exportDirectoryURL(forProject name: String) -> URL {
        return windmillHomeDirectoryURL.appendingPathComponent(name).appendingPathComponent("export")
    }

    func archiveDirectoryURL(forProject name: String) -> URL {
        return windmillHomeDirectoryURL.appendingPathComponent(name).appendingPathComponent("archive")
    }

    func pollDirectoryURL(forProject name: String) -> URL {
        let directory = self.directory(windmillHomeDirectoryURL.appendingPathComponent(name).appendingPathComponent("poll"))
        directory.create()
        return directory.URL
    }

    func archiveURL(forProject projectName: String, inArchive archiveName: String) -> URL {
        return archiveDirectoryURL(forProject: projectName).appendingPathComponent("\(archiveName).xcarchive")
    }

    func archiveInfoURL(forProject projectName: String, inArchive archiveName: String) -> URL {
        return self.archiveURL(forProject: projectName, inArchive: archiveName).appendingPathComponent("Info.plist")
    }

    func exportURL(forProject project: Project) -> URL {
        return exportDirectoryURL(forProject: project.name).appendingPathComponent("\(project.scheme).ipa")
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
