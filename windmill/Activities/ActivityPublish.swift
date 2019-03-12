//
//  ActivityPublish.swift
//  windmill
//
//  Created by Markos Charatzas on 08/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

struct ActivityPublish {
    
    weak var accountResource: AccountResource?
    weak var activityManager: ActivityManager?
    
    let log: URL
    
    func make(project: Project, user: String) -> ActivitySuccess {
        
        return { next in
            return { context in
                
                guard let export = context["export"] as? Export else {
                    preconditionFailure("ActivityPublish expects a `Export` under the context[\"export\"] for a succesful callback")
                }
                
                guard let appBundle = context["appBundle"] as? AppBundle else {
                    preconditionFailure("ActivityPublish expects a `AppBundle` under the context[\"appBundle\"] for a succesful callback")
                }
                
                let claim = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjU1ZmQyYWMzLTdkZTItNGM2Ny1iMGY4LTc5ZTdjZmEwMjBjMiIsImV4cCI6MzMxMDgxODg1NzQsInR5cCI6ImF0IiwidiI6MX0.yxmDN4QLq0eJeJ1D42ZoIb9HO67o8bRvYXFjDy9bLcs"
                
                let userInfo:[String : Any] = ["activity" : ActivityType.publish, "artefact": ArtefactType.otaDistribution]

                self.accountResource?.requestExport(export: export, forAccount: user, authorizationToken: SubscriptionAuthorizationToken(value: claim), completion: { itms, error in
                    
                    switch (itms, error) {
                    case (_, let error?):
                        self.activityManager?.post(notification: Windmill.Notifications.didError, userInfo: ["activity": ActivityType.publish, "artefact": ArtefactType.otaDistribution, "error": error])
                    case (let itms?, _):
                        //echo "** PUBLISH SUCCEEDED **" | tee -a "${LOG_FOR_PROJECT}"
                        self.activityManager?.didExitSuccesfully(activity: ActivityType.publish, userInfo: userInfo)
                        
                        self.activityManager?.post(notification: Windmill.Notifications.didPublishProject, userInfo: ["project":project, "export": export, "appBundle":appBundle, "itms": itms])
                        
                        next?([:])
                    case (.none, .none):
                        preconditionFailure("Must have either itms returned or an error")
                    }
                })
                self.activityManager?.didLaunch(activity: ActivityType.publish, userInfo: userInfo)
                //log progress of upload
            }
        }
    }
}
