//
//  Configuration.swift
//  windmill
//
//  Created by Markos Charatzas on 20/12/17.
//  Copyright © 2017 qnoid.com. All rights reserved.
//

import Foundation

public enum Configuration {
    case debug
    case release
    
    var name: String {
        switch self {
        case .debug:
            return "Debug"
        case .release:
            return "Release"
        }        
    }
}
