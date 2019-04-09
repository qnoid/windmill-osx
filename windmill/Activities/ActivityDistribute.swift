//
//  ActivityDistribute.swift
//  windmill
//
//  Created by Markos Charatzas on 08/03/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Foundation
import os

class ActivityDistribute: NSObject {
    static func make(export: Export, appBundle: AppBundle) -> ActivityContext {
        return ["export": export, "appBundle": appBundle]
    }
    
    weak var subscriptionManager: SubscriptionManager?
    weak var activityManager: ActivityManager?
    
    var standardOutFormattedWriter: StandardOutFormattedWriter
    
    var dispatchSourceWrite: DispatchSourceWrite? {
        didSet {
            oldValue?.cancel()
        }
    }

    deinit {
        dispatchSourceWrite?.cancel()
    }

    init(subscriptionManager: SubscriptionManager, activityManager: ActivityManager, standardOutFormattedWriter: StandardOutFormattedWriter) {
        self.subscriptionManager = subscriptionManager
        self.activityManager = activityManager
        self.standardOutFormattedWriter = standardOutFormattedWriter
    }
    
    func make(queue: DispatchQueue? = nil, next: Activity? = nil, account: Account, authorizationToken: SubscriptionAuthorizationToken) -> Activity {
        return { context in
            
            guard let export = context["export"] as? Export else {
                preconditionFailure("ActivityDistribute expects a `Export` under the context[\"export\"] for a succesful callback")
            }
            
            guard let appBundle = context["appBundle"] as? AppBundle else {
                preconditionFailure("ActivityDistribute expects a `AppBundle` under the context[\"appBundle\"] for a succesful callback")
            }
            
            let userInfo:[String : Any] = ["activity" : ActivityType.distribute, "artefact": ArtefactType.otaDistribution]
            
            (queue ?? DispatchQueue.main).async {
                
                self.activityManager?.willLaunch(activity: .distribute, userInfo: userInfo)
                
                self.subscriptionManager?.distribute(export: export, authorizationToken: authorizationToken, forAccount: account, completion: { itms, error in
                    
                    switch (itms, error) {
                    case (_, let error?):
                        let error = error as NSError
                        
                        self.standardOutFormattedWriter.failed(title: "DISTRIBUTE", error: error)
                        self.dispatchSourceWrite = self.standardOutFormattedWriter.activate()

                        self.activityManager?.did(terminate: .distribute, error: WindmillError.recoverable(activityType: .distribute, error: error), userInfo: ["activity": ActivityType.distribute, "artefact": ArtefactType.otaDistribution, "error": WindmillError.recoverable(activityType: .distribute, error: error)])
                    case (let itms?, _):
                        self.standardOutFormattedWriter.success(message: "DISTRIBUTE")
                        self.dispatchSourceWrite = self.standardOutFormattedWriter.activate()
                        
                        self.activityManager?.didExitSuccesfully(activity: .distribute, userInfo: userInfo)
                        
                        self.activityManager?.notify(notification: Windmill.Notifications.didDistributeProject, userInfo: ["export": export, "appBundle":appBundle, "itms": itms])
                        
                        next?([:])
                    case (.none, .none):
                        preconditionFailure("Must have either itms returned or an error")
                    }
                })
                self.activityManager?.didLaunch(activity: .distribute, userInfo: userInfo)
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
