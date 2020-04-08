//
//  Devices.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 12/2/18.
//  Copyright © 2014-2020 qnoid.com. All rights reserved.
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation is required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.
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

