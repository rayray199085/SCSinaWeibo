//
//  SCPictureItem.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 28/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit

/// weibo picture model
class SCPictureItem: NSObject {
    @objc var large_pic :String?
    @objc var thumbnail_pic :String?{
        didSet{
            large_pic = thumbnail_pic?.replacingOccurrences(of: "/thumbnail/", with: "/large/")
            thumbnail_pic = thumbnail_pic?.replacingOccurrences(of: "/thumbnail/", with: "/wap360/")
        }
    }
    override var description: String{
        return yy_modelDescription()
    }
}
