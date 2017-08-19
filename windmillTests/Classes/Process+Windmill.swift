//
//  Process+Windmill.swift
//  windmillTests
//
//  Created by Markos Charatzas on 15/08/2017.
//  Copyright © 2017 qnoid.com. All rights reserved.
//

import Foundation

extension Process {
    
    static func makeEcho() -> Process {
        let process = Process()
        process.launchPath = "/bin/echo"
        process.arguments = ["Hello World"]

        return process
    }
}
