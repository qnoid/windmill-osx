//
//  ErrorSummariesViewController.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 4/3/18.
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

import Cocoa


class ErrorSummariesView: NSView {
    override var intrinsicContentSize: NSSize {
        return NSSize(width: 329, height: 240)
    }
}

protocol ErrorSummariesViewControllerDelegate: class {
    func didSelect(_ errorSummariesViewController: ErrorSummariesViewController, errorSummary: ResultBundle.ErrorSummary)
}

class ErrorSummariesViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSMenuDelegate, SummariesViewController {

    enum ErrorSummaryIdentifier: String {
        
        static var allValues: [ErrorSummaryIdentifier] = [.Branch, .Commit, .Target, .IssueType, .Message]
        
        case Branch
        case Commit
        case Target
        case IssueType
        case Message
    }

    
    @IBOutlet weak var tableView: NSTableView! {
        didSet{
            tableView.allowsMultipleSelection = false
        }
    }
    
    @IBOutlet weak var tableViewHeaderMenu: NSMenu! {
        didSet{
            ErrorSummaryIdentifier.allValues.forEach { (errorSummaryIdentifier) in
                
                guard errorSummaryIdentifier != .Message else {
                    return
                }
                
                let menuItem = NSMenuItem(title: errorSummaryIdentifier.rawValue, action:  #selector(self.didSelect(menuItem:)), keyEquivalent: "")
                menuItem.identifier = NSUserInterfaceItemIdentifier(rawValue: errorSummaryIdentifier.rawValue)
                menuItem.state = .on
                tableViewHeaderMenu.addItem(menuItem)
            }
        }
    }
    
    weak var delegate: ErrorSummariesViewControllerDelegate?
    
    let applicationCachesDirectory = Directory.Windmill.ApplicationCachesDirectory()
    var commit: Repository.Commit?
    var errorSummaries: [ResultBundle.ErrorSummary] = []
    
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
        return errorSummaries.count
    }
    
    // MARK: NSTableViewDelegate
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let identifier = tableColumn?.identifier else {
            return nil
        }
        
        let tableCellView = tableView.makeView(withIdentifier: identifier, owner: self) as! NSTableCellView
        tableColumn?.isHidden = false
        
        let errorSummaryIdentifier = ErrorSummaryIdentifier(rawValue: identifier.rawValue)
        
        if case ErrorSummaryIdentifier.Branch? = errorSummaryIdentifier {
            self.updateOrHide(viewFor: tableColumn, tableCellView: tableCellView, value: commit?.branch)
        } else if case ErrorSummaryIdentifier.Commit? = errorSummaryIdentifier {
            self.updateOrHide(viewFor: tableColumn, tableCellView: tableCellView, value: commit?.shortSha)
        } else if case ErrorSummaryIdentifier.Target? = errorSummaryIdentifier {
            self.updateOrHide(viewFor: tableColumn, tableCellView: tableCellView, value: errorSummaries[row].target)
        } else  if case ErrorSummaryIdentifier.IssueType? = errorSummaryIdentifier {
            self.updateOrHide(viewFor: tableColumn, tableCellView: tableCellView, value: errorSummaries[row].issueType)
        } else if case ErrorSummaryIdentifier.Message? = errorSummaryIdentifier {
            self.updateOrHide(viewFor: tableColumn, tableCellView: tableCellView, value: errorSummaries[row].message)
        }
        
        tableCellView.toolTip = errorSummaries[row].message ?? ""

        return tableCellView
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let sender = notification.object as? NSTableView else {
            return
        }
        self.tableViewDidSelectRow(sender)
    }
    
    @IBAction func tableViewDidSelectRow(_ sender: NSTableView) {
        
        guard tableView.selectedRow >= 0 && tableView.selectedRow < errorSummaries.count else {
            return
        }
        
        let errorSummary = errorSummaries[tableView.selectedRow]
        
        self.delegate?.didSelect(self, errorSummary: errorSummary)
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
