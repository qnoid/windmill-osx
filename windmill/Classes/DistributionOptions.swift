//
//  DistributionOptions.swift
//  windmill
//
//  Created by Markos Charatzas on 1/1/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation

struct DistributionOptions {
    
    let project: Project
    let metadata: Metadata
    
    var dictionary:[String:Any]? {
        let array:[[String:Any]]? = metadata["\(project.scheme).ipa"]
        
        return array?[0]
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
    
    var certificateType: String {
        return certificate?["type"] ?? ""
    }
    
    var profileName: String {
        return profile?["name"] ?? ""
    }
}
