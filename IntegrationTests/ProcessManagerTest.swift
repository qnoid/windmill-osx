//
//  ProcessManagerTest.swift
//  IntegrationTests
//
//  Created by Markos Charatzas (markos@qnoid.com) on 12/03/2019.
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

import XCTest

@testable import Windmill

class ProcessManagerTest: XCTestCase {

    /**
     - Precondition: requires internet connection
     */
    func testGivenNameWithWhitespacesAssertSuccess() {
        let manager = ProcessManager()
        let repoName = "with white space"
        let validOrigin = "git@github.com:windmill-io/blank.git"
        let checkoutDirectory: Directory = FileManager.default.directory(FileManager.default.trashDirectoryURL.appendingPathComponent(CharacterSet.Windmill.random(characters: CharacterSet.lowercaseLetters, length: 16)))
        
        let process = Process.makeCheckout(sourceDirectory: checkoutDirectory, project: Project(isWorkspace: false, name: repoName, scheme: "foo", origin: validOrigin), log: FileManager.default.trashDirectoryURL.appendingPathComponent(CharacterSet.Windmill.random()))
        
        defer {
            var trashDirectory = FileManager.default.trashDirectoryURL
            try? FileManager.default.removeItem(at: trashDirectory.appendingPathComponent(repoName))
        }
        
        let expectation = self.expectation(description: #function)
        
        manager.launch(process: process, wasSuccesful: { _ in
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 5.0)
    }
}
