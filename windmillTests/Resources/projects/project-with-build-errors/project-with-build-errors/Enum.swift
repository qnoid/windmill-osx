//
//  Enum.swift
//  project-with-build-errors
//
//  Created by Markos Charatzas (markos@qnoid.com) on 5/3/18.
//  Copyright © 2018 qnoid. All rights reserved.
//

import Foundation

enum Enum: CustomStringConvertible {
    case first
    case second
    
    var description: String {
        switch self {
        case .first:
            return "first"
        }
    }
}
