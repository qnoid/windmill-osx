//
//  DispatchSourceWriteProvider.swift
//  windmill
//
//  Created by Markos Charatzas on 05/04/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

protocol DispatchSourceWriteProvider {
    
    var queue: DispatchQueue { get }
    var fileHandleForWriting: FileHandle? { get }
    
    func write(standardOutput: String, completion: DispatchQueue?) -> DispatchSourceWrite?
    
    func output(standardOutput: String, count: Int)
}

extension DispatchSourceWriteProvider {
    
    func output(standardOutput: String, count: Int) {
        
    }
    
    func write(standardOutput: String, completion: DispatchQueue? = nil) -> DispatchSourceWrite? {
        
        guard let fileHandleForWriting = fileHandleForWriting else {
            return nil
        }
        
        let fileDescriptor = fileHandleForWriting.fileDescriptor
        let writeSource = DispatchSource.makeWriteSource(fileDescriptor: fileDescriptor, queue: nil)
        
        writeSource.setEventHandler { [weak writeSource = writeSource] in
            guard let data = writeSource?.data else {
                return
            }
            
            let isSpaceAvailableForWriting = Int(data)
            
            guard isSpaceAvailableForWriting > 0 else {
                return
            }

            let bytesWritten = Darwin.write(fileDescriptor, standardOutput, standardOutput.utf8.count)
            
            (completion ?? DispatchQueue.main).async {
                self.output(standardOutput: standardOutput, count: bytesWritten)
            }
            
            writeSource?.cancel()
        }
        
        writeSource.setCancelHandler {
            fileHandleForWriting.closeFile()
        }
        
        return writeSource
    }
}
