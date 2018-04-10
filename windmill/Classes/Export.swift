//
//  Export.swift
//  windmill
//
//  Created by Markos Charatzas on 24/1/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation

public struct Export {
    
    public struct DistributionSummary {
        
        public static func make(at url: URL) -> DistributionSummary {
            return DistributionSummary(metadata: MetadataPlistEncoded(url: url))
        }
        
        private let metadata: Metadata
        let url: URL
        
        init(metadata: Metadata) {
            self.metadata = metadata
            self.url = metadata.url
        }

        let dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yy"
            
            return dateFormatter
        }()

        var dictionary:[String:Any]? {
            
            guard let key = self.key else {
                return nil
            }
            
            let array:[[String:Any]]? = metadata[key]
            
            return array?[0]
        }
        
        var key: String? {
            return metadata.dictionary?.keys.first
        }

        var name: String {
            return dictionary?["name"] as? String ?? ""
        }

        var team: [String: String]? {
            return dictionary?["team"] as? [String: String]
        }
        
        var certificate: [String: String]? {
            return dictionary?["certificate"] as? [String: String]
        }
        
        var profile: [String: String]? {
            return dictionary?["profile"] as? [String: String]
        }
        
        var teamId: String {
            return team?["id"] ?? ""
        }
        
        var teamName: String {
            return team?["name"] ?? ""
        }
        
        var certificateType: String? {
            return certificate?["type"]
        }
        
        var certificateExpiryDate: Date? {
            guard let dateExpires = certificate?["dateExpires"] else {
                return nil
            }
            
            return dateFormatter.date(from: dateExpires)
        }
        
        var profileName: String? {
            return profile?["name"]
        }
    }

    public struct Manifest {

        public static func make(at url: URL) -> Manifest {
            return Manifest(metadata: MetadataPlistEncoded(url: url))
        }
        
        private let metadata: Metadata
        let url: URL

        init(metadata: Metadata) {
            self.metadata = metadata
            self.url = metadata.url
        }

        var items:[String:Any]? {
            let items:[[String:Any]]? = metadata["items"]
            
            return items?[0]
        }

        var bundleIdentifier: String {
            let metadata = items?["metadata"] as? [String: String]
            
            return metadata?["bundle-identifier"] ?? ""
        }
        
        var bundleVersion: String {
            let metadata = items?["metadata"] as? [String: String]
            
            return metadata?["bundle-version"] ?? ""
        }
        
        var title: String {
            let metadata = items?["metadata"] as? [String: String]
            
            return metadata?["title"] ?? ""
        }
    }
    
    static func make(at url: URL, manifest: Manifest, distributionSummary: DistributionSummary) -> Export {
        return Export(url: url, manifest: manifest, distributionSummary: distributionSummary)
    }
    
    let url: URL
    let manifest: Manifest
    let distributionSummary: DistributionSummary
}

extension Export {
    
    var filename: String {
        return self.distributionSummary.key ?? self.url.lastPathComponent
    }
}

