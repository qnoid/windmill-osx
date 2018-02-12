
//
//  BuildSettings.swift
//  windmill
//
//  Created by Markos Charatzas on 12/2/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation

public struct BuildSettings {
    
    static func make(for project: Project) -> BuildSettings {
        return BuildSettings(metadata: MetadataJSONEncoded.buildSettings(for: project))
    }
    
    struct Product {
        let value: [String: String]?
        
        var name: String? {
            return value?["name"]
        }
    }
    
    struct Deployment {
        let value: [String: Float]?
        
        var target: Float? {
            return value?["target"]
        }
    }
    
    private let metadata: Metadata
    let url: URL
    
    init(metadata: Metadata) {
        self.metadata = metadata
        self.url = metadata.url
    }
    
    var product: Product {
        return Product(value: metadata["product"] as [String: String]?)
    }
    
    var deployment: Deployment {
        return Deployment(value: metadata["deployment"] as [String: Float]?)
    }
}
