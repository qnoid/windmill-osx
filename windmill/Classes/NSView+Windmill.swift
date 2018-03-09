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
    return wml_load(name: NSNib.Name(rawValue: String(describing: view)))
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
