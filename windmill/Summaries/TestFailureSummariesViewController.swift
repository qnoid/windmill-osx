//
//  TestErrorSummariesViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 16/3/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import Cocoa

class TestFailureSummariesView: NSView {
    override var intrinsicContentSize: NSSize {
        return NSSize(width: 329, height: 240);
    }
}

protocol TestFailureSummariesViewControllerDelegate: class {
    func didSelect(_ errorSummariesViewController: TestFailureSummariesViewController, testFailureSummary: ResultBundle.TestFailureSummary)
    func doubleAction(_ errorSummariesViewController: TestFailureSummariesViewController, testFailureSummary: ResultBundle.TestFailureSummary)
}

class TestFailureSummariesViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSMenuDelegate, SummariesViewController {
    
    enum TestFailureSummaryIdentifier: String {
        
        static var allValues: [TestFailureSummaryIdentifier] = [.Branch, .Commit, .TestCase, .IssueType, .Message]
        
        case Branch
        case Commit
        case TestCase
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
            TestFailureSummaryIdentifier.allValues.forEach { (testFailureSummaryIdentifier) in
                
                guard testFailureSummaryIdentifier != .Message else {
                    return
                }
                
                let menuItem = NSMenuItem(title: testFailureSummaryIdentifier.rawValue, action:  #selector(self.didSelect(menuItem:)), keyEquivalent: "")
                menuItem.identifier = NSUserInterfaceItemIdentifier(rawValue: testFailureSummaryIdentifier.rawValue)
                menuItem.state = .on
                tableViewHeaderMenu.addItem(menuItem)
            }
        }
    }
    
    @IBOutlet weak var pathControl: NSPathControl! {
        didSet{
            pathControl.isEditable = false
        }
    }
    
    weak var delegate: TestFailureSummariesViewControllerDelegate?
    
    let applicationCachesDirectory = Directory.Windmill.ApplicationCachesDirectory()
    var commit: Repository.Commit?
    var testFailureSummaries: [ResultBundle.TestFailureSummary] = [] {
        didSet{
            pathControl.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        tableView.reloadData()
    }
    
    // MARK: NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return testFailureSummaries.count
    }
    
    // MARK: NSTableViewDelegate
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let identifier = tableColumn?.identifier else {
            return nil
        }
        
        let tableCellView = tableView.makeView(withIdentifier: identifier, owner: self) as! NSTableCellView
        
        let testFailureSummaryIdentifier = TestFailureSummaryIdentifier(rawValue: identifier.rawValue)
        
        if case TestFailureSummaryIdentifier.Branch? = testFailureSummaryIdentifier {
            tableCellView.textField?.stringValue = commit?.branch ?? ""
        } else if case TestFailureSummaryIdentifier.Commit? = testFailureSummaryIdentifier {
            tableCellView.textField?.stringValue = commit?.shortSha ?? ""
        } else if case TestFailureSummaryIdentifier.TestCase? = testFailureSummaryIdentifier {
            tableCellView.textField?.stringValue = testFailureSummaries[row].testCase
        } else  if case TestFailureSummaryIdentifier.IssueType? = testFailureSummaryIdentifier {
            tableCellView.textField?.stringValue = testFailureSummaries[row].issueType
        } else if case TestFailureSummaryIdentifier.Message? = testFailureSummaryIdentifier {
            tableCellView.textField?.stringValue = testFailureSummaries[row].message
        }
        
        tableCellView.toolTip = testFailureSummaries[row].message
        
        return tableCellView
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let sender = notification.object as? NSTableView else {
            return
        }
        self.tableViewDidSelectRow(sender)
    }
    
    @IBAction func tableViewDidSelectRow(_ sender: NSTableView) {
        
        guard tableView.selectedRow >= 0 && tableView.selectedRow < testFailureSummaries.count else {
            return
        }
        
        let testFailureSummary = testFailureSummaries[tableView.selectedRow]
        
        self.delegate?.didSelect(self, testFailureSummary: testFailureSummary)
        
        guard let documentURL = testFailureSummary.textDocumentLocation?.documentURL else{
            return
        }
        
        self.pathControl.isHidden = false
        let string = documentURL.path.replacingOccurrences(of: applicationCachesDirectory.sourcesURL().path, with: "")
        pathControl.url = URL(string: string)
        pathControl.pathItems.forEach { path in
            path.image = #imageLiteral(resourceName: "NavGroup")
        }
        pathControl.pathItems.first?.image = #imageLiteral(resourceName: "xcode-project_icon")
        pathControl.pathItems.last?.image = #imageLiteral(resourceName: "swift-source_Icon")
    }
    
    override func keyDown(with event: NSEvent) {
        
        switch event.keyCode {
        case 49: //space
            doubleAction(self.tableView)
        default:
            return
        }
    }
    
    @IBAction func doubleAction(_ sender: NSTableView) {
        
        guard tableView.selectedRow >= 0 && tableView.selectedRow < testFailureSummaries.count else {
            return
        }
        
        let testFailureSummary = testFailureSummaries[tableView.selectedRow]
        
        delegate?.doubleAction(self, testFailureSummary: testFailureSummary)
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

