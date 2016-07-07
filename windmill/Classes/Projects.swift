//
//  Projects.swift
//  windmill
//
//  Created by Markos Charatzas on 17/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation

typealias ProjectsInputStream = NSInputStream
typealias ProjectsOutputStream = NSOutputStream

extension NSInputStream
{
    class func inputStreamOnProjects() -> ProjectsInputStream {
        return NSInputStream(URL: ApplicationDirectory().file("projects.json").URL)!
    }
    
    func read() -> Array<Project>
    {
        do
        {
            defer {
                self.close()
            }
            
            self.open()
            let object: AnyObject? = try NSJSONSerialization.JSONObjectWithStream(self, options: NSJSONReadingOptions())
            
            let projects = Array((object as! NSArray)).map(Project.fromDictionary)
            
            return projects
        } catch let error {
            Windmill.logger.log(.ERROR, error)
            
            return []
        }
    }
}

extension NSOutputStream
{
    class func outputStreamOnProjects() -> ProjectsOutputStream {
        return NSOutputStream(URL: ApplicationDirectory().file("projects.json").URL, append: false)!
    }
    
    func write(projects: Array<Project>)
    {
        self.open()
        var error : NSError?
        
        NSJSONSerialization.writeJSONObject(projects.map(Project.toDictionary), toStream: self, options: NSJSONWritingOptions.PrettyPrinted, error:&error)
        
        self.close()
        
        print(error)
    }

}

extension NSFileManager {
    
    var foo: NSURL {
        return try! self.URLForDirectory(.UserDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
    }
    
    var windmill: String {
        return "\(NSHomeDirectory())/.windmill/"
    }

}