//
//  GettingStartedWindowController.swift
//  windmill
//
//  Created by Markos Charatzas on 30/1/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Foundation
import Cocoa
import AVKit
import os

class GettingStartedWindowController: NSWindowController {

    static func make() -> GettingStartedWindowController {
        return GettingStartedWindowController(windowNibName: NSNib.Name(String(describing: self)))
    }
    
    @IBOutlet weak var playerView: AVPlayerView! {
        didSet{
            guard let url = Bundle(for: GettingStartedWindowController.self).url(forResource: "getting-started", withExtension: "mp4") else {
                os_log("Failed to load getting started video.", log: .default, type: .error)
                return
            }
            
            let player = AVPlayer(url: url)
            playerView.player = player
        }
    }
    override func windowDidLoad() {
        super.windowDidLoad()
    }
}
