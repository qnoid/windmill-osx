//
//  Preferences.swift
//  windmill
//
//  Created by Markos Charatzas on 30/3/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation

final class Preferences {
    
    static let shared = Preferences()
    
    struct Key {
        static let managedSource = "managedSource"
    }
    
    var managedSource: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Key.managedSource)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.managedSource)
        }
    }
}
