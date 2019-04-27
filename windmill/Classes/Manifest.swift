//
//  Manifest.swift
//  windmill
//
//  Created by Markos Charatzas on 27/04/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

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
