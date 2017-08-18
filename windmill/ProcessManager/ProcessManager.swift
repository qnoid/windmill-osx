//
//  ProcessManager.swift
//  windmill
//
//  Created by Markos Charatzas on 16/08/2017.
//  Copyright © 2017 qnoid.com. All rights reserved.
//

import Foundation

typealias ProcessCompletionHandler = (_ type: ActivityType, _ success: Bool, _ error: Error?) -> Void

struct ProcessCompletionHandlerChain {
    let completionHandler: ProcessCompletionHandler
    
    func `case`(success: @escaping ProcessCompletionHandler) -> ProcessCompletionHandler {
        
        return { [completionHandler = self.completionHandler] type, isSuccess, error in
            completionHandler(type, isSuccess, error)
            
            guard isSuccess else {
                return
            }
            
            success(type, isSuccess, error)
        }
    }
}

protocol ProcessManagerDelegate: class {
    
    func willLaunch(manager: ProcessManager, process: Process, type: ActivityType)
    
    func didLaunch(manager: ProcessManager, process: Process, type: ActivityType)
}

struct ProcessManagerChain {
    
    let dispatchWorkItem: (_ completionHandler: @escaping ProcessCompletionHandler) -> DispatchWorkItem
}

struct ProcessManager {
    
    weak var delegate: ProcessManagerDelegate?
    
    /* private */ func makeDispatchWorkItem(process processProvider: @escaping @autoclosure () -> Process, type: ActivityType, queue: DispatchQueue = .main, completionHandler: @escaping ProcessCompletionHandler) -> DispatchWorkItem {
        
        return DispatchWorkItem {
            
            let process = processProvider()
            
            process.terminationHandler = { process in
                let terminationStatus = Int(process.terminationStatus)
                
                guard terminationStatus == 0 else {
                    queue.async {
                        completionHandler(type, false, NSError.errorTermination(for: type, status: terminationStatus))
                    }
                    return
                }
                
                queue.async {
                    completionHandler(type, true, nil)
                }
            }
            
            self.delegate?.willLaunch(manager: self, process: process, type: type)
            
            process.launch()
            
            self.delegate?.didLaunch(manager: self, process: process, type: type)
        }
    }
}
