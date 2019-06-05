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
    
    struct Context {
        
        static func make(locations: Windmill.Locations, configuration: Windmill.Configuration) -> ActivityContext {
            
            let export = Export.make(home: locations.home, configuration: configuration)
            let appBundle = AppBundle.make(home: locations.home, project: configuration.project)
            let metadata = Export.Metadata.make(home: locations.home, projectAt: locations.projectAt, configuration: configuration, applicationProperties: appBundle.info)

            return make(export: export, metadata: metadata, appBundle: appBundle)
        }
        
        static func make(export: Export, metadata: Export.Metadata, appBundle: AppBundle) -> ActivityContext {
            return ["export": export, "metadata": metadata, "appBundle": appBundle]
        }
    }
    
    weak var subscriptionManager: SubscriptionManager?
    weak var delegate: ActivityDelegate?
    
    var standardOutFormattedWriter: StandardOutFormattedWriter

    var dispatchSourceWrite: DispatchSourceWrite? {
        didSet {
            oldValue?.cancel()
        }
    }

    deinit {
        dispatchSourceWrite?.cancel()
    }

    init(subscriptionManager: SubscriptionManager, standardOutFormattedWriter: StandardOutFormattedWriter) {
        self.subscriptionManager = subscriptionManager
        self.standardOutFormattedWriter = standardOutFormattedWriter
    }
    
    func make(queue: DispatchQueue? = nil, next: Activity? = nil, account: Account, authorizationToken: SubscriptionAuthorizationToken) -> Activity {
        return { context in
            
            guard let export = context["export"] as? Export else {
                preconditionFailure("ActivityDistribute expects a `Export` under the context[\"export\"] for a succesful callback")
            }

            guard let metadata = context["metadata"] as? Export.Metadata else {
                preconditionFailure("ActivityExport expects a `Export.Metadata` under the context[\"metadata\"] for a succesful callback")
            }

            guard let appBundle = context["appBundle"] as? AppBundle else {
                preconditionFailure("ActivityDistribute expects a `AppBundle` under the context[\"appBundle\"] for a succesful callback")
            }
            
            let userInfo:[String : Any] = ["activity" : ActivityType.distribute, "artefact": ArtefactType.otaDistribution]
            
            (queue ?? DispatchQueue.main).async {
                
                self.delegate?.willLaunch(activity: .distribute, userInfo: userInfo)
                
                self.subscriptionManager?.distribute(export: export, metadata: metadata, authorizationToken: authorizationToken, forAccount: account, completion: { itms, error in
                    
                    switch (itms, error) {
                    case (_, let error?):
                        let error = error as NSError
                        
                        self.standardOutFormattedWriter.failed(title: "DISTRIBUTE", error: error)
                        self.dispatchSourceWrite = self.standardOutFormattedWriter.activate()

                        self.delegate?.did(terminate: .distribute, error: WindmillError.recoverable(activityType: .distribute, error: error), userInfo: ["activity": ActivityType.distribute, "artefact": ArtefactType.otaDistribution, "error": WindmillError.recoverable(activityType: .distribute, error: error)])
                    case (_, .none):
                        self.standardOutFormattedWriter.success(message: "DISTRIBUTE")
                        self.dispatchSourceWrite = self.standardOutFormattedWriter.activate()
                        
                        self.delegate?.didExitSuccesfully(activity: .distribute, userInfo: userInfo)
                        
                        self.delegate?.notify(notification: Windmill.Notifications.didDistributeProject, userInfo: ["export": export, "metadata": metadata, "appBundle":appBundle])
                        
                        next?([:])
                    }
                })
                self.delegate?.didLaunch(activity: .distribute, userInfo: userInfo)
            }
            //log progress of upload
        }
    }
    
    func success(account: Account, authorizationToken: SubscriptionAuthorizationToken) -> SuccessfulActivity {
        return SuccessfulActivity { next in
            return self.make(next: next, account: account, authorizationToken: authorizationToken)
        }
    }
}
