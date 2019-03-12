//
//  AppBundles.swift
//  windmillTests
//
//  Created by Markos Charatzas on 09/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation
@testable import Windmill

extension AppBundle {
    static func make() -> AppBundle {
        let url = Bundle(for: AppBundleTest.self).url(forResource: "AppBundleTest/Info", withExtension: "plist")!
        let metadata = MetadataPlistEncoded(url: url)
        let info = AppBundle.Info(metadata: metadata)
        return AppBundle(url: URL(fileURLWithPath: "any"), info: info)
    }
}
