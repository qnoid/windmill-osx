//
//  WarnSummariesViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 14/05/2019.
//  Copyright © 2019 qnoid.com. All rights reserved.
//

import Cocoa

class WarnSummariesView: NSView {
    override var intrinsicContentSize: NSSize {
        return NSSize(width: 329, height: 240)
    }
}

protocol WarnSummariesViewControllerDelegate: class {
    func didSelect(_ errorSummariesViewController: WarnSummariesViewController, warnSummary: WarnSummary)
}

class WarnSummariesViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSMenuDelegate, SummariesViewController {
    
    enum WarnSummaryIdentifier: String {
        
        static var allValues: [WarnSummaryIdentifier] = [.IssueType, .Message, .RecoverySuggestion]
        
        case IssueType
        case Message
        case RecoverySuggestion
    }
    
    
    @IBOutlet weak var tableView: NSTableView! {
        didSet{
            tableView.allowsMultipleSelection = false
        }
    }
    
    @IBOutlet weak var tableViewHeaderMenu: NSMenu! {
        didSet{
            WarnSummaryIdentifier.allValues.forEach { (warnSummaryIdentifier) in
                
                guard warnSummaryIdentifier != .Message else {
                    return
                }
                
                let menuItem = NSMenuItem(title: warnSummaryIdentifier.rawValue, action:  #selector(self.didSelect(menuItem:)), keyEquivalent: "")
                menuItem.identifier = NSUserInterfaceItemIdentifier(rawValue: warnSummaryIdentifier.rawValue)
                menuItem.state = .on
                tableViewHeaderMenu.addItem(menuItem)
            }
        }
    }
    
    weak var delegate: WarnSummariesViewControllerDelegate?
    
    var warnSummaries: [WarnSummary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        tableView.reloadData()
    }
    
    private func updateOrHide(viewFor tableColumn: NSTableColumn?, tableCellView: NSTableCellView, value: String?) {
        if let value = value {
            tableCellView.textField?.stringValue = value
        } else {
            tableColumn?.isHidden = true
        }
    }
    
    // MARK: NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return warnSummaries.count
    }
    
    // MARK: NSTableViewDelegate
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let identifier = tableColumn?.identifier else {
            return nil
        }
        
        let tableCellView = tableView.makeView(withIdentifier: identifier, owner: self) as! NSTableCellView
        tableColumn?.isHidden = false
        
        let warnSummaryIdentifier = WarnSummaryIdentifier(rawValue: identifier.rawValue)
        
        if case WarnSummaryIdentifier.IssueType? = warnSummaryIdentifier {
            self.updateOrHide(viewFor: tableColumn, tableCellView: tableCellView, value: warnSummaries[row].issueType)
        } else if case WarnSummaryIdentifier.Message? = warnSummaryIdentifier {
            self.updateOrHide(viewFor: tableColumn, tableCellView: tableCellView, value: warnSummaries[row].message)
        }

        tableCellView.toolTip = warnSummaries[row].recoverySuggestion ?? ""
        
        return tableCellView
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let sender = notification.object as? NSTableView else {
            return
        }
        self.tableViewDidSelectRow(sender)
    }
    
    @IBAction func tableViewDidSelectRow(_ sender: NSTableView) {
        
        guard tableView.selectedRow >= 0 && tableView.selectedRow < warnSummaries.count else {
            return
        }
        
        let warnSummary = warnSummaries[tableView.selectedRow]
        
        self.delegate?.didSelect(self, warnSummary: warnSummary)
    }
    
    
    @objc func didSelect(menuItem: NSMenuItem) {
        menuItem.state = (menuItem.state == .on) ? .off : .on
        
        guard let identifier = menuItem.identifier else {
            return
        }
        
        let column = tableView.tableColumn(withIdentifier: identifier)
        column?.isHidden = menuItem.state == .off ? true : false
    }
}
