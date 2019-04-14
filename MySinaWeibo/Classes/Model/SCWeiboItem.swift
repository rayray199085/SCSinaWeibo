
//
//  SCWeiboItem.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 24/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit
import YYModel
/// model for loading weibo items
/// @objc should be added before the definition of attributes
/// yy model cannot get the data without the symbol
class SCWeiboItem: NSObject {
    @objc var created_at : String?{
        didSet{
            createdDate = Date.sinaDateWithString(timeString: created_at ?? "")
        }
    }
    @objc var createdDate: Date?
    @objc var source : String?
    @objc var id : Int64 = 0
    @objc var text : String?
    @objc var user : SCUserItem?
    @objc var reposts_count : Int = 0
    @objc var comments_count : Int = 0
    @objc var attitudes_count : Int = 0
    @objc var pic_urls: [SCPictureItem]?
    @objc var retweeted_status: SCWeiboItem?
    
    override var description: String{
        return yy_modelDescription()
    }
    @objc class func modelContainerPropertyGenericClass()->[String:AnyClass]{
        return ["pic_urls": SCPictureItem.self]
    }
}
