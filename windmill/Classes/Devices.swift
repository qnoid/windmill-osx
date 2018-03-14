//
//  Devices.swift
//  windmill
//
//  Created by Markos Charatzas on 12/2/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation
import os

public struct Devices {
    
    static func make(at url: URL) -> Devices {
        return Devices(metadata: MetadataJSONEncoded(url: url))
    }
    
    public struct Destination {
        let value: [String: String]

        var udid: String? {
            return value["udid"]
        }

        var name: String? {
            return value["name"]
        }
    }

    let log = OSLog(subsystem: "io.windmill.windmill", category: "windmill")
    
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
    
    var destination: Destination? {
        guard let destination: [String: String] = metadata["destination"] else {
            os_log("'destination' must be present with a 'udid' and 'name' keys; e.g. 'destination': {'udid': 'B7901B24-A855-4767-860B-A34F11168F4D', 'name': 'iPhone 5s'}`", log: log, type: .debug)
            return nil
        }
        
        return Destination(value: destination)
    }
}

