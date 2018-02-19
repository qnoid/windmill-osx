//
//  Foo.swift
//  windmill
//
//  Created by Markos Charatzas on 18/2/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation

extension CharacterSet {
    
    public struct Windmill {
        
        static func random(characters: CharacterSet = CharacterSet.alphanumerics, length: Int = 32) -> String {
        
            let string = String(describing:characters)
            
            var random = String()
        
            for _ in 0..<length {
                let indexOfRandomCharacter = Int(arc4random_uniform(UInt32(string.count)))
                let randomIndex = string.index(string.startIndex, offsetBy: indexOfRandomCharacter)
                random.append(string[randomIndex])
            }

            return random
        }
    }
}
