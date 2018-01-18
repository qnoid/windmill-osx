//
//  SidePanelViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 26/08/2017.
//  Copyright © 2017 qnoid.com. All rights reserved.
//

import AppKit

@IBDesignable
class SidePanelView: NSView {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.wantsLayer = true
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
        self.layer?.backgroundColor = CGColor.black
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.wantsLayer = true
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
        self.layer?.backgroundColor = CGColor.black
    }
}

class SidePanelViewController: NSViewController {
    
    weak var gridView: NSGridView!
    
    // MARK: Checkout views
    lazy var checkout: NSTextField = {
        let checkout = NSTextField(labelWithString: "checkout")
        checkout.isHidden = true
        return checkout
    }()
    
    lazy var origin: NSTextField = {
        let origin = NSTextField(labelWithString: "Origin:")
        origin.isHidden = true
        return origin
    }()
    
    lazy var branch: NSTextField = {
        let branch = NSTextField(labelWithString: "Branch:")
        branch.isHidden = true
        return branch
    }()
    
    lazy var commit: NSTextField = {
        let commit = NSTextField(labelWithString: "Commit:")
        commit.isHidden = true
        return commit
    }()
    
    lazy var originValue: NSTextField = {
        let originValue = NSTextField(labelWithString: "")
        originValue.isHidden = true
        originValue.isSelectable = true
        return originValue
    }()
    
    lazy var branchValue: NSTextField = {
        let branchValue = NSTextField(labelWithString: "")
        branchValue.isHidden = true
        branchValue.isSelectable = true
        return branchValue
    }()
    
    lazy var commitValue: NSTextField = {
        let commitValue = NSTextField(labelWithString: "")
        commitValue.isHidden = true
        commitValue.isSelectable = true
        return commitValue
    }()
    
    // MARK: Build views
    
    lazy var build: NSTextField = {
        let build = NSTextField(labelWithString: "build")
        build.isHidden = true
        return build
    }()
    
    lazy var buildConfiguration: NSTextField = {
        let buildConfiguration = NSTextField(labelWithString: "Configuration:")
        buildConfiguration.isHidden = true
        return buildConfiguration
    }()
    
    lazy var buildConfigurationValue: NSTextField = {
        let buildConfigurationValue = NSTextField(labelWithString: "Debug")
        buildConfigurationValue.isHidden = true
        buildConfigurationValue.isSelectable = true
        return buildConfigurationValue
    }()
    
    // MARK: Test views
    
    lazy var test: NSTextField = {
        let test = NSTextField(labelWithString: "test")
        test.isHidden = true
        return test
    }()
    
    lazy var deploymentTarget: NSTextField = {
        let deploymentTarget = NSTextField(labelWithString: "iOS Deployment Target:")
        deploymentTarget.isHidden = true
        return deploymentTarget
    }()
    
    lazy var deploymentTargetValue: NSTextField = {
        let deploymentTargetValue = NSTextField(labelWithString:  "10.3")
        deploymentTargetValue.isHidden = true
        deploymentTargetValue.isSelectable = true
        return deploymentTargetValue
    }()
    
    lazy var destination: NSTextField = {
        let destination = NSTextField(labelWithString: "Destination:")
        destination.isHidden = true
        return destination
    }()
    
    lazy var destinationValue: NSTextField = {
        let destinationValue = NSTextField(labelWithString:  "iOS Simulator (iPhone SE)")
        destinationValue.isHidden = true
        destinationValue.isSelectable = true
        
        return destinationValue
    }()
    
    // MARK: Archive views
    
    lazy var archive: NSTextField = {
        let archive = NSTextField(labelWithString: "archive")
        archive.isHidden = true
        return archive
    }()
    
    lazy var archiveConfiguration: NSTextField = {
        let archiveConfiguration = NSTextField(labelWithString: "Configuration:")
        archiveConfiguration.isHidden = true
        return archiveConfiguration
    }()
    
