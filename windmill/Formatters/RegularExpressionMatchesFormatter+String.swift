//
//  RegularExpressionMatchesFormatter+String.swift
//  windmill
//
//  Created by Markos Charatzas on 14/4/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation

extension RegularExpressionMatchesFormatter {
    
    static func makeNote(regularExpression: NSRegularExpression = NSRegularExpression.Windmill.NOTE_EXPRESSION) -> RegularExpressionMatchesFormatter<String> {
        return single(match: regularExpression) { note in
            return "\t\t \(note)\n"
        }
    }
}
