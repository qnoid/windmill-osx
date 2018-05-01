//
//  Metadata.swift
//  windmill
//
//  Created by Markos Charatzas on 1/1/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
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
