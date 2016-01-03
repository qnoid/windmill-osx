//
//  NSBundle+WindmillBundle.swift
//  windmill
//
//  Created by Markos Charatzas on 16/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation

public struct BundleKey : RawRepresentable
{
    static var CFBundleName: BundleKey {
        return BundleKey(rawValue: "CFBundleName")!
    }

    public typealias RawValue = String
    
    public let rawValue: String
    
    /// Convert from a value of `RawValue`, yielding `nil` iff
    /// `rawValue` does not correspond to a value of `Self`.
    public init?(rawValue: String)
    {
        self.rawValue = rawValue
    }
}

extension NSBundle
{
    func CFBundleName() -> String {
    return self.infoDictionary?[BundleKey.CFBundleName.rawValue] as! String
    }
}