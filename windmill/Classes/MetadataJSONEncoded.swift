//
//  Metadata.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 1/1/18.
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

public protocol Metadata {
    
    var url: URL { get }
    
    var dictionary: [String: Any]? { get }
    
    subscript<T>(key: String) -> T? { get }
}

extension Metadata {

    public subscript<T>(key: String) -> T? {
        return dictionary?[key] as? T
    }
    
}

public class MetadataJSONEncoded: Metadata, CustomDebugStringConvertible {

    public var debugDescription: String {
        return dictionary.debugDescription
    }
    
    public let url: URL
    
    public lazy var dictionary: [String: Any]? = {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments), let dictionary = jsonObject as? [String: Any] else {
            return nil
        }
        
        return dictionary
    }()
        
    init(url: URL) {
        self.url = url
    }
    
}

public class MetadataPlistEncoded: Metadata {
    
    public let url: URL
    
    public lazy var dictionary: [String: Any]? = {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        guard let propertyList = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil), let dictionary = propertyList as? [String: Any] else {
            return nil
        }
        
        return dictionary
    }()
    
    init(url: URL) {
        self.url = url
    }
}
