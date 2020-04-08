//
//  Struct.swift
//  project-with-build-errors
//
//  Created by Markos Charatzas (markos@qnoid.com) on 5/3/18.
//  Copyright © 2018 qnoid. All rights reserved.
//

import Foundation

//Thanks Marcin, https://twitter.com/krzyzanowskim/status/970346713977409537
struct Foo {
    
    static func make() -> Foo {
        return Foo(f: "lala")
    }
    
    var f: String?
    var g: String?
}
