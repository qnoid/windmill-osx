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
    
    static let dispatch_queue_serial = DispatchQueue(label: "io.windmil.StandardOutFormattedReader", qos: .utility, attributes: [])
    
    static func make(standardOutFormatter: StandardOutPrettyFormatter, fileURL: URL?) -> StandardOutFormattedReader {
        return StandardOutFormattedReader(queue: dispatch_queue_serial, standardOutFormatter: standardOutFormatter, fileURL: fileURL)
    }
    
    let standardOutFormatter: StandardOutPrettyFormatter
    let queue: DispatchQueue
    weak var delegate: StandardOutFormattedReaderDelegate?
    
    var fileURL: URL?
    var standardOutput: String = ""
    
    var fileHandleForReading: FileHandle? {
        guard let fileURL = self.fileURL else {
            return nil
        }
        
        return try? FileHandle(forReadingFrom: fileURL)
    }
    
    init(queue: DispatchQueue, standardOutFormatter: StandardOutPrettyFormatter, fileURL: URL?) {
        self.queue = queue
        self.standardOutFormatter = standardOutFormatter
        self.fileURL = fileURL
    }
    
    func activate() -> DispatchSourceRead? {
        self.standardOutput = ""
        
        let dispatchSourceRead = self.get()
        dispatchSourceRead?.activate()
        
        return dispatchSourceRead
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
            
            if let delegate = self.delegate {
                DispatchQueue.main.async {
                    delegate.standardOut(line: formatted)
                }
            }
        }
        
        let range = self.standardOutput.lineRange(for: standardOutput.startIndex..<standardOutput.endIndex)
        self.standardOutput.removeSubrange(range)
    }
}

