//
//  StandardOutFormattedReader.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 20/4/18.
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

