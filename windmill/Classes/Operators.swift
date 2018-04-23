//
//  Operators.swift
//  windmill
//
//  Created by Markos Charatzas on 13/03/2015.
//  Copyright (c) 2015 qnoid.com. All rights reserved.
//

import Foundation

/// https://twitter.com/andy_matuschak/status/576165108973355008
/// https://twitter.com/andy_matuschak/status/576165111355723776

public func == (lhs: Project, rhs: Project) -> Bool {
    return lhs.filename == rhs.filename
}
