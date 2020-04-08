//
//  UserMessageToolbarItemTest.swift
//  windmillTests
//
//  Created by Markos Charatzas (markos@qnoid.com) on 05/04/2019.
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

import XCTest

@testable import Windmill

class UserMessageToolbarItemTest: XCTestCase {

    func testGivenWindmillRunningAssertRecoverableErrorDoesNotStopIt() {

        let userMessageToolbarItem = UserMessageToolbarItem(itemIdentifier: NSToolbarItem.Identifier(rawValue: "foo"))
        
        let userInfo: [AnyHashable : Any] = ["error": WindmillError.recoverable(activityType: .distribute, error: nil), "activity": ActivityType.distribute.rawValue]
        let notification = Notification(name: Windmill.Notifications.didError, object: nil, userInfo: userInfo)
        
        userMessageToolbarItem.windmillImageView.startAnimation()
        userMessageToolbarItem.activityError(notification)

        let spinAnimation = userMessageToolbarItem.windmillImageView.layer?.animation(forKey: "spinAnimation")
        
        XCTAssertNotNil(spinAnimation, "Windmill should still be spinning")
    }
}
