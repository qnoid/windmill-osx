//
//  NSView+Windmill.swift
//  windmill
//
//  Created by Markos Charatzas on 14/08/2017.
//  Copyright © 2017 qnoid.com. All rights reserved.
//

import AppKit

enum Layout {
    case centered
    
    func layout(superView: NSView, subView: NSView) {
        superView.topAnchor.constraint(equalTo: subView.topAnchor).isActive = true
        superView.bottomAnchor.constraint(equalTo: subView.bottomAnchor).isActive = true
        superView.leadingAnchor.constraint(equalTo: subView.leadingAnchor).isActive = true
        superView.trailingAnchor.constraint(equalTo: subView.trailingAnchor).isActive = true
    }
}

extension NSView {
    
    func wml_load<T: NSView>(view: T.Type) -> NSView? {
        
        var topLevelObjects = NSArray()
        Bundle(for: type(of: self)).loadNibNamed(String(describing: view), owner: self, topLevelObjects: &topLevelObjects)
        
        for object in topLevelObjects {
            if let containerView = object as? NSView {
                return containerView
            }
        }
        
        return nil
    }
    
    func wml_addSubview(view: NSView, layout: Layout) {
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
