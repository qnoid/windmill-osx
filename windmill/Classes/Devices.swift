//
//  Devices.swift
//  windmill
//
//  Created by Markos Charatzas on 12/2/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation

public struct Devices {
    
    static func make(at url: URL) -> Devices {
        return Devices(metadata: MetadataJSONEncoded(url: url))
    }
    
    struct Destination {
        let value: [String: String]?

        var udid: String? {
            return value?["udid"]
        }

        var name: String? {
            return value?["name"]
        }
    }

    
    private let metadata: Metadata
    let url: URL
    
    init(metadata: Metadata) {
        self.metadata = metadata
        self.url = metadata.url
    }

    var platform: String? {
        return metadata["platform"]
    }

    var version: Float? {
        return metadata["version"]
    }
    
    var destination: Destination {
        return Destination(value: metadata["destination"] as [String: String]?)
    }
}

