//
//  LineEnumerator.swift
//  windmill
//
//  Created by Markos Charatzas on 19/3/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation

protocol LineEnumerator {
    func enumerate(callback: (_ lineNumber: Int, _ lineRect: NSRect) -> Void)
}
