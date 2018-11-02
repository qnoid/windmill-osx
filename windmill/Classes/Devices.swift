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
        let value: [String: AnyObject]

        var udid: String? {
            return value["udid"] as? String
        }

        var name: String? {
            return value["name"] as? String
        }
    }

    let log = OSLog(subsystem: "io.windmill.windmill", category: "windmill")
    let logCompatibility = OSLog(subsystem: "io.windmill.windmill", category: "compatibility")
    
    private let metadata: Metadata
    let url: URL
    
    init(metadata: Metadata) {
        self.metadata = metadata
        self.url = metadata.url
    }

    var platform: String? {
        return metadata["platform"]
    }

    var version: Double? {
        return metadata["version"]
    }
    
    var destination: Destination? {
        guard let dictionary: AnyObject = metadata["destination"] else {
            os_log("Destination couldn't not be read from devices at '%{public}@'. Is a 'devices.json' present? Does it define a 'destination' dictionary?`", log: log, type: .debug, url.path)
            return nil
        }
        
        guard let destination = dictionary as? [String: AnyObject] else {
            os_log("'destination' dictionary in JSON is incompatible to type [String: AnyObject]. See '%{public}@'", log: logCompatibility, type: .error, dictionary.debugDescription)
        return nil
        }
        
        return Destination(value: destination)
    }
}

