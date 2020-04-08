//
//  GettingStartedWindowController.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 30/1/18.
//  Copyright © 2014-2020 qnoid.com. All rights reserved.
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation is required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.
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
