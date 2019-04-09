//
//  UserMessageToolbarItemTest.swift
//  windmillTests
//
//  Created by Markos Charatzas on 05/04/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
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
