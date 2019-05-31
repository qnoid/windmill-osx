//
//  Export.swift
//  windmill
//
//  Created by Markos Charatzas on 24/1/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation

public struct Export {
    
    public struct Metadata: Encodable {
        
        enum CodingKeys: CodingKey {
            case commit
            case deployment
            case configuration
            case distributionSummary
            case applicationProperties
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(self.commit, forKey: .commit)
            try container.encode(self.buildSettings , forKey: .deployment)
            try container.encode(self.configuration, forKey: .configuration)
            try container.encode(self.distributionSummary, forKey: .distributionSummary)
            try container.encode(self.applicationProperties, forKey: .applicationProperties)
        }
        
        let project: Project
        let buildSettings: BuildSettings
        let projectAt: Project.Location
        let distributionSummary: DistributionSummary
        let configuration: Configuration
        let applicationProperties: AppBundle.Info
        
        var commit: Repository.Commit? {
            return projectAt.commit
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

