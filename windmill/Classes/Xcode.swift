//
//  Xcode.swift
//  windmill
//
//  Created by Markos Charatzas on 22/08/2017.
//  Copyright © 2017 qnoid.com. All rights reserved.
//

import Foundation


public class Xcode {
    public enum Build: String {
        case XCODE_10_2_BETA_1 = "10P82s"
        case XCODE_10_1 = "10B61"
    }
}

extension FileManager {
    
    var xcodeArchivesURL: URL {
        let directory = self.directory(self.urls(for: .libraryDirectory, in: .userDomainMask)[0].appendingPathComponent("Developer/Xcode/Archives"))
        
        directory.create()
        
        return directory.URL
    }
}
