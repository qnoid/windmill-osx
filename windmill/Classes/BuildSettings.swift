
//
//  BuildSettings.swift
//  windmill
//
//  Created by Markos Charatzas on 12/2/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation

public class BuildSettings: Encodable {
    
    enum CodingKeys: CodingKey {
        case target
    }
    
    static func make(at url: URL) -> BuildSettings {
        return BuildSettings(url: url)
    }
    
    struct Product {
        let value: [String: String]?
        
        var name: String? {
            return value?["name"]
        }
        
        var type: String? {
            return value?["type"]
        }
    }
    
    public struct Deployment {
        let value: [String: String]?
        
        var target: String? {
            return value?["target"]
        }
    }
    
    struct Target {
        let value: [String: String]?
        
        var name: String? {
            return value?["name"]
        }
    }

    let url: URL
    let values: [String: Any]
    
    public lazy var array: [[String: Any]]? = {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments), let array = jsonObject as? [[String: Any]] else {
            return nil
        }
        
        return array
    }()
    
    init(url: URL, values: [String: Any] = [:]) {
        self.url = url
        self.values = values
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.deployment?.target ?? "", forKey: .target)
    }
    var projectName: String? {
        guard let project = values["project"] as? [String: String]?, let name = project?["name"] as String? else {
            return nil
        }
        
        return name
    }
    
    var product: Product? {
        guard let value = values["product"] as? [String: String]? else {
            return nil
        }
        
        return Product(value: value)
    }
    
    var deployment: Deployment? {
        guard let value = values["deployment"] as? [String: String]? else {
            return nil
        }
        
        return Deployment(value: value)
    }
    
    func `for`(project name: String, type: String = "com.apple.product-type.application") -> BuildSettings {
        let settings: [BuildSettings]? = self.array?.map({ dictionary -> BuildSettings in
            return BuildSettings(url: self.url, values: dictionary)
        })
        
        return settings?.first(where: { settings -> Bool in
            return settings.projectName == name && settings.product?.type == type
        }) ?? settings?.first ?? BuildSettings(url: self.url)
    }
}
