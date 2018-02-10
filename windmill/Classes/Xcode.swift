//
//  Xcode.swift
//  windmill
//
//  Created by Markos Charatzas on 22/08/2017.
//  Copyright © 2017 qnoid.com. All rights reserved.
//

import Foundation

extension FileManager {
    
    var xcodeArchivesURL: URL {
        let directory = self.directory(self.urls(for: .libraryDirectory, in: .userDomainMask)[0].appendingPathComponent("Developer/Xcode/Archives"))
        
        directory.create()
        
        return directory.URL
    }
}
