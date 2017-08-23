//
//  Archive.swift
//  windmill
//
//  Created by Markos Charatzas on 18/08/2017.
//  Copyright © 2017 qnoid.com. All rights reserved.
//

import Foundation

struct Archive {
    
    struct Info {
        
        static func parse(url: URL) throws -> Info {
            let info = try PropertyListSerialization.propertyList(from: Data(contentsOf: url), options: [], format: nil) as! [String: Any]
            
            let applicationProperties = info["ApplicationProperties"] as! [String: Any]
            
            let name = info["Name"] as? String ?? ""
            let bundleShortVersion = applicationProperties["CFBundleShortVersionString"] as? String ?? ""
            let bundleVersion = applicationProperties["CFBundleVersion"] as? String ?? ""
        
            let creationDate = info["CreationDate"] as? Date

            return Info(name: name, bundleShortVersion: bundleShortVersion, bundleVersion: bundleVersion, creationDate: creationDate)
        }
        
        let name: String
        let bundleShortVersion: String
        let bundleVersion: String
        let creationDate: Date?
    }
    
    static func make(forProject project: Project, name: String) throws -> Archive {
        let archiveInfoURL = FileManager.default.archiveInfoURL(forProject: project.name, inArchive: name)
        
        let info = try Archive.Info.parse(url: archiveInfoURL)
        let archiveURL = FileManager.default.archiveURL(forProject: project.name, inArchive: name)
        
        return Archive(url: archiveURL, info: info)
    }
    
    let url: URL
    let info: Info
}

extension Archive {
    
    func name(dateFormatter: DateFormatter) -> String {
        return "\(self.info.name) \(dateFormatter.string(from: self.info.creationDate ?? Date())).xcarchive"
    }
    
    func xcodeArchivesURL(url: URL = FileManager.default.xcodeArchivesURL, dateFormatter: DateFormatter) -> URL {
        return url.appendingPathComponent(dateFormatter.string(from: self.info.creationDate ?? Date()))
    }
}
