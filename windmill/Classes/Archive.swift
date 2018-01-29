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
        
        static func make(for project:Project) -> Info {
            let url = FileManager.default.archiveInfoURL(forProject: project.name, inArchive: project.scheme)
            
            return Info(metadata: MetadataPlistEncoded(url: url))
        }

        let metadata: Metadata

        var applicationProperties: [String: String]? {
            let applicationProperties:[String: String]? = metadata["ApplicationProperties"]
            
            return applicationProperties
        }
        
        var name: String {
            let name: String? = metadata["Name"]
            
            return name ?? ""
        }

        var creationDate: Date? {
            let creationDate: Date? = metadata["CreationDate"]
            
            return creationDate
        }

        var bundleShortVersion: String {
            let bundleShortVersion: String? = applicationProperties?["CFBundleShortVersionString"]
            
            return bundleShortVersion ?? ""
        }
        
        var bundleVersion: String {
            let bundleVersion: String? = applicationProperties?["CFBundleVersion"]
            
            return bundleVersion ?? ""
        }
        
        var signingIdentity: String {
            let signingIdentity: String? = applicationProperties?["SigningIdentity"]
            
            return signingIdentity  ?? ""
        }
    }
    
    static func make(forProject project: Project, name: String) -> Archive {
        
        let info = Archive.Info.make(for: project)
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
        
        let xcodeArchivesURL = url.appendingPathComponent(dateFormatter.string(from: self.info.creationDate ?? Date()))
        
        let directory = Directory(URL: xcodeArchivesURL, fileManager: FileManager.default)
        directory.create()

        return xcodeArchivesURL
    }
}
