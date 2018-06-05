//
//  ArtefactsViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 24/1/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Cocoa
import os

public enum ArtefactType
{
    case appBundle
    case testReport
    case archiveBundle
    case ipaFile
    case otaDistribution
}

@IBDesignable class ArtefactsViewControllerView: NSView {
    
    
}

class ArtefactsViewController: NSViewController {

    @IBOutlet weak var buildArtefactView: ArtefactView! {
        didSet {
            buildArtefactView.headerTextField.string = NSLocalizedString("windmill.artefacts.build.header", comment: "")
            buildArtefactView.toolTip = NSLocalizedString("windmill.artefacts.build.tooltip", comment: "")
            buildArtefactView.leadingLabel.stringValue = "Make sure:"
        }
    }
    @IBOutlet weak var testArtefactView: ArtefactView! {
        didSet {
            testArtefactView.headerTextField.string = NSLocalizedString("windmill.reports.test.header", comment: "")
            testArtefactView.toolTip = NSLocalizedString("windmill.reports.test.tooltip", comment: "")
            testArtefactView.leadingLabel.stringValue = "You need to:"
        }
    }
    @IBOutlet weak var archiveArtefactView: ArtefactView! {
        didSet {
            archiveArtefactView.headerTextField.string = NSLocalizedString("windmill.artefacts.archive.header", comment: "")
            archiveArtefactView.toolTip = NSLocalizedString("windmill.artefacts.archive.tooltip", comment: "")
        }
    }
    @IBOutlet weak var exportArtefactView: ArtefactView! {
        didSet {
            exportArtefactView.headerTextField.string = NSLocalizedString("windmill.artefacts.ipa.header", comment: "")
            exportArtefactView.toolTip = NSLocalizedString("windmill.artefacts.ipa.tooltip", comment: "")
            exportArtefactView.leadingLabel.stringValue = ""
        }
    }
    @IBOutlet weak var deployArtefactView: ArtefactView! {
        didSet {
            deployArtefactView.headerTextField.string = NSLocalizedString("windmill.aspects.ota.header", comment: "")
            deployArtefactView.leadingLabel.stringValue = "You need to:"
            deployArtefactView.toolTip = NSLocalizedString("windmill.aspects.ota.tooltip", comment: "")
        }
    }
    
    lazy var artefactViews: [ArtefactType: ArtefactView] = { [unowned self] in
        return [.appBundle: self.buildArtefactView, .testReport: self.testArtefactView, .archiveBundle: self.archiveArtefactView, .ipaFile: self.exportArtefactView, .otaDistribution: self.deployArtefactView]
        }()
    
    @IBOutlet weak var appView: AppView! {
        didSet {
            appView.toolTip = NSLocalizedString("windmill.artefacts.build.tooltip", comment: "")
        }
    }
    @IBOutlet weak var testReportView: TestReportView! {
        didSet {
            testReportView.toolTip = NSLocalizedString("windmill.reports.test.tooltip", comment: "")
        }
    }
    @IBOutlet weak var archiveView: ArchiveView! {
        didSet {
            archiveView.toolTip = NSLocalizedString("windmill.artefacts.archive.tooltip", comment: "")
        }
    }
    @IBOutlet weak var exportView: ExportView! {
        didSet {
            exportView.toolTip = NSLocalizedString("windmill.artefacts.ipa.tooltip", comment: "")
        }
    }
    @IBOutlet weak var deployView: DeployView! {
        didSet {
            deployView.toolTip = NSLocalizedString("windmill.aspects.ota.tooltip", comment: "")
        }
    }
    
    lazy var views: [ArtefactType: NSView] = { [unowned self] in
        return [.appBundle: self.appView, .testReport: self.testReportView, .archiveBundle: self.archiveView, .ipaFile: self.exportView, .otaDistribution: self.deployView]
        }()


    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("dd/MM/YYYY, HH:mm")
        
        return dateFormatter
    }()
    
    let defaultCenter = NotificationCenter.default
    
    weak var windmill: Windmill? {
        didSet{
            self.defaultCenter.addObserver(self, selector: #selector(willStartProject(_:)), name: Windmill.Notifications.willStartProject, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(didCheckoutProject(_:)), name: Windmill.Notifications.didCheckoutProject, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(activityDidLaunch(_:)), name: Windmill.Notifications.activityDidLaunch, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(activityError(_:)), name: Windmill.Notifications.didError, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(activityDidExitSuccesfully(_:)), name: Windmill.Notifications.activityDidExitSuccesfully, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(didBuildProject(_:)), name: Windmill.Notifications.didBuildProject, object: windmill)
            self.defaultCenter.addObserver(self, selector: #selector(didTestProject(_:)), name: Windmill.Notifications.didTestProject, object: windmill)
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
        for view in self.views.values {
            view.isHidden = true
        }
        
        self.testReportView.openButton.isHidden = true
    }

    @objc func activityDidLaunch(_ aNotification: Notification) {
        if let artefact = aNotification.userInfo?["artefact"] as? ArtefactType {
            self.artefactViews[artefact]?.startStageAnimation()
        }
    }

    @objc func activityError(_ aNotification: Notification) {
        guard let activity = aNotification.userInfo?["activity"] as? ActivityType, let artefact = aNotification.userInfo?["artefact"] as? ArtefactType  else {
            return
        }
        
        self.artefactViews[artefact]?.stopStageAnimation()
        
        switch activity {
        case .test:
            if let testsFailedCount = aNotification.userInfo?["testsFailedCount"] as? Int {
                self.artefactViews[artefact]?.isHidden = true                
                self.testReportView.testReport = .failure(testsFailedCount: testsFailedCount)
                self.testReportView.isHidden = false
            }

            guard let testableSummaries = aNotification.userInfo?["testableSummaries"] as? [TestableSummary] else {
                return
            }
            
            self.testReportView.openButton.isHidden = testableSummaries.count == 0

        default:
            return
        }
    }
    
    @objc func activityDidExitSuccesfully(_ aNotification: Notification) {
        
        if let artefact = aNotification.userInfo?["artefact"] as? ArtefactType {
            self.artefactViews[artefact]?.stopStageAnimation()
            self.artefactViews[artefact]?.isHidden = true
        }
    }

    @objc func didCheckoutProject(_ aNotification: Notification) {
        
        guard let commit = aNotification.userInfo?["commit"] as? Repository.Commit else {
            os_log("Commit for project not found.", log: .default, type: .debug)
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
    
    @objc func didTestProject(_ aNotification: NSNotification) {
        
        if let testsCount = aNotification.userInfo?["testsCount"] as? Int {
            self.testReportView.testReport = .success(testsCount: testsCount)
            self.testReportView.isHidden = false
        }

        guard let testableSummaries = aNotification.userInfo?["testableSummaries"] as? [TestableSummary] else {
            return
        }

        self.testReportView.openButton.isHidden = testableSummaries.count == 0
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

        if let appBundle = aNotification.userInfo?["appBundle"] as? AppBundle {
            self.deployView.appBundle = appBundle
        }
        
        self.deployView.isHidden = false
    }
}
