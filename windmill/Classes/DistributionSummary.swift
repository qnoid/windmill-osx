//
//  DistributionSummary.swift
//  windmill
//
//  Created by Markos Charatzas on 27/04/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

public struct DistributionSummary: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case certificateExpiryDate
    }
    
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
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.certificateExpiryDate, forKey: .certificateExpiryDate)
    }
    
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
