//
//  Projects.swift
//  windmill
//
//  Created by Markos Charatzas on 17/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation
import os

typealias ProjectsInputStream = InputStream
typealias ProjectsOutputStream = OutputStream

extension InputStream
{
    class func inputStreamOnProjects() -> ProjectsInputStream {
        return InputStream(url: ApplicationDirectory().file("projects.json").URL)!
    }
    
    func read() -> Array<Project>
    {
        do
        {
            defer {
                self.close()
            }
            
            self.open()
            let object = try JSONSerialization.jsonObject(with: self, options: JSONSerialization.ReadingOptions())
            
            let projects = Array((object as! NSArray)).map(Project.fromDictionary)
            
            return projects
        } catch let error as NSError {
            os_log("%{public}@", log: .default, type: .error, error)
            
            return []
        }
    }
}

extension OutputStream
{
    class func outputStreamOnProjects() -> ProjectsOutputStream {
        return OutputStream(url: ApplicationDirectory().file("projects.json").URL, append: false)!
    }
    
    func write(_ projects: Array<Project>)
    {
        self.open()
        var error : NSError?
        
        JSONSerialization.writeJSONObject(projects.map(Project.toDictionary), to: self, options: JSONSerialization.WritingOptions.prettyPrinted, error:&error)
        
        self.close()
        
        if let error = error {
            os_log("%{errorno}@", log: .default, type: .error, error)
        }
    }

}
