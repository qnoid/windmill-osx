//
//  TextDocumentLocation+Windmill.swift
//  windmill
//
//  Created by Markos Charatzas on 16/3/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation

extension TextDocumentLocation {
    
    var characterRange: NSRange? {
        
        guard self.characterRangeLoc >= 0, self.characterRangeLen >= 0 else {
            return nil
        }
        
        return NSRange(location: max(0, self.characterRangeLoc - 1), length: self.characterRangeLen + 1)
    }    
}
