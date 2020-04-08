//
//  DispatchSourceWriteProvider.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 05/04/2019.
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
