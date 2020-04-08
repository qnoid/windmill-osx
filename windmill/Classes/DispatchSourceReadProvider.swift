//
//  DispatchSourceReadProvider.swift
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

protocol DispatchSourceReadProvider: class {
    
    var queue: DispatchQueue { get }
    
    func makeReadSource(fileHandleForReading: FileHandle, completion: DispatchQueue?) -> DispatchSourceRead
    func output(part: String, count: Int)
}

extension DispatchSourceReadProvider {
    
    func makeReadSource(fileHandleForReading: FileHandle, completion: DispatchQueue? = nil) -> DispatchSourceRead {
        
        let fileDescriptor = fileHandleForReading.fileDescriptor
        let readSource = DispatchSource.makeReadSource(fileDescriptor: fileDescriptor, queue: self.queue)
        
        readSource.setEventHandler { [weak readSource = readSource, weak self] in
            guard let data = readSource?.data else {
                return
            }
            
            let estimatedBytesAvailableToRead = Int(data)
            
            var buffer = [CChar](repeating: 0, count: estimatedBytesAvailableToRead)
            let bytesRead = Darwin.read(fileDescriptor, &buffer, estimatedBytesAvailableToRead)            
            buffer.append(0)
            
            //https://twitter.com/Catfish_Man/status/1128934439096971264
            guard bytesRead > 0, let availableString = String(validatingUTF8: buffer) else {
                return
            }
        
            (completion ?? DispatchQueue.main).async { 
                self?.output(part: availableString, count: availableString.utf8.count)
            }
        }
        
        readSource.setCancelHandler {
            fileHandleForReading.closeFile()
        }
        
        return readSource
    }
}
