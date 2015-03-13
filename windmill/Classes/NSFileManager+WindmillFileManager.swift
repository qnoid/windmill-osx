//
//  NSFileManager+WindmillFileManager.swift
//  windmill
//
//  Created by Markos Charatzas on 12/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation

extension NSFileManager
{
    typealias UserLibraryDirectoryView = (URL:NSURL, directory:UserLibraryDirectory)
    
    func directory(URL:NSURL) -> Directory {
    return Directory(URL: URL, fileManager: self)
    }
    
    func userLibraryDirectoryView() -> UserLibraryDirectoryView
    {
        let URLForUserLibraryDirectory = self.URLForDirectory(.LibraryDirectory, inDomain:NSSearchPathDomainMask.UserDomainMask, appropriateForURL:nil, create:false, error:nil)!
        
        return (URL: URLForUserLibraryDirectory, directory:directory(URLForUserLibraryDirectory))
    }
    
    func fileExists(filename: String, atURL URL:NSURL) -> Bool {
        return self.fileExistsAtPath(URL.path!.stringByAppendingPathComponent(filename))
    }
}