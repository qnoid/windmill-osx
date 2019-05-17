//
//  DispatchSourceReadProvider.swift
//  windmill
//
//  Created by Markos Charatzas on 20/4/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation

protocol DispatchSourceReadProvider {
    
    var queue: DispatchQueue { get }
    var fileHandleForReading: FileHandle? { get }
    
    func read(completion: DispatchQueue?) -> DispatchSourceRead?
    
    func output(part: String, count: Int)
}

extension DispatchSourceReadProvider {
    
    func read(completion: DispatchQueue? = nil) -> DispatchSourceRead? {
        
        guard let fileHandleForReading = fileHandleForReading else {
            return nil
        }
        
        let fileDescriptor = fileHandleForReading.fileDescriptor
        let readSource = DispatchSource.makeReadSource(fileDescriptor: fileDescriptor, queue: self.queue)
        
        readSource.setEventHandler { [weak readSource = readSource] in
            guard let data = readSource?.data else {
                return
            }
            
            let estimatedBytesAvailableToRead = Int(data)
            
            var buffer = [CChar](repeating: 0, count: estimatedBytesAvailableToRead)
            let bytesRead = Darwin.read(fileDescriptor, &buffer, estimatedBytesAvailableToRead)
            
            //https://twitter.com/Catfish_Man/status/1128934439096971264
            guard bytesRead > 0, let availableString = String(validatingUTF8: buffer) else {
                return
            }
        
            (completion ?? DispatchQueue.main).async {
                self.output(part: availableString, count: availableString.utf8.count)
            }
        }
        
        readSource.setCancelHandler {
            fileHandleForReading.closeFile()
        }
        
        return readSource
    }
}
