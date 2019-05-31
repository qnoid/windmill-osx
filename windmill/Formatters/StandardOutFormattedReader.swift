//
//  StandardOutFormattedReader.swift
//  windmill
//
//  Created by Markos Charatzas on 20/4/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation
import AppKit.NSColor

protocol StandardOutFormattedReaderDelegate: class {
    
    func standardOut(line: NSAttributedString)
}

class StandardOutFormattedReader: DispatchSourceReadProvider {
    
    static func make(standardOutFormatter: StandardOutPrettyFormatter, queue: DispatchQueue) -> StandardOutFormattedReader {
        return StandardOutFormattedReader(queue: queue, standardOutFormatter: standardOutFormatter)
    }
    
    let standardOutFormatter: StandardOutPrettyFormatter
    let queue: DispatchQueue
    weak var delegate: StandardOutFormattedReaderDelegate?
    
    var standardOutput: String = ""
    
    init(queue: DispatchQueue, standardOutFormatter: StandardOutPrettyFormatter) {
        self.queue = queue
        self.standardOutFormatter = standardOutFormatter
    }
    
    func read(fileHandleForReading: FileHandle, completion: DispatchQueue? = nil) -> DispatchSourceRead {
        self.standardOutput = ""
        return self.makeReadSource(fileHandleForReading: fileHandleForReading, completion: completion)
    }
    
    func output(part: String, count: Int) {
        self.standardOutput.append(part)
        self.standardOutput.enumerateLines { (line, _) in
            
            let formatted: NSAttributedString
            
            if let attributedString = self.standardOutFormatter.attributedString(for: line) {
                formatted = attributedString
            } else if let string = self.standardOutFormatter.string(for: line) {
                formatted = NSAttributedString(string: string, attributes: [.foregroundColor : NSColor.textColor])
            } else {
                return
            }
            
            self.delegate?.standardOut(line: formatted)
        }
        
        let range = self.standardOutput.lineRange(for: standardOutput.startIndex..<standardOutput.endIndex)
        self.standardOutput.removeSubrange(range)
    }
}

