//
//  ActivitySuccess.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 08/03/2019.
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

import Foundation

struct ActivityAlwaysSuccess {
    
    weak var activityManager: ActivityManager?
    let type: ActivityType
    
    func make(userInfo: [AnyHashable : Any]) -> SuccessfulActivity {
        return SuccessfulActivity { next in
            
            return { context in
                
                let userInfo = userInfo.merging(["activity" : self.type], uniquingKeysWith: { (_, new) in new } )
                self.activityManager?.didLaunch(activity: self.type, userInfo: userInfo)
                self.activityManager?.didExitSuccesfully(activity: self.type, userInfo: userInfo)
                next?(userInfo)
            }
        }
    }
}
