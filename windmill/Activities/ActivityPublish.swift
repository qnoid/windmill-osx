//
//  ActivityDistribute.swift
//  windmill
//
//  Created by Markos Charatzas on 08/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation

struct ActivityDistribute {
    
    static func make(export: Export, appBundle: AppBundle) -> ActivityContext {
        return ["export": export, "appBundle": appBundle]
    }
    
    weak var subscriptionManager: SubscriptionManager?
    weak var activityManager: ActivityManager?
    
    let log: URL
    
    func make(queue: DispatchQueue? = nil, next: Activity? = nil, account: Account, authorizationToken: SubscriptionAuthorizationToken) -> Activity {
        return { context in
            
            guard let export = context["export"] as? Export else {
                preconditionFailure("ActivityDistribute expects a `Export` under the context[\"export\"] for a succesful callback")
            }
            
            guard let appBundle = context["appBundle"] as? AppBundle else {
                preconditionFailure("ActivityDistribute expects a `AppBundle` under the context[\"appBundle\"] for a succesful callback")
            }
            
            let userInfo:[String : Any] = ["activity" : ActivityType.publish, "artefact": ArtefactType.otaDistribution]
            
            (queue ?? DispatchQueue.main).async {
                
                self.activityManager?.willLaunch(activity: .publish, userInfo: userInfo)
                
                self.subscriptionManager?.publish(export: export, authorizationToken: authorizationToken, forAccount: account, completion: { itms, error in
                    
                    switch (itms, error) {
                    case (_, let error?):
                        self.activityManager?.did(terminate: .publish, error: error, userInfo: ["activity": ActivityType.publish, "artefact": ArtefactType.otaDistribution, "error": error])
                    case (let itms?, _):
                        //echo "** PUBLISH SUCCEEDED **" | tee -a "${LOG_FOR_PROJECT}"
                        self.activityManager?.didExitSuccesfully(activity: .publish, userInfo: userInfo)
                        
                        self.activityManager?.notify(notification: Windmill.Notifications.didPublishProject, userInfo: ["export": export, "appBundle":appBundle, "itms": itms])
                        
                        next?([:])
                    case (.none, .none):
                        preconditionFailure("Must have either itms returned or an error")
                    }
                })
                self.activityManager?.didLaunch(activity: .publish, userInfo: userInfo)
            }
            //log progress of upload
        }
    }
    
    func success(account: Account, authorizationToken: SubscriptionAuthorizationToken) -> ActivitySuccess {
        return { next in
            return self.make(next: next, account: account, authorizationToken: authorizationToken)
        }
    }
}
