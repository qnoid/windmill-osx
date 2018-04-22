//
//  RepositoryTest.swift
//  windmillTests
//
//  Created by Markos Charatzas on 22/4/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import XCTest

@testable import Windmill

class RepositoryTest: XCTestCase {

    let bundle: Bundle = Bundle(for: RepositoryTest.self)

    func testExample() {
        
        let repositoryLocalURL = URL(fileURLWithPath: "/Users/qnoid/Developer/workspace/swift/windmill-osx/windmillTests/Resources/projects/helloworld/helloworld.xcodeproj")
        
        let commit = try? Repository.parse(localGitRepoURL: repositoryLocalURL)
        
        XCTAssertEqual("master", commit?.branch)
        XCTAssertEqual("git@github.com:qnoid/helloworld.git", commit?.repository.origin)
    }

    func testExample2() {

        let repositoryLocalURL = URL(fileURLWithPath: "/Users/qnoid/Developer/workspace/swift/windmill-osx/windmillTests/Resources/projects/project-not-at-root/iOS/project-not-at-root.xcodeproj")

        let commit = try? Repository.parse(localGitRepoURL: repositoryLocalURL)
        
        XCTAssertEqual("master", commit?.branch)
        XCTAssertEqual("git@github.com:qnoid/project-not-at-root.git", commit?.repository.origin)
    }
    
    func testExample3() {
        
        let projectURL = URL(fileURLWithPath: "/Users/qnoid/Library/Caches/io.windmill.windmill/Sources/project-not-at-root/iOS")
        let repositoryLocalURL = URL(fileURLWithPath: "/Users/qnoid/Library/Caches/io.windmill.windmill/Sources/project-not-at-root/iOS/project-not-at-root.xcodeproj")
        
        let localGitRepoURL = projectURL.appendingPathComponent("project-not-at-root.xcodeproj")
        let commit = try? Repository.parse(localGitRepoURL: localGitRepoURL)
        
        XCTAssertEqual("master", commit?.branch)
        XCTAssertEqual("git@github.com:qnoid/project-not-at-root.git", commit?.repository.origin)
    }

}
