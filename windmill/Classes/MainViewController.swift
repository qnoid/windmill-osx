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
        self.layer?.backgroundColor = NSColor.black.cgColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.wantsLayer = true
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
        self.layer?.backgroundColor = NSColor.black.cgColor
    }
}

class MainViewController: NSViewController, WindmillDelegate {
    
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
    
    @IBOutlet var textView: NSTextView! {
        didSet {
            textView.wantsLayer = true
            textView.isAutomaticSpellingCorrectionEnabled = false
            textView.isAutomaticQuoteSubstitutionEnabled = false
            textView.isAutomaticDashSubstitutionEnabled = false
            textView.isAutomaticTextReplacementEnabled = false
            textView.usesFontPanel = false
            textView.usesFindPanel = false
            textView.usesRuler = false
        }
    }
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
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
    var windmill: Windmill! {
        didSet {
            windmill.delegate = self
        }
    }
    
    var project: Project?
    var location: Int = 0
    var buffer: String = ""
    
    static func make() -> MainViewController {
        let mainStoryboard = NSStoryboard(name: "Main", bundle: Bundle(for: MainViewController.self))
        
        return mainStoryboard.instantiateController(withIdentifier: String(describing: MainViewController.self)) as! MainViewController
    }
    
    override func updateViewConstraints() {
        
        if(self.topConstraint == nil) {
        
            let topAnchor = (self.view.window?.contentLayoutGuide as AnyObject?)?.topAnchor
        
            let topConstraint = self.windmillImageView.topAnchor.constraint(equalTo: topAnchor!, constant: 20)
        
            topConstraint.isActive = true
        
            self.topConstraint = topConstraint
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
    
    func append(_ textView: NSTextView, output: String, count: Int) {
        
        self.buffer.append(output)
        self.location = self.location + count
        
        textView.string = self.buffer
        let range = NSRange(location:location,length:0)
        textView.scrollRangeToVisible(range)
    }
    
    func windmill(_ windmill: Windmill, standardOutput: String, count: Int) {
        self.append(self.textView, output: standardOutput, count: count)
    }
    
    func windmill(_ windmill: Windmill, standardError: String, count: Int) {
        self.append(self.textView, output: standardError, count: count)
    }

    
    func windmillWillDeployProject(_ aNotification: Notification) {
        let project = aNotification.object as! Project
        
        self.project = project
        
        self.buffer = ""
        self.location = 0
        self.textView.string = ""
        textView.isSelectable = false
        
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
    
    func activityDidLaunch(_ aNotification: Notification) {
        let activityType = ActivityType(rawValue: aNotification.userInfo!["activity"] as! String)!
        let log = OSLog(subsystem: "io.windmill.windmill", category: activityType.rawValue)
        os_log("%{public}@", log: log, type: .debug, activityType.description)
        
        self.windmillImageView.image = NSImage(named: activityType.imageName)
        self.activityViews[activityType]?.isHidden = false
        self.activityViews[activityType]?.alphaValue = 1.0
        self.activityViews[activityType]?.startLightsAnimation(activityType: activityType)
        
        self.activityTextfield.stringValue = activityType.description
    }

    func activityError(_ aNotification: Notification) {
        let activityType = ActivityType(rawValue: aNotification.userInfo!["activity"] as! String)!
        let log = OSLog(subsystem: "io.windmill.windmill", category: activityType.rawValue)
        os_log("%{public}@", log: log, type: .error, activityType.description)
        
        self.windmillImageView.toolTip = NSLocalizedString("windmill.toolTip.error", comment: "")
        self.windmillImageView.stopAnimation()
        
        self.activityViews[activityType]?.alphaValue = 0.1
        self.activityViews[activityType]?.imageView.layer?.removeAnimation(forKey: "lights")
        
        self.activityTextfield.stringValue = NSLocalizedString("windmill.ui.activityTextfield.stopped", comment: "")
        
        self.textViewHeightConstraint.animator().constant = 105
        self.textView.isSelectable = true
    }

    func activityDidExitSuccesfully(_ aNotification: Notification) {
        
        let activityType = ActivityType(rawValue: aNotification.userInfo!["activity"] as! String)!
        let log = OSLog(subsystem: "io.windmill.windmill", category: activityType.rawValue)
        os_log("%{public}@", log: log, type: .debug, activityType.description)

        self.activityViews[activityType]?.alphaValue = 1.0
        self.activityViews[activityType]?.stopLightsAnimation()
    }
    
    func didArchiveSuccesfully(_ aNotification: Notification) {
        let archive = aNotification.userInfo!["archive"] as! Archive
        let info = archive.info
        
        self.archiveView.titleTextField.stringValue = info.name
        self.archiveView.versionTextField.stringValue = "\(info.bundleShortVersion) (\(info.bundleVersion))"
        let creationDate = info.creationDate ?? Date()
        
        self.archiveView.dateTextField.stringValue = self.dateFormatter.string(from: creationDate)
        self.archiveView.archive = archive
        self.archiveView.isHidden = false
    }
    
    @discardableResult func cleanBuildFolder() -> Bool {
        
        guard let name = self.project?.name else {
            return false
        }
        
        do {
            let url = FileManager.default.windmillHomeDirectoryURL.appendingPathComponent("\(name)/build/Build")
            try FileManager.default.removeItem(at: url)
            return true
        } catch let error as NSError {
            os_log("%{public}@", log:.default, type: .error, error)
            return false
        }
    }
    
    @discardableResult func cleanProjectFolder() -> Bool {

        guard let name = self.project?.name else {
            return false
        }

        let url = FileManager.default.windmillHomeDirectoryURL.appendingPathComponent(name)
        
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch let error as NSError {
            os_log("%{public}@", log:.default, type: .error, error)
            return false
        }
    }
    
    @IBAction func toggleDebugArea(_ menuItem: NSMenuItem) {
        let isClosed = self.textViewHeightConstraint.constant == 0.0

        menuItem.title = isClosed ? NSLocalizedString("windmill.ui.toolbar.view.hideDebugArea", comment: "") : NSLocalizedString("windmill.ui.toolbar.view.showDebugArea", comment: "")
        self.textViewHeightConstraint.animator().constant = isClosed ? 105.0 : 0.0
        textView.isSelectable = isClosed
    }
}
