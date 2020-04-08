//
//  NSView+Windmill.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 14/08/2017.
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

enum Layout {
    case centered
    case equalWidth
    
    func layout(superView: NSView, subView: NSView) {
        switch self {
        case .centered:
            superView.topAnchor.constraint(equalTo: subView.topAnchor).isActive = true
            superView.bottomAnchor.constraint(equalTo: subView.bottomAnchor).isActive = true
            superView.leadingAnchor.constraint(equalTo: subView.leadingAnchor).isActive = true
            superView.trailingAnchor.constraint(equalTo: subView.trailingAnchor).isActive = true
        case .equalWidth:
            superView.leadingAnchor.constraint(equalTo: subView.leadingAnchor).isActive = true
            superView.widthAnchor.constraint(equalTo: subView.widthAnchor).isActive = true
        }
    }
}

extension NSObject {
    
    func wml_load<T>(name: NSNib.Name) -> T? {
        
        var topLevelObjects: NSArray?
        Bundle(for: type(of: self)).loadNibNamed(name, owner: self, topLevelObjects: &topLevelObjects)
        
        guard let views = topLevelObjects else {
            return nil
        }
        
        for object in views {
            if let containerView = object as? T {
                return containerView
            }
        }
        
        return nil
    }
}

extension NSView {
    
    func wml_load<T: NSView>(view: T.Type) -> NSView? {
    return wml_load(name: String(describing: view))
    }
    
    func wml_addSubview(view: NSView, layout: Layout = .centered) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(view)
        layout.layout(superView: self, subView: view)
    }
    
    func wml_addSubview(view: NSView, layout: (_ view: NSView) -> Void) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(view)
        layout(view)
    }

}
