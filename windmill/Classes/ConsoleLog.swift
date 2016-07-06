//
//  ConsoleLog.swift
//  windmill
//
//  Created by Markos Charatzas on 12/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation


public class ConsoleLog {
    
    public enum Level : CustomStringConvertible {
        case DEBUG
        case INFO
        case WARN
        case ERROR
        
        public var description: String {
        
            switch self{
            case DEBUG:
                return "debug"
            case INFO:
                return "info"
            case WARN:
                return "warn"
            case ERROR:
                return "error"
            }
        }
    }
    
    public func log<T>(level : Level, _ value : T) {
        print("[windmill] [\(level)] \(value)")
    }    
}