    lazy var archiveConfigurationValue: NSTextField = {
        let archiveConfigurationValue = NSTextField(labelWithString: "Release")
        archiveConfigurationValue.isHidden = true
        archiveConfigurationValue.isSelectable = true
        return archiveConfigurationValue
    }()
    
    
    // MARK: Export views
    lazy var export: NSTextField = {
        let export = NSTextField(labelWithString: "export")
        export.isHidden = true
        return export
    }()
    
    lazy var certificate: NSTextField = {
        let certificate = NSTextField(labelWithString: "Signing Certificate:")
        certificate.isHidden = true
        return certificate
    }()
    
    lazy var certificateValue: NSTextField = {
        let certificateValue = NSTextField(labelWithString:  "iOS Distribution: Markos Charatzas (AQ2US2UQQ7)")
        certificateValue.isHidden = true
        certificateValue.isSelectable = true
        return certificateValue
    }()
    
    lazy var provisioning: NSTextField = {
        let provisioning = NSTextField(labelWithString:  "Provisioning Profile:")
        provisioning.isHidden = true
        return provisioning
    }()
    
    lazy var provisioningValue: NSTextField = {
        let provisioningValue = NSTextField(labelWithString: "iOS Team Ad Hoc Provisioning Profile: io.windmill.windmill")
        provisioningValue.isHidden = true
        provisioningValue.isSelectable = true
        return provisioningValue
    }()
    
    // MARK: Deploy views
    lazy var deploy: NSTextField = {
        let deploy = NSTextField(labelWithString: "deploy")
        deploy.isHidden = true
        return deploy
    }()
    
    lazy var acccount: NSTextField = {
        let acccount = NSTextField(labelWithString: "Account:")
        acccount.isHidden = true
        return acccount
    }()
    
    lazy var accountValue: NSTextField = {
        let accountValue = NSTextField(labelWithString: try! Keychain.defaultKeychain().findWindmillUser())
        accountValue.isHidden = true
        accountValue.isSelectable = true
        return accountValue
    }()
    
    weak var topConstraint: NSLayoutConstraint!
    
    lazy var checkoutSection: (origin: NSTextField, branch: NSTextField, commit: NSTextField) = { [unowned self] in
        return (origin: self.origin, branch: self.branch, commit: self.commit)
        }()
    
    lazy var checkoutValues: (originValue: NSTextField, branchValue: NSTextField, commitValue: NSTextField) = { [unowned self] in
        return (originValue: self.originValue, branchValue: self.branchValue, commitValue: self.commitValue)
        }()
    
    let defaultCenter = NotificationCenter.default
    
    var project: Project?
    
    override func updateViewConstraints() {
        
        if(self.topConstraint == nil) {
            if let topAnchor = (self.view.window?.contentLayoutGuide as AnyObject).topAnchor {
                topConstraint = self.gridView.topAnchor.constraint(equalTo: topAnchor, constant: 0)
                topConstraint.isActive = true
            }
        }
        
        super.updateViewConstraints()
    }
    
    private func layout() {
        
        let empty = NSGridCell.emptyContentView
        
        let gridView = NSGridView(views: [
            [checkout, empty],
            [origin, originValue],
            [branch, branchValue],
            [commit, commitValue],
            [build, empty],
            [buildConfiguration, buildConfigurationValue],
            [test, empty],
            [deploymentTarget, deploymentTargetValue],
            [destination, destinationValue],
            [archive, empty],
            [archiveConfiguration, archiveConfigurationValue],
            [export, empty],
            [certificate, certificateValue],
            [provisioning, provisioningValue],
            [deploy, empty],
            [acccount, accountValue]
            ])
        
        self.view.wml_addSubview(view: gridView, layout: .equalWidth)
        self.gridView = gridView
        
        gridView.column(at: 0).xPlacement = .trailing
        gridView.rowAlignment = .firstBaseline
        
        headerCell(for: checkout, cell:gridView.cell(for:checkout)!)
        headerCell(for: build, cell:gridView.cell(for:build)!)
        headerCell(for: test, cell:gridView.cell(for:test)!)
        headerCell(for: archive, cell:gridView.cell(for:archive)!)
        headerCell(for: export, cell:gridView.cell(for:export)!)
        headerCell(for: deploy, cell:gridView.cell(for:deploy)!)
    }
    
