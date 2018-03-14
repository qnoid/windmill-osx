//
//  ArtefactsViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 24/1/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Cocoa
import os

@IBDesignable class ArtefactsViewControllerView: NSView {
    
    
}

class ArtefactsViewController: NSViewController {

    @IBOutlet weak var buildArtefactView: ArtefactView!
    @IBOutlet weak var archiveArtefactView: ArtefactView!
    @IBOutlet weak var exportArtefactView: ArtefactView! {
        didSet {
            exportArtefactView.headerLabel.stringValue = ""
        }
    }
    @IBOutlet weak var deployArtefactView: ArtefactView! {
        didSet {
            deployArtefactView.headerLabel.stringValue = "You need to:"
            if (try? Keychain.defaultKeychain().findWindmillUser()) == nil {
                deployArtefactView.toolTip =  NSLocalizedString("windmill.paid", comment: "")
            }
        }
    }
    
    lazy var artefactViews: [ActivityType: ArtefactView] = { [unowned self] in
        return [.build: self.buildArtefactView, .archive: self.archiveArtefactView, .export: self.exportArtefactView, .deploy: self.deployArtefactView]
        }()
    
    @IBOutlet weak var appView: AppView!{
        didSet{
            appView.isHidden = true
        }
    }
    @IBOutlet weak var archiveView: ArchiveView! {
        didSet{
            archiveView.isHidden = true
        }
    }
    @IBOutlet weak var exportView: ExportView! {
        didSet{
            exportView.isHidden = true
        }
    }
    @IBOutlet weak var deployView: DeployView! {
        didSet{
            deployView.isHidden = true
        }
    }

    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("dd/MM/YYYY, HH:mm")
        
        return dateFormatter
    }()
    
    let defaultCenter = NotificationCenter.default
    
    weak var windmill: Windmill? {
        didSet{
            self.defaultCenter.addObserver(self, selector: #selector(willStartProject(_:)), name: Windmill.Notifications.willStartProject, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(activityDidLaunch(_:)), name: Windmill.Notifications.activityDidLaunch, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(activityError(_:)), name: Windmill.Notifications.activityError, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(activityDidExitSuccesfully(_:)), name: Windmill.Notifications.activityDidExitSuccesfully, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(didBuildProject(_:)), name: Windmill.Notifications.didBuildProject, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(didArchiveSuccesfully(_:)), name: Windmill.Notifications.didArchiveProject, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(didExportSuccesfully(_:)), name: Windmill.Notifications.didExportProject, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(didDeploySuccesfully(_:)), name: Windmill.Notifications.didDeployProject, object: windmill)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func willStartProject(_ aNotification: Notification) {
        for artefactView in self.artefactViews.values {
            artefactView.isHidden = false
            artefactView.stopStageAnimation()
        }
        self.appView.isHidden = true
        self.archiveView.isHidden = true
        self.exportView.isHidden = true
        self.deployView.isHidden = true
    }

    @objc func activityDidLaunch(_ aNotification: Notification) {
        guard let activity = aNotification.userInfo?["activity"] as? ActivityType else {
            return
        }

        self.artefactViews[activity]?.startStageAnimation()
    }

    @objc func activityError(_ aNotification: Notification) {
        if let activity = aNotification.userInfo?["activity"] as? ActivityType {
            self.artefactViews[activity]?.stopStageAnimation()
        }
    }
    
    @objc func activityDidExitSuccesfully(_ aNotification: Notification) {
        
        guard let activity = aNotification.userInfo?["activity"] as? ActivityType else {
            return
        }

        self.artefactViews[activity]?.stopStageAnimation()
        self.artefactViews[activity]?.isHidden = true
        
        guard case .checkout = activity else {
            return
        }
        
        guard let repositoryLocalURL = aNotification.userInfo?["repositoryLocalURL"] as? URL, let commit = try? Repository.parse(localGitRepoURL: repositoryLocalURL) else {
            os_log("Repository for project not found. Have you cloned it? Did you pass the `repositoryLocalURL`?", log: .default, type: .error)
            return
        }
        
        self.appView.commit = commit
    }

    @objc func didBuildProject(_ aNotification: NSNotification) {
        
        guard let appBundle = aNotification.userInfo?["appBundle"] as? AppBundle else {
            return
        }
        
        self.appView.appBundle = appBundle
        self.appView.isHidden = false
    }
    @objc func didArchiveSuccesfully(_ aNotification: Notification) {
        
        guard let archive = aNotification.userInfo?["archive"] as? Archive else {
            return
        }
        
        let info = archive.info
        
        self.archiveView.titleTextField.stringValue = info.name
        self.archiveView.versionTextField.stringValue = "\(info.bundleShortVersion) (\(info.bundleVersion))"
        let creationDate = info.creationDate ?? Date()
        
        self.archiveView.dateTextField.stringValue = self.dateFormatter.string(from: creationDate)
        self.archiveView.archive = archive
        self.archiveView.isHidden = false
    }
    
    @objc func didExportSuccesfully(_ aNotification: Notification) {

        if let export = aNotification.userInfo?["export"] as? Export {
            self.exportView.export = export
        }
        
        if let appBundle = aNotification.userInfo?["appBundle"] as? AppBundle {
            self.exportView.appBundle = appBundle
        }
        
        self.exportView.isHidden = false
    }
    
    @objc func didDeploySuccesfully(_ aNotification: Notification) {
        
        if let export = aNotification.userInfo?["export"] as? Export {
            self.deployView.export = export
        }

        if let buildSettings = aNotification.userInfo?["buildSettings"] as? BuildSettings {
            self.deployView.buildSettings = buildSettings
        }
        
        self.deployView.isHidden = false
    }
}
