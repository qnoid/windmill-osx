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

func read(inputStream: ProjectsInputStream) -> Array<Project>
{
    var error : NSError?
    
    inputStream.open()
    let object: AnyObject? = NSJSONSerialization.JSONObjectWithStream(inputStream, options: NSJSONReadingOptions(), error: &error)
    inputStream.close()
    
    if object == nil{
        return []
    }
    
    let projects = Array((object as! NSArray)).map(Project.fromDictionary)
    
    if let error = error {
        Windmill.logger.log(.ERROR, error)
    }
    
    return projects
}

func write(projects: Array<Project>, outputStream: ProjectsOutputStream)
{
    outputStream.open()
    var error : NSError?
    
    NSJSONSerialization.writeJSONObject(projects.map(Project.toDictionary), toStream: outputStream, options: NSJSONWritingOptions.PrettyPrinted, error:&error)
    
    outputStream.close()
    
    println(error)
}