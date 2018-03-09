//
//  TextDocumentLocation.swift
//  windmill
//
//  Created by Markos Charatzas on 27/2/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
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
