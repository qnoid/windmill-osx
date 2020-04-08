//
//  TestSummariesViewController.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 22/3/18.
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

protocol TestSummariesViewControllerDelegate: class {
    func didSelect(_ testSummariesViewController: TestSummariesViewController, test: Test)
}

class TestSummariesViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {

    enum TestableSummaryIdentifier: String {
        
        static var allValues: [TestableSummaryIdentifier] = [.Name, .Duration]
        
        case Name
        case Duration
    }
    

    @IBOutlet weak var outlineView: NSOutlineView!
    
    weak var delegate: TestSummariesViewControllerDelegate?
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
//        formatter.minimumSignificantDigits = 1
        formatter.maximumFractionDigits = 3
        
        return formatter
    }()
    
    var testableSummaries: [TestableSummary] = [] {
        didSet{
            outlineView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.outlineView.reloadData()
        self.outlineView.expandItem(nil, expandChildren: true)
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return testableSummaries.count
        }
        
        if let testableSummary = item as? TestableSummary {
            return testableSummary.tests.actual.count
        }
        
        if let test = item as? Test {
            return test.subtests.count
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return testableSummaries[index]
        }
        
        if let testableSummary = item as? TestableSummary {
            return testableSummary.tests.actual[index] as AnyObject
        }
        
        if let test = item as? Test {
            return test.subtests[index]
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        
        if let testableSummary = item as? TestableSummary {
            return testableSummary.tests.count > 0
        }
        
        if let test = item as? Test {
            return test.subtests.count > 0
        }
        
        return testableSummaries.count > 0
    }
    
    // MARK: NSOutlineViewDelegate
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {

        guard let identifier = tableColumn?.identifier else {
            return nil
        }
        
        let tableCellView = outlineView.makeView(withIdentifier: identifier, owner: self) as! NSTableCellView
        tableCellView.translatesAutoresizingMaskIntoConstraints = false
        
        let testableSummaryIdentifier = TestableSummaryIdentifier(rawValue: identifier.rawValue)
        
        if case TestableSummaryIdentifier.Name? = testableSummaryIdentifier, let testCell = tableCellView as? TestSummaryCellView {
            testCell.statusImageView.image = nil
            testCell.toolTip = ""

            let level = outlineView.level(forItem: item)
            
            if let testableSummary = item as? TestableSummary {
                testCell.nameTextField.stringValue = testableSummary.testName
            } else if let test = item as? Test {
                testCell.nameTextField?.stringValue = test.testName
            }

            if case 0 = level {
                testCell.typeImageView.image = #imageLiteral(resourceName: "testtarget")
                testCell.nameTextField.lineBreakMode = .byTruncatingTail
            } else if case 1 = level {
                testCell.typeImageView.image = #imageLiteral(resourceName: "testcase")
                testCell.nameTextField.lineBreakMode = .byTruncatingMiddle
                testCell.toolTip = ""
            } else if case 2 = level, let test = item as? Test {
                if test.isPerformance {
                    testCell.typeImageView.image = #imageLiteral(resourceName: "pt-test")
                    testCell.typeImageView.toolTip = "Performance Test"
                } else {
                    testCell.typeImageView.image = #imageLiteral(resourceName: "test")
                    testCell.typeImageView.toolTip = "Functional Test"
                }
                testCell.statusImageView.image = test.testStatus?.image
                testCell.nameTextField.lineBreakMode = .byTruncatingHead
                testCell.toolTip = test.failureSummaries.first?.message
            }

        } else if case TestableSummaryIdentifier.Duration? = testableSummaryIdentifier {
            if let test = item as? Test {
                
                if test.isPerformance, let metric = test.performanceMetrics.first, let duration = try? test.average() {
                    tableCellView.textField?.stringValue = self.formatter.string(from: NSNumber(value: duration)) ?? ""
                    tableCellView.toolTip = "Average of \(test.iterations(metric: metric)) iterations ...in seconds."
                } else {
                    tableCellView.textField?.stringValue = self.formatter.string(from: test.duration) ?? ""
                    tableCellView.toolTip = "Total duration ...in seconds."
                }
                tableCellView.textField?.lineBreakMode = .byTruncatingTail
            } else {
                tableCellView.textField?.stringValue = "--"
            }
        }
        
        return tableCellView
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        
        if let test = item as? Test, test.testStatus == .failure {
            return true
        }
        
        return false
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        
        guard let outlineView = notification.object as? NSOutlineView else {
            return
        }
        
        guard outlineView.selectedRow >= 0 else {
            return
        }
        
        guard let test = outlineView.item(atRow: outlineView.selectedRow) as? Test else {
            return
        }

        self.delegate?.didSelect(self, test: test)
    }
}
