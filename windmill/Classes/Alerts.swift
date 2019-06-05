//
//  Alerts.swift
//  windmill
//
//  Created by Markos Charatzas on 17/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import AppKit

struct Alerts {
    
    static func make(_ error: NSError) -> NSAlert {
        
        let alert = NSAlert()
        alert.messageText = error.localizedDescription
        alert.informativeText = error.localizedFailureReason ?? ""
        alert.alertStyle = .critical
        
        return alert
    }
}
