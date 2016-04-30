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
}

extension NSOutputStream
{
    class func outputStreamOnProjects() -> ProjectsOutputStream {
        return NSOutputStream(URL: ApplicationDirectory().file("projects.json").URL, append: false)!
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

func read(inputStream: ProjectsInputStream) -> Array<Project>
{
    do
    {
      defer {
        inputStream.close()
      }
      
      inputStream.open()
      let object: AnyObject? = try NSJSONSerialization.JSONObjectWithStream(inputStream, options: NSJSONReadingOptions())
        
        let projects = Array((object as! NSArray)).map(Project.fromDictionary)

        return projects
    } catch let error {
        Windmill.logger.log(.ERROR, error)
        
        return []
    }
}

func write(projects: Array<Project>, outputStream: ProjectsOutputStream)
{
    outputStream.open()
    var error : NSError?
    
    NSJSONSerialization.writeJSONObject(projects.map(Project.toDictionary), toStream: outputStream, options: NSJSONWritingOptions.PrettyPrinted, error:&error)
    
    outputStream.close()
    
    print(error)
}