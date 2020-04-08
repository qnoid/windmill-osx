//
//  StandardOutFormattedWriter.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 06/04/2019.
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
    
    func note(_ message: String) {
        self.standardOutput = ""
        self.out(string: &standardOutput, type: "note: ", message: message)
    }

    
    func activate() -> DispatchSourceWrite? {
        let dispatchSourceWrite = self.write(standardOutput: self.standardOutput)
        dispatchSourceWrite?.activate()
        
        self.standardOutput = ""

        return dispatchSourceWrite
    }
}
