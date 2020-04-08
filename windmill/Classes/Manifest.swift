//
//  Manifest.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 27/04/2019.
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

import Foundation

public struct Manifest {
    
    public static func make(at url: URL) -> Manifest {
        return Manifest(metadata: MetadataPlistEncoded(url: url))
    }
    
    private let metadata: Metadata
    let url: URL
    
    init(metadata: Metadata) {
        self.metadata = metadata
        self.url = metadata.url
    }
    
    var items:[String:Any]? {
        let items:[[String:Any]]? = metadata["items"]
        
        return items?[0]
    }
    
    var bundleIdentifier: String {
        let metadata = items?["metadata"] as? [String: String]
        
        return metadata?["bundle-identifier"] ?? ""
    }
    
    var bundleVersion: String {
        let metadata = items?["metadata"] as? [String: String]
        
        return metadata?["bundle-version"] ?? ""
    }
    
    var title: String {
        let metadata = items?["metadata"] as? [String: String]
        
        return metadata?["title"] ?? ""
    }
}
