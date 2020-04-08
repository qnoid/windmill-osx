//
//  CAAnimation+Windmill.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 01/05/2016.
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
