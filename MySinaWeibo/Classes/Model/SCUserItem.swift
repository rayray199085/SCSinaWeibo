//
//  SCUserItem.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 28/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit
import YYModel
/// user information model
class SCUserItem: NSObject {
    @objc var id: Int64 = 0
    @objc var screen_name: String?
    @objc var profile_image_url: String?
    // -1 no verified, 0 normal, 2,3,5 enterprise, 220 star
    @objc var verified_type :Int = -1
    @objc var mbrank: Int = 0
    override var description: String{
        return yy_modelDescription()
    }
}
