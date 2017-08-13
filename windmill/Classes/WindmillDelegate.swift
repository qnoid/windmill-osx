//
//  WindmillDelegate.swift
//  windmill
//
//  Created by Markos Charatzas on 17/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation

protocol WindmillDelegate
{
    func windmill(_ windmill: Windmill, standardOutput: String, count: Int)
    
    func windmill(_ windmill: Windmill, standardError: String, count: Int)
}
