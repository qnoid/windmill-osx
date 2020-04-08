//
//  TextDocumentLocation.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 27/2/18.
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

@objc(DVTTextDocumentLocation)
class TextDocumentLocation: NSObject, NSCoding {
    
    var documentURL: URL?
    let startingColumnNumber: Int
    let endingColumnNumber: Int
    let startingLineNumber: Int
    let endingLineNumber: Int
    let characterRangeLen: Int
    let characterRangeLoc: Int
    
    init(documentURL: URL = URL(fileURLWithPath: "")) {
        self.documentURL = documentURL
        self.startingColumnNumber = 0
        self.endingColumnNumber = 0
        self.characterRangeLen = 0
        self.endingLineNumber = 0
        self.startingLineNumber = 0
        self.characterRangeLoc = 0
    }
    
    func encode(with aCoder: NSCoder) {
        
        if let path = self.documentURL?.path {
            aCoder.encode(path, forKey: "documentURL")
        }
        aCoder.encode(self.startingColumnNumber, forKey: "startingColumnNumber")
        aCoder.encode(self.endingColumnNumber, forKey: "endingColumnNumber")
        aCoder.encode(self.startingLineNumber, forKey: "startingLineNumber")
        aCoder.encode(self.endingLineNumber, forKey: "endingLineNumber")
        aCoder.encode(self.characterRangeLen, forKey: "characterRangeLen")
        aCoder.encode(self.characterRangeLoc, forKey: "characterRangeLoc")
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        if let string = aDecoder.decodeObject(forKey: "documentURL") as? String {
            self.documentURL = URL(string: string)
        }
        
        self.startingColumnNumber = aDecoder.decodeInteger(forKey: "startingColumnNumber")
        self.endingColumnNumber = aDecoder.decodeInteger(forKey: "endingColumnNumber")
        self.startingLineNumber = aDecoder.decodeInteger(forKey: "startingLineNumber")
        self.endingLineNumber = aDecoder.decodeInteger(forKey: "endingLineNumber")
        self.characterRangeLen = aDecoder.decodeInteger(forKey: "characterRangeLen")
        self.characterRangeLoc = aDecoder.decodeInteger(forKey: "characterRangeLoc")
    }
}
