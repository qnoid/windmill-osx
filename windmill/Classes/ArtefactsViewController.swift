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

    @IBOutlet weak var archiveArtefactView: ArtefactView!
    @IBOutlet weak var exportArtefactView: ArtefactView!
    @IBOutlet weak var deployArtefactView: ArtefactView!
    
    lazy var artefactViews: [ActivityType: ArtefactView] = { [unowned self] in
        return [.archive: self.archiveArtefactView, .export: self.exportArtefactView, .deploy: self.deployArtefactView]
        }()
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.defaultCenter.addObserver(self, selector: #selector(ArtefactsViewController.windmillWillDeployProject(_:)), name: Windmill.Notifications.willDeployProject, object: nil)
        self.defaultCenter.addObserver(self, selector: #selector(ArtefactsViewController.activityDidLaunch(_:)), name: Process.Notifications.activityDidLaunch, object: nil)
        self.defaultCenter.addObserver(self, selector: #selector(ArtefactsViewController.activityError(_:)), name: Process.Notifications.activityError, object: nil)
        self.defaultCenter.addObserver(self, selector: #selector(ArtefactsViewController.activityDidExitSuccesfully(_:)), name: Process.Notifications.activityDidExitSuccesfully, object: nil)
        self.defaultCenter.addObserver(self, selector: #selector(ArtefactsViewController.didArchiveSuccesfully(_:)), name: Windmill.Notifications.didArchiveProject, object: nil)
        self.defaultCenter.addObserver(self, selector: #selector(ArtefactsViewController.didExportSuccesfully(_:)), name: Windmill.Notifications.didExportProject, object: nil)
        self.defaultCenter.addObserver(self, selector: #selector(ArtefactsViewController.didDeploySuccesfully(_:)), name: Windmill.Notifications.didDeployProject, object: nil)
    }
    
    @objc func windmillWillDeployProject(_ aNotification: Notification) {
        for artefactView in self.artefactViews.values {
            artefactView.isHidden = false
            artefactView.stopStageAnimation()
        }
        self.archiveView.isHidden = true
        self.exportView.isHidden = true
        self.deployView.isHidden = true
    }

    @objc func activityDidLaunch(_ aNotification: Notification) {
        guard let activity = aNotification.userInfo?["activity"] as? String, let activityType = ActivityType(rawValue: activity) else {
            return
        }

        self.artefactViews[activityType]?.startStageAnimation()
    }

    @objc func activityError(_ aNotification: Notification) {
        guard let activity = aNotification.userInfo?["activity"] as? String, let activityType = ActivityType(rawValue: activity) else {
            return
        }

        self.artefactViews[activityType]?.stopStageAnimation()
    }
    
    @objc func activityDidExitSuccesfully(_ aNotification: Notification) {
        
        guard let activity = aNotification.userInfo?["activity"] as? String, let activityType = ActivityType(rawValue: activity) else {
            return
        }
        
        self.artefactViews[activityType]?.stopStageAnimation()
        self.artefactViews[activityType]?.isHidden = true
    }

    @objc func didArchiveSuccesfully(_ aNotification: Notification) {
        
        guard let project = aNotification.userInfo?["project"] as? Project else {
            return
        }
        
        let archive = Archive.make(forProject: project, name: project.scheme)
        
        let info = archive.info
        
        self.archiveView.titleTextField.stringValue = info.name
        self.archiveView.versionTextField.stringValue = "\(info.bundleShortVersion) (\(info.bundleVersion))"
        let creationDate = info.creationDate ?? Date()
        
        self.archiveView.dateTextField.stringValue = self.dateFormatter.string(from: creationDate)
        self.archiveView.archive = archive
        self.archiveView.isHidden = false
    }
    
    @objc func didExportSuccesfully(_ aNotification: Notification) {

        guard let project = aNotification.userInfo?["project"] as? Project else {
            return
        }
        
        self.exportView.export = Export.make(forProject: project)
        self.exportView.metadata = MetadataJSONEncoded.testMetadata(for: project)
        self.exportView.isHidden = false
    }
    
    @objc func didDeploySuccesfully(_ aNotification: Notification) {
        
        guard let project = aNotification.userInfo?["project"] as? Project else {
            return
        }
        
        self.deployView.export = Export.make(forProject: project)
        self.deployView.metadata = MetadataJSONEncoded.testMetadata(for: project)
        
        self.deployView.isHidden = false
    }

}