    func headerCell(for view: NSTextField, cell: NSGridCell) {
        cell.row!.topPadding = 10
        view.font = NSFont(name: view.font!.fontName, size: 18)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.layout()
        self.defaultCenter.addObserver(self, selector: #selector(SidePanelViewController.windmillWillDeployProject(_:)), name: Windmill.Notifications.willDeployProject, object: nil)
        self.defaultCenter.addObserver(self, selector: #selector(SidePanelViewController.activityDidLaunch(_:)), name: Process.Notifications.activityDidLaunch, object: nil)
        self.defaultCenter.addObserver(self, selector: #selector(MainViewController.activityDidExitSuccesfully(_:)), name: Process.Notifications.activityDidExitSuccesfully, object: nil)
    }
    
    @objc func windmillWillDeployProject(_ aNotification: Notification) {
        guard let project = aNotification.object as? Project else {
            return
        }
        
        self.project = project

        for activityView in self.gridView.subviews {
            activityView.isHidden = true
        }
    }
    
    @objc func activityDidLaunch(_ aNotification: Notification) {
        
        guard let activity = aNotification.userInfo?["activity"] as? String, let activityType = ActivityType(rawValue: activity) else {
            return
        }
        
        guard let project = project else {
            return
        }
        
        switch activityType {
        case .build:
            self.build.isHidden = false
            self.buildConfiguration.isHidden = false
            self.buildConfigurationValue.isHidden = false
            self.buildConfigurationValue.stringValue = Configuration.debug.name
        case .test:
            
            let metadata = MetadataJSONEncoded.testMetadata(for: project)
            
            self.test.isHidden = false
            let deployment:[String: String]? = metadata["deployment"]
            let destination:[String: String]? = metadata["destination"]
            
            self.deploymentTarget.isHidden = false
            self.deploymentTargetValue.isHidden = false
            self.deploymentTargetValue.stringValue = deployment?["target"] ?? ""
            self.destination.isHidden = false
            self.destinationValue.isHidden = false
            self.destinationValue.stringValue = destination?["name"] ?? ""
        case .archive:
            self.archive.isHidden = false
            self.archiveConfiguration.isHidden = false
            self.archiveConfigurationValue.isHidden = false
            self.archiveConfigurationValue.stringValue = Configuration.release.name
        default:
            break
        }
    }
    
    @objc func activityDidExitSuccesfully(_ aNotification: Notification) {
        
        
        guard let activity = aNotification.userInfo?["activity"] as? String, let activityType = ActivityType(rawValue: activity) else {
            return
        }
        
        guard let project = project else {
            return
        }
        
        switch activityType {
        case .checkout:
            let commit = try! Repository.of(project: project)
            
            self.checkout.isHidden = false
            
            self.checkoutSection.origin.isHidden = false
            self.checkoutValues.originValue.stringValue = commit.repository.origin
            self.checkoutValues.originValue.isHidden = false
            self.checkoutSection.branch.isHidden = false
            self.checkoutValues.branchValue.stringValue = commit.branch
            self.checkoutValues.branchValue.isHidden = false
            self.checkoutSection.commit.isHidden = false
            self.checkoutValues.commitValue.stringValue = commit.shortSha
            self.checkoutValues.commitValue.isHidden = false
        case .export:
            let metadata = MetadataPlistEncoded.exportMetadata(for: project)
            let distributionOptions = DistributionOptions(project: project, metadata: metadata)
            
            self.export.isHidden = false
            self.certificate.isHidden = false
            self.certificateValue.isHidden = false
            self.certificateValue.stringValue = distributionOptions.certificateType
            
            self.provisioning.isHidden = false
            self.provisioningValue.isHidden = false
            self.provisioningValue.stringValue = distributionOptions.profileName
            
        case .deploy:
            self.deploy.isHidden = false
            self.acccount.isHidden = false
            self.accountValue.isHidden = false
        default:
            break
        }
    }
    
    func toggle(isHidden: Bool) {
        self.gridView?.isHidden = isHidden
    }
}
