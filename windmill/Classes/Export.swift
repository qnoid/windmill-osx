//
//  Export.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 24/1/18.
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
            try container.encode(self.buildSettings.for(project: project.name) , forKey: .deployment)
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

