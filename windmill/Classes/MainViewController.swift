//
//  ProjectDetailViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 20/03/2016.
//  Copyright © 2016 qnoid.com. All rights reserved.
//

import AppKit
import os

extension CALayer {
    
    struct Windmill {
        
        static func positionAnchorPoint(_ layer: CALayer, anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)) {
            let frame = layer.frame
            layer.anchorPoint = anchorPoint
            layer.frame = frame
        }
    }
}

extension NSView {
    
    func startAnimation() {
        self.layer?.add(CAAnimation.Windmill.spinAnimation, forKey: "spinAnimation")
    }
    
    func stopAnimation() {
        self.layer?.removeAnimation(forKey: "spinAnimation")
    }
}

@IBDesignable
class MainView: NSView {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.wantsLayer = true
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.wantsLayer = true
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
    }
    
    override var intrinsicContentSize: NSSize {
        return NSSize(width: 850, height: 524)
    }
}

class MainViewController: NSViewController {
    
    @IBOutlet var windmillImageView: NSImageView! {
        didSet{
            windmillImageView.wantsLayer = true
            windmillImageView.toolTip = NSLocalizedString("windmill.toolTip", comment: "")
        }
    }
    
    @IBOutlet weak var activityTextfield: NSTextField! {
        didSet {
            activityTextfield.stringValue = NSLocalizedString("windmill.ui.activityTextfield.idle", comment: "")
        }
    }
    @IBOutlet weak var checkoutActivityView: ActivityView!
    @IBOutlet weak var buildActivityView: ActivityView!
    @IBOutlet weak var testActivityView: ActivityView!
    @IBOutlet weak var archiveActivityView: ActivityView!
    @IBOutlet weak var exportActivityView: ActivityView!
    @IBOutlet weak var deployActivityView: ActivityView!
    
    weak var topConstraint: NSLayoutConstraint!
    
    lazy var activityViews: [ActivityType: ActivityView] = { [unowned self] in
        return [.checkout: self.checkoutActivityView, .build: self.buildActivityView, .test: self.testActivityView, .archive: self.archiveActivityView, .export: self.exportActivityView, .deploy: self.deployActivityView]
    }()
    
    @IBOutlet weak var archiveView: ArchiveView!
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("dd/MM/YYYY, HH:mm")
        
