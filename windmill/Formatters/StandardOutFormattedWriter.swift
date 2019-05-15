//
//  StandardOutFormattedWriter.swift
//  windmill
//
//  Created by Markos Charatzas on 06/04/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation


protocol StandardOut {
    
    func success(message: String)
}

protocol StandardError {
    
    func failureReason(string: inout String, message: String?)
    
    func recoverySuggestion(string: inout String, message: String?)

    func failed(title: String, error: NSError)
}

class StandardOutFormattedWriter: DispatchSourceWriteProvider, StandardOut, StandardError, CustomStringConvertible {
    
    static func make(queue: DispatchQueue, fileURL: URL?) -> StandardOutFormattedWriter {
        return StandardOutFormattedWriter(queue: queue, fileURL: fileURL)
    }
    
    var description: String {
        return self.standardOutput
    }
    
    let queue: DispatchQueue
    
    var fileURL: URL?
    var standardOutput: String = ""
    
    var fileHandleForWriting: FileHandle? {
        guard let fileURL = self.fileURL else {
            return nil
        }
        
        let fileHandle = try? FileHandle(forWritingTo: fileURL)
        fileHandle?.seekToEndOfFile()
        return fileHandle
    }
    
    init(queue: DispatchQueue, fileURL: URL?) {
        self.queue = queue
        self.fileURL = fileURL
    }
    
    func success(message: String) {
        self.standardOutput.append("** \(message) SUCCEEDED **\n")
    }

    func out(string: inout String, type: String, message: String?) {
        if let message = message {
            string.append("\(type) \(message)\n")
        }
    }
    
    func failureReason(string: inout String, message: String?) {
        return self.out(string: &string, type: "error: failureReason:", message: message)
    }
    
    func recoverySuggestion(string: inout String, message: String?) {
        return self.out(string: &string, type: "error: recoverySuggestion:", message: message)
    }

    func failed(title: String, error: NSError) {
        self.standardOutput = "** \(title) FAILED **\n"
        
        standardOutput.append("global: error: \(error.localizedDescription)\n")
        self.failureReason(string: &standardOutput, message: error.localizedFailureReason)
        self.recoverySuggestion(string: &standardOutput, message: error.localizedRecoverySuggestion)
    }

    func error(error: SubscriptionError) {
        self.standardOutput = ""
        
        if let title = error.errorTitle {
            standardOutput.append("** \(title) **\n")
        }

        self.out(string: &standardOutput, type: "global: error:", message: error.errorDescription)
        self.failureReason(string: &standardOutput, message: error.failureReason)
        self.recoverySuggestion(string: &standardOutput, message: error.recoverySuggestion)
    }
    
    func warn(title: String, error: NSError) {
        self.standardOutput = ""
        
        standardOutput.append("global: warn: \(error.localizedDescription)\n")
        self.failureReason(string: &standardOutput, message: error.localizedFailureReason)
        self.recoverySuggestion(string: &standardOutput, message: error.localizedRecoverySuggestion)
    }
    
    func warn(error: SubscriptionError) {
        self.standardOutput = ""
        
        if let title = error.errorTitle {
            standardOutput.append("* \(title) *\n")
        }
        
        self.out(string: &standardOutput, type: "global: warn:", message: error.errorDescription)
        self.failureReason(string: &standardOutput, message: error.failureReason)
        self.recoverySuggestion(string: &standardOutput, message: error.recoverySuggestion)
    }

    
    func activate() -> DispatchSourceWrite? {
        let dispatchSourceWrite = self.write(standardOutput: self.standardOutput)
        dispatchSourceWrite?.activate()
        
        self.standardOutput = ""

        return dispatchSourceWrite
    }
}
