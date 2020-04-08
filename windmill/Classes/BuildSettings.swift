
//
//  BuildSettings.swift
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