        return dateFormatter
    }()

    let defaultCenter = NotificationCenter.default
    
    var project: Project?
    
    static func make() -> MainViewController {
        let mainStoryboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: Bundle(for: MainViewController.self))
        
        return mainStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: String(describing: MainViewController.self))) as! MainViewController
    }
    
    override func updateViewConstraints() {
        
        if(self.topConstraint == nil) {        
            if let topAnchor = (self.windmillImageView.window?.contentLayoutGuide as AnyObject).topAnchor {
                topConstraint = self.windmillImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20)
                topConstraint.isActive = true
            }
        }
        
        super.updateViewConstraints()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        CALayer.Windmill.positionAnchorPoint(self.windmillImageView.layer!)
    }
    
    override func loadView() {
        super.loadView()
        
        self.view.window?.addTitlebarAccessoryViewController(ProjectTitlebarAccessoryViewController())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.defaultCenter.addObserver(self, selector: #selector(MainViewController.windmillWillDeployProject(_:)), name: Windmill.Notifications.willDeployProject, object: nil)
        self.defaultCenter.addObserver(self, selector: #selector(MainViewController.activityDidLaunch(_:)), name: Process.Notifications.activityDidLaunch, object: nil)
        self.defaultCenter.addObserver(self, selector: #selector(MainViewController.activityError(_:)), name: Process.Notifications.activityError, object: nil)
        self.defaultCenter.addObserver(self, selector: #selector(MainViewController.activityDidExitSuccesfully(_:)), name: Process.Notifications.activityDidExitSuccesfully, object: nil)
        self.defaultCenter.addObserver(self, selector: #selector(MainViewController.didArchiveSuccesfully(_:)), name: Notification.Name("archive"), object: nil)
    }
    
    @objc func windmillWillDeployProject(_ aNotification: Notification) {
        guard let project = aNotification.object as? Project else {
            return
        }
        
        self.project = project
        
        self.windmillImageView.startAnimation()
        self.windmillImageView.toolTip = NSLocalizedString("windmill.toolTip.active", comment: "")
        self.view.window?.title = project.name        
        for activityView in self.activityViews.values {
            activityView.isHidden = true
        }
        self.archiveView.isHidden = true
        
        let projectTitlebarAccessoryViewController = self.view.window?.titlebarAccessoryViewControllers[0] as! ProjectTitlebarAccessoryViewController
        projectTitlebarAccessoryViewController.project = project        
    }
    
    @objc func activityDidLaunch(_ aNotification: Notification) {
        guard let activity = aNotification.userInfo?["activity"] as? String, let activityType = ActivityType(rawValue: activity) else {
            return
        }
        
        let log = OSLog(subsystem: "io.windmill.windmill", category: activityType.rawValue)
        os_log("%{public}@", log: log, type: .debug, activityType.description)
        
        self.windmillImageView.image = NSImage(named: NSImage.Name(rawValue: activityType.imageName))
        self.activityViews[activityType]?.isHidden = false
        self.activityViews[activityType]?.alphaValue = 1.0
        self.activityViews[activityType]?.startLightsAnimation(activityType: activityType)
        
        self.activityTextfield.stringValue = activityType.description
    }

    @objc func activityError(_ aNotification: Notification) {
        let activityType = ActivityType(rawValue: aNotification.userInfo!["activity"] as! String)!
        let log = OSLog(subsystem: "io.windmill.windmill", category: activityType.rawValue)
        os_log("%{public}@", log: log, type: .error, activityType.description)
        
        self.windmillImageView.toolTip = NSLocalizedString("windmill.toolTip.error", comment: "")
        self.windmillImageView.stopAnimation()
        
        self.activityViews[activityType]?.alphaValue = 1.0
        self.activityViews[activityType]?.stopLightsAnimation()

        self.activityTextfield.stringValue = NSLocalizedString("windmill.ui.activityTextfield.stopped", comment: "")
    }

    @objc func activityDidExitSuccesfully(_ aNotification: Notification) {
        
        let activityType = ActivityType(rawValue: aNotification.userInfo!["activity"] as! String)!
        let log = OSLog(subsystem: "io.windmill.windmill", category: activityType.rawValue)
        os_log("%{public}@", log: log, type: .debug, activityType.description)

        self.activityViews[activityType]?.alphaValue = 1.0
        self.activityViews[activityType]?.stopLightsAnimation()
    }
    
    @objc func didArchiveSuccesfully(_ aNotification: Notification) {

        guard let project = aNotification.userInfo?["project"] as? Project else {
            return
        }

        do {
            let archive = try Archive.make(forProject: project, name: project.scheme)
            
            let info = archive.info
            
            self.archiveView.titleTextField.stringValue = info.name
            self.archiveView.versionTextField.stringValue = "\(info.bundleShortVersion) (\(info.bundleVersion))"
            let creationDate = info.creationDate ?? Date()
            
            self.archiveView.dateTextField.stringValue = self.dateFormatter.string(from: creationDate)
            self.archiveView.archive = archive
            self.archiveView.isHidden = false
        }
        catch let error as NSError {
            os_log("%{public}@", log:.default, type: .error, error)
        }
    }
    
    @discardableResult func cleanBuildFolder() -> Bool {
        
        guard let project = self.project else {
            return false
        }
        
        do {
            let url = FileManager.default.buildDirectoryURL(forProject: project.name).appendingPathComponent("/Build")
            try FileManager.default.removeItem(at: url)
            return true
        } catch let error as NSError {
            os_log("%{public}@", log:.default, type: .error, error)
            return false
        }
    }
    
    @discardableResult func cleanProjectFolder() -> Bool {

        guard let project = self.project else {
            return false
        }

        do {
            try FileManager.default.removeItem(at: project.directoryPathURL)
            return true
        } catch let error as CocoaError {
            guard let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? POSIXError, underlyingError.code == POSIXError.ENOTEMPTY else {
                return false
            }
            
            try? FileManager.default.removeItem(at: project.directoryPathURL)
            return true
        } catch let error as NSError {
            os_log("%{public}@", log:.default, type: .error, error)
            return false
        }
    }    
}
