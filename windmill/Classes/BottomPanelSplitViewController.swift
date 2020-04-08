//
//  BottomPanelSplitViewController.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 16/1/18.
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

class BottomPanelSplitViewController: NSSplitViewController {
    
    @IBOutlet weak var mainViewSplitViewItem: NSSplitViewItem!
    @IBOutlet weak var bottomViewSplitViewItem: NSSplitViewItem! {
        didSet{
            bottomViewSplitViewItem.minimumThickness = 150
            bottomViewSplitViewItem.canCollapse = true
            bottomViewSplitViewItem.isCollapsed = true
        }
    }
    
    var mainViewController: MainViewController? {
        return self.children[0] as? MainViewController
    }

    var bottomViewController: BottomTabViewController? {
        return self.children[1] as? BottomTabViewController
    }

    var isBottomPanelCollapsed: Bool {
        get {
            return self.bottomViewSplitViewItem.isCollapsed
        }
    }
    
    func toggleBottomPanel(isCollapsed: Bool? = nil, completionHandler: @escaping (_ isHidden: Bool) -> Void = {_ in }) {
        NSAnimationContext.runAnimationGroup({ [weak self] _ in
            guard let self = self else {
                return
            }
            
            self.bottomViewSplitViewItem.animator().isCollapsed = isCollapsed ?? !self.isBottomPanelCollapsed
            self.bottomViewController?.consoleViewController?.toggle(isHidden: self.isBottomPanelCollapsed)
            self.bottomViewController?.prettyConsoleViewController?.toggle(isHidden: self.isBottomPanelCollapsed)
        }, completionHandler: { [weak self] in
            guard let self = self else {
                return
            }

            self.bottomViewController?.consoleViewController?.toggle(isHidden: self.isBottomPanelCollapsed)
            self.bottomViewController?.prettyConsoleViewController?.toggle(isHidden: self.isBottomPanelCollapsed)
            completionHandler(self.isBottomPanelCollapsed)
        })
    }
    
    func onCollapsed(changeHandler: @escaping (NSSplitViewItem, NSKeyValueObservedChange<Bool>) -> Void) -> NSKeyValueObservation {
        return bottomViewSplitViewItem.observe(\.isCollapsed, options: [.initial, .new], changeHandler: changeHandler)
    }
}
