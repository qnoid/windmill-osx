//
//  ProcessManager.swift
//  windmill
//
//  Created by Markos Charatzas on 16/08/2017.
//  Copyright © 2017 qnoid.com. All rights reserved.
//

import Foundation

typealias ProcessCompletionHandler = (_ process: Process, _ type: ActivityType, _ success: Bool, _ error: Error?) -> Void

struct ProcessCompletionHandlerChain {
    let completionHandler: ProcessCompletionHandler
    
    func success(completionHandler: @escaping ProcessCompletionHandler) -> ProcessCompletionHandler {
        return chain(success: completionHandler).completionHandler
    }

    func chain(success: @escaping ProcessCompletionHandler) -> ProcessCompletionHandlerChain {
        
        return ProcessCompletionHandlerChain { [completionHandler = self.completionHandler] process, type, isSuccess, error in
            completionHandler(process, type, isSuccess, error)
            
            guard isSuccess else {
                return
            }
            
            success(process, type, isSuccess, error)
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

struct DispatchWorkItemCompute {
    var dispatchWorkItem: (_ queue: DispatchQueue, _ completionHandler: @escaping ProcessCompletionHandler) -> DispatchWorkItem
}

struct ProcessManager {
    
    weak var delegate: ProcessManagerDelegate?
    
    /* private */ func makeCompute(process: Process, type: ActivityType) -> DispatchWorkItemCompute {
        return DispatchWorkItemCompute { queue , completionHandler in
            return self.makeDispatchWorkItem(process: process, type: type, queue: queue, completionHandler: completionHandler)
        }
    }

    /* private */ func makeDispatchWorkItem(process processProvider: @escaping @autoclosure () -> Process, type: ActivityType, queue: DispatchQueue = .main, completionHandler: @escaping ProcessCompletionHandler) -> DispatchWorkItem {
        
        return DispatchWorkItem {
            
            let process = processProvider()
            
            process.terminationHandler = { process in
                let terminationStatus = Int(process.terminationStatus)
                
                guard terminationStatus == 0 else {
                    queue.async {
                        completionHandler(process, type, false, NSError.errorTermination(process: process, for: type, status: terminationStatus))
                    }
                    return
                }
                
                queue.async {
                    completionHandler(process, type, true, nil)
                }
            }
            
            self.delegate?.willLaunch(manager: self, process: process, type: type)
            
            process.launch()
            
            self.delegate?.didLaunch(manager: self, process: process, type: type)
        }
    }
}
