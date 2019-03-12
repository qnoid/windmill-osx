//
//  ActivitySuccess.swift
//  windmill
//
//  Created by Markos Charatzas on 08/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

struct ActivityAlwaysSuccess {
    
    weak var activityManager: ActivityManager?
    let type: ActivityType
    
    func make(userInfo: [AnyHashable : Any]) -> ActivitySuccess {
        return { next in
            
            return { context in
                
                let userInfo = userInfo.merging(["activity" : self.type], uniquingKeysWith: { (_, new) in new } )
                self.activityManager?.didLaunch(activity: self.type, userInfo: userInfo)
                self.activityManager?.didExitSuccesfully(activity: self.type, userInfo: userInfo)
                next?(userInfo)
            }
        }
    }
}
