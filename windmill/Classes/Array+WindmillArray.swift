//
//  Array+WindmillArray.swift
//  windmill
//
//  Created by Markos Charatzas on 17/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation

extension Array
{
    func forEach(each: (Element) -> Void){
        for obj in self {
            each(obj)
        }
    }
}