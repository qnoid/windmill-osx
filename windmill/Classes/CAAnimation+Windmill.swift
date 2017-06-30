//
//  CAAnimation+Windmill.swift
//  windmill
//
//  Created by Markos Charatzas on 01/05/2016.
//  Copyright © 2016 qnoid.com. All rights reserved.
//

import AppKit

extension CAAnimation {
    
    struct Windmill {
        static let spinAnimation: CAAnimation = {
            let basicAnimation = CABasicAnimation(keyPath:"transform.rotation")
            basicAnimation.fromValue = 2.0 * .pi
            basicAnimation.toValue = NSNumber(value: 0.0 as Double)
            basicAnimation.duration = 1.0
            basicAnimation.repeatCount = Float.infinity
            
            return basicAnimation
        }()
    }
}
