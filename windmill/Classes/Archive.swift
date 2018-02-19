//
//  Archive.swift
//  windmill
//
//  Created by Markos Charatzas on 18/08/2017.
//  Copyright © 2017 qnoid.com. All rights reserved.
//

import Foundation

public struct Archive {

    struct Info {
        
        static func make(at url: URL) -> Info {
            return Info(metadata: MetadataPlistEncoded(url: url))
        }

        private let metadata: Metadata
        let url: URL
        
        init(metadata: Metadata) {
            self.metadata = metadata
            self.url = metadata.url
        }

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

        var schemeName: String? {
            let schemeName: String? = metadata["SchemeName"]
            
            return schemeName
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
    
    static func make(at url: URL, info: Archive.Info) -> Archive {
        return Archive(url: url, info: info)
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
