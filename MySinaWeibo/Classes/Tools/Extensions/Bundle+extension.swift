//
//  Bundle+extension.swift
//  Reflect
//
//  Created by Stephen Cao on 21/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import Foundation

extension Bundle{
    /// return Bundle Name
    var nameSpace :String{
        return infoDictionary?["CFBundleName"] as? String ?? ""
    }
    var currentVersion : String{
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
}
