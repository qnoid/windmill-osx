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
            basicAnimation.toValue = 0.0
            basicAnimation.duration = 1.0
            basicAnimation.repeatCount = Float.infinity
            basicAnimation.isRemovedOnCompletion = false
            
            return basicAnimation
        }()
        
        static func lightsAnimation(size: CGSize, animations images: [NSImage]) -> CAAnimation {
            let keyPath = "contents"
            let keyframeAnimation = CAKeyframeAnimation(keyPath: keyPath)
            keyframeAnimation.calculationMode = .discrete
            
            let durationOfAnimation: CFTimeInterval = 2.0
            keyframeAnimation.duration = durationOfAnimation
            keyframeAnimation.repeatCount = .infinity
            
            keyframeAnimation.values = images
                        
            return keyframeAnimation
        }
        
        static func opacityAnimation() -> CABasicAnimation {
            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = 0.25
            opacityAnimation.toValue = 1.0
            opacityAnimation.duration = 0.75
            opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            opacityAnimation.autoreverses = true
            opacityAnimation.repeatCount = .greatestFiniteMagnitude
            
            return opacityAnimation
        }
    }
}
