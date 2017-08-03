//
//  ForwardExecution.swift
//  windmill
//
//  Created by Markos Charatzas on 01/08/2017.
//  Copyright © 2017 qnoid.com. All rights reserved.
//

import Foundation

typealias Execute = () throws -> Void
typealias CompletionHandler = (_ success: Bool, _ error: Error?) -> Void

struct ForwardExecution {
    let execute: Execute
    
    func run() throws -> Void {
        try execute()
    }
    
    func then(_ execute: @escaping Execute) -> ForwardExecution {
        
        let before = self.execute
        
        return ForwardExecution {
            try before()
            try execute()
        }
    }

    func dispatchWorkItem(queue: DispatchQueue = .main, completionHandler: @escaping CompletionHandler) -> DispatchWorkItem {
        return DispatchWorkItem{
            do {
                try self.run()
                queue.async {
                    completionHandler(true, nil)
                }
            } catch {
                queue.async {
                    completionHandler(false, error)
                }
            }
        }
    }
}
