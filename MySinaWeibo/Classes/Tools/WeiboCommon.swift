//
//  WeiboCommon.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 25/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import Foundation

//Mark: - global notification
let SCUserShouldLoginNotification = "SCUserShouldLoginNotification"
let SCUserLoginSuccessfullyNotification = "SCUserLoginSuccessfullyNotification"
let SCPhotoBrowserForWeiboCellNotification = "SCPhotoBrowserForWeiboCellNotification"

//Mark: - photo browser notificaton
let SCPhotoBrowserForWeiboCellSelectedImageIndex = "SCPhotoBrowserForWeiboCellSelectedImageIndex"
let SCPhotoBrowserForWeiboCellSelectedImageURLs = "SCPhotoBrowserForWeiboCellSelectedImageURLs"
let SCPhotoBrowserForWeiboCellSelectedImageVisibleImageViews = "SCPhotoBrowserForWeiboCellSelectedImageVisibleImageViews"

//Mark: - application information
let SCAppKey = "688141545"
let SCRedirectURI = "http://baidu.com"
let SCAppSecret = "72a8bc39b23d689acba994bf3f4ea160"
let SCSecurityDomain = "http://www.mob.com"

//Mark: - weibo item pictures attributes
let SCPicturesViewOutterMargin:CGFloat = 12
let SCPicturesViewInnerMargin:CGFloat = 3
let SCPicturesViewWidth = UIScreen.main.bounds.width - SCPicturesViewOutterMargin * 2
let SCPictureViewImageWidth = (SCPicturesViewWidth - SCPicturesViewInnerMargin * 2) / 3

