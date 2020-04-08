//
//  SidePanelSplitViewController.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 27/08/2017.
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

import AppKit

class SidePanelSplitViewController: NSSplitViewController {
    
    @IBOutlet weak var mainViewSplitViewItem: NSSplitViewItem!
    @IBOutlet weak var sideViewSplitViewItem: NSSplitViewItem! {
        didSet{
            sideViewSplitViewItem.canCollapse = true
        }
    }

    var bottomPanelSplitViewController: BottomPanelSplitViewController? {
        return self.children[0] as? BottomPanelSplitViewController
    }
    
    var mainViewController: MainViewController? {
        return self.bottomPanelSplitViewController?.mainViewController
    }
    
    var sidePanelViewController: SidePanelViewController? {
        return self.children[1] as? SidePanelViewController
    }
    
    var isSidePanelHidden: Bool {
        get {
            return self.sideViewSplitViewItem.isCollapsed
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func toggleSidePanel(isCollapsed: Bool? = nil, completionHandler: @escaping (_ isHidden: Bool) -> Void = {_ in }) {
        NSAnimationContext.runAnimationGroup({ _ in
            self.toggleSidebar(self)
        }, completionHandler: {
            completionHandler(self.isSidePanelHidden)
        })
    }
    
    func onCollapsed(changeHandler: @escaping (NSSplitViewItem, NSKeyValueObservedChange<Bool>) -> Void) -> NSKeyValueObservation {
        return sideViewSplitViewItem.observe(\.isCollapsed, options: [.initial, .new], changeHandler: changeHandler)
    }
}